; Household Joint Probability Model (IPF)

; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DMMAT00B.PRN" MSG='Household Joint Classification Model (IPF)'

FILEI DBI[1] = "{CATALOG_DIR}\PARAMS\CLASSIFICATION\HH_SEED.DBF",
 AUTOARRAY=share
FILEI DBI[2] = "{SCENARIO_DIR}\INPUT\SE.DBF",
 AUTOARRAY=ALLFIELDS

; Distributions of Households for each possible average within a zone
FILEI DBI[3] = "{CATALOG_DIR}\PARAMS\CLASSIFICATION\HH_WORKER_LOOKUP.DBF",
 AUTOARRAY=ALLFIELDS
FILEI DBI[4] = "{CATALOG_DIR}\PARAMS\CLASSIFICATION\HH_SIZE_LOOKUP.DBF",
 AUTOARRAY=ALLFIELDS
FILEI DBI[5] = "{CATALOG_DIR}\PARAMS\CLASSIFICATION\HH_VEHICLE_LOOKUP.DBF",
 AUTOARRAY=ALLFIELDS

; Output Files
FILEO PRINTO[2] = "{SCENARIO_DIR}\OUTPUT\LOGS\CROSSCLASSDEBUG.PRN"
FILEO PRINTO[3] = "{SCENARIO_DIR}\OUTPUT\LOGS\CROSSCLASSREPORT.PRN"

FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\SE_CLASSIFIED_{YEAR}{ALTERNATIVE}.DBF",
	FORM=8.0,
	FIELDS=Z, COUNTY, ACRES, TAZ_OLD, FRED_UDA, POP, HH, WORK, VEH, HTRET, IND, OFF, RET, SER ,EMP,
					EMP_NOSG, SCHOOL, UNV, SG_RET, SG_AIR, SG_COL, SG_HOS, SG_NAME, DISTRICT, STU_PT, ID,
					N(4.0), W0V0(8.4), W0V1(8.4), W0V2(8.4), W0V3(8.4), W1V0(8.4), W1V1(8.4), W1V2(8.4), W1V3(8.4),
	                W2V0(8.4), W2V1(8.4), W2V2(8.4), W2V3(8.4), W3V0(8.4), W3V1(8.4), W3V2(8.4), W3V3(8.4),
	                P1V0(8.4), P1V1(8.4), P1V2(8.4), P1V3(8.4), P2V0(8.4), P2V1(8.4), P2V2(8.4), P2V3(8.4),
	                P3V0(8.4), P3V1(8.4), P3V2(8.4), P3V3(8.4), P4V0(8.4), P4V1(8.4), P4V2(8.4), P4V3(8.4)

PAR ZONES=169

;SET DEFAULTS
tolerance = 0.1			; tolerance
DebugZone=113			; selected zone for reporting debug info
MaxIterations=30			; iterations


; Define arrays for distributions
ARRAY TYPE=D, JOINT_DIST=ZONES,4,4,4
ARRAY TYPE=D, V_Marginals=ZONES,4
ARRAY TYPE=D, P_Marginals=ZONES,4
ARRAY TYPE=D, W_Marginals=ZONES,4
ARRAY ZN_SKIP=444, HHLDS=ZONES

;OUTPUT ARRAYS
ARRAY TYPE=D, WV=4,4
ARRAY TYPE=D, PV=4,4

;***********************************************************
; FILL MARGINALS ARRAYS FROM INPUT FILES
;	For each zone, match distribution percentages based on average Workers/HH, Persons/HH and Vehicles/HH

ARRAY TYPE=D, HHWRKS=ZONES
ARRAY TYPE=D, HHPERS=ZONES
ARRAY TYPE=D, HHVEHS=ZONES

COMP HHWRKS[I]=0
COMP HHPERS[I]=0
COMP HHVEHS[I]=0

IF (DBA.2.HH[I] > 0)
	COMP HHWRKS[I] = ROUND((DBA.2.WORK[I] / DBA.2.HH[I])*100)/100
	IF (HHWRKS[I] < DBA.3.AVG[1]) HHWRKS[I]=1  ; Make sure no average number of workers is less than the minimum

	COMP HHPERS[I] = ROUND((DBA.2.POP[I] / DBA.2.HH[I])*100)/100
	IF (HHPERS[I] < DBA.4.AVG[1]) HHPERS[I]=1  ; Make sure no household size is is less than the minimum

	COMP HHVEHS[I] = ROUND((DBA.2.VEH[I] / DBA.2.HH[I])*100)/100
	IF (HHVEHS[I] < DBA.5.AVG[1]) HHVEHS[I]=1  ; Make sure no average number of vehicles is less than the minimum
ENDIF

IF(I == ZONES)
	LOOP ZN=1, ZONES				   ; First loop ver zones to create marginal arrays
		IF (DBA.2.HH[ZN]=0)			   ; for SE records with zero households, set all shares to 0 and skip processing
			W_Marginals[ZN][1]=0
			W_Marginals[ZN][2]=0
			W_Marginals[ZN][3]=0
			W_Marginals[ZN][4]=0
			P_Marginals[ZN][1]=0
			P_Marginals[ZN][2]=0
			P_Marginals[ZN][3]=0
			P_Marginals[ZN][4]=0
			V_Marginals[ZN][1]=0
			V_Marginals[ZN][2]=0
			V_Marginals[ZN][3]=0
			V_Marginals[ZN][4]=0
		ELSE
			LOOP RECNO=1, DBI.3.NUMRECORDS		 ; Loop through avg HHWRKS distribution table to find record that matches SE data avg HHWRKS
			  ; IF average HHWRKS is greater tha the largest value in the HH dist table take the largest value
				IF (HHWRKS[ZN] > DBA.3.AVG[DBI.3.NUMRECORDS])
					W_Marginals[ZN][1]= DBA.3.WORKERS_0[DBI.3.NUMRECORDS]
					W_Marginals[ZN][2]= DBA.3.WORKERS_1[DBI.3.NUMRECORDS]
					W_Marginals[ZN][3]= DBA.3.WORKERS_2[DBI.3.NUMRECORDS]
					W_Marginals[ZN][4]= DBA.3.WORKERS_3[DBI.3.NUMRECORDS]
					BREAK
				ENDIF
				IF (HHWRKS[ZN] == DBA.3.AVG[RECNO])
					W_Marginals[ZN][1]= DBA.3.WORKERS_0[RECNO]
					W_Marginals[ZN][2]= DBA.3.WORKERS_1[RECNO]
					W_Marginals[ZN][3]= DBA.3.WORKERS_2[RECNO]
					W_Marginals[ZN][4]= DBA.3.WORKERS_3[RECNO]
					BREAK
				ENDIF
			ENDLOOP		;end of loop for worker shares

			LOOP RECNO=1, DBI.4.NUMRECORDS	  ; Loop through avg HHPERS distribution table to find record that matches SE data avg HHPERS
			  ; IF average HHPERS is greater tha the largest value in the HH dist table take the largest value
				IF (HHPERS[ZN] > DBA.4.AVG[DBI.4.NUMRECORDS])
					P_Marginals[ZN][1]= DBA.4.PERSONS_1[DBI.4.NUMRECORDS]
					P_Marginals[ZN][2]= DBA.4.PERSONS_2[DBI.4.NUMRECORDS]
					P_Marginals[ZN][3]= DBA.4.PERSONS_3[DBI.4.NUMRECORDS]
					P_Marginals[ZN][4]= DBA.4.PERSONS_4[DBI.4.NUMRECORDS]
					BREAK
				ENDIF
				IF (HHPERS[ZN] == DBA.4.AVG[RECNO])
					P_Marginals[ZN][1]= DBA.4.PERSONS_1[RECNO]
					P_Marginals[ZN][2]= DBA.4.PERSONS_2[RECNO]
					P_Marginals[ZN][3]= DBA.4.PERSONS_3[RECNO]
					P_Marginals[ZN][4]= DBA.4.PERSONS_4[RECNO]
					BREAK
				ENDIF
			ENDLOOP		;end of loop for household size shares

			LOOP RECNO=1, DBI.5.NUMRECORDS		 ; Loop through avg HHVEHS distribution table to find record that matches SE data avg HHVEHS
			  ; IF average HHVEHS is greater tha the largest value in the HH dist table take the largest value
				IF (HHVEHS[ZN] > DBA.5.AVG[DBI.5.NUMRECORDS])
					V_Marginals[ZN][1]= DBA.5.VEHICLES_0[DBI.5.NUMRECORDS]
					V_Marginals[ZN][2]= DBA.5.VEHICLES_1[DBI.5.NUMRECORDS]
					V_Marginals[ZN][3]= DBA.5.VEHICLES_2[DBI.5.NUMRECORDS]
					V_Marginals[ZN][4]= DBA.5.VEHICLES_3[DBI.5.NUMRECORDS]
					BREAK
				ENDIF
				IF (DBA.5.AVG[RECNO] == HHVEHS[ZN])
					V_Marginals[ZN][1]= DBA.5.VEHICLES_0[RECNO]
					V_Marginals[ZN][2]= DBA.5.VEHICLES_1[RECNO]
					V_Marginals[ZN][3]= DBA.5.VEHICLES_2[RECNO]
					V_Marginals[ZN][4]= DBA.5.VEHICLES_3[RECNO]
					BREAK
				ENDIF
			ENDLOOP		;	end of loop for vehicle shares
		ENDIF			 		;	end of processing for zones with non-zero households
	 ENDLOOP				;	end of first loop over zones in the SE data to create marginal arrays

	;	****************************************************************************************
	;	INITIAL IPF LOOP --- PERFORMED FOR EACH ZONE

	LOOP ZN=1,ZONES ; main loop on zones

		; Print to Report Main Loop Title
		IF(ZN == 1) PRINT LIST=	"Household Joint Classification Model (IPF) Results",
													"\n                Model Alternative  = {Year}{Alternative}", PRINTO=3

		IF(DBA.2.HH[ZN] > 0)
			; -------------------------------------------------------------------------------------------
			; Initialize targets from seed matrix for each zone
			; Seeds are in order - vehs 0-3, pers 1-4 witin vehs, wrks 0-3 within pers
			RECNO=0
			LOOP WRKS = 1,4    ; Workers
				LOOP PERS = 1,4  ; Persons
					LOOP VEHS = 1,4  ; Vehicles
					IPWD= (100*WRKS) + (10*PERS) + VEHS
					RECNO = RECNO + 1
					JOINT_DIST[ZN][WRKS][PERS][VEHS] = DBA.1.share[RECNO]	; HH SEEDS are in an array shares[64]. Initialize the joint distribution with the seed.
					IF(JOINT_DIST[ZN][WRKS][PERS][VEHS]=0) ZN_SKIP[IPWD]=1
					ENDLOOP ;Vehicless
				ENDLOOP ;Persons
			ENDLOOP ; Workers

			; -------------------------------------------------------------------------------------------
			;    START ITERATIVE PROPORTIONAL FIT

			LOOP ITER=1, MaxIterations		;	Tabulate  marginals
			M_WRKS0 = 0, M_WRKS1 = 0, M_WRKS2 = 0, M_WRKS3 = 0
			M_PERS1 = 0, M_PERS2 = 0, M_PERS3 = 0, M_PERS4 = 0
			M_VEHS1 = 0, M_VEHS2 = 0, M_VEHS3 = 0, M_VEHS4 = 0
			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF(WRKS==1) M_WRKS0 = M_WRKS0 + JOINT_DIST[ZN][1][PERS][VEHS]
						IF(WRKS==2) M_WRKS1 = M_WRKS1 + JOINT_DIST[ZN][2][PERS][VEHS]
						IF(WRKS==3) M_WRKS2 = M_WRKS2 + JOINT_DIST[ZN][3][PERS][VEHS]
						IF(WRKS==4) M_WRKS3 = M_WRKS3 + JOINT_DIST[ZN][4][PERS][VEHS]

						IF(PERS==1) M_PERS1 = M_PERS1 + JOINT_DIST[ZN][WRKS][1][VEHS]
						IF(PERS==2) M_PERS2 = M_PERS2 + JOINT_DIST[ZN][WRKS][2][VEHS]
						IF(PERS==3) M_PERS3 = M_PERS3 + JOINT_DIST[ZN][WRKS][3][VEHS]
						IF(PERS==4) M_PERS4 = M_PERS4 + JOINT_DIST[ZN][WRKS][4][VEHS]

						IF(VEHS==1) M_VEHS1 = M_VEHS1 + JOINT_DIST[ZN][WRKS][PERS][1]
						IF(VEHS==2) M_VEHS2 = M_VEHS2 + JOINT_DIST[ZN][WRKS][PERS][2]
						IF(VEHS==3) M_VEHS3 = M_VEHS3 + JOINT_DIST[ZN][WRKS][PERS][3]
						IF(VEHS==4) M_VEHS4 = M_VEHS4 + JOINT_DIST[ZN][WRKS][PERS][4]
					ENDLOOP
				ENDLOOP
			ENDLOOP

			;Tabulate ratios of targets to marginals
			margin0=0
			IF(M_WRKS0>0) margin0=margin0+abs(1-(W_Marginals[ZN][1]/M_WRKS0))
			IF(M_WRKS1>0) margin0=margin0+abs(1-(W_Marginals[ZN][2]/M_WRKS1))
			IF(M_WRKS2>0) margin0=margin0+abs(1-(W_Marginals[ZN][3]/M_WRKS2))
			IF(M_WRKS3>0) margin0=margin0+abs(1-(W_Marginals[ZN][4]/M_WRKS3))

			IF(M_PERS1>0) margin0=margin0+abs(1-(P_Marginals[ZN][1]/M_PERS1))
			IF(M_PERS2>0) margin0=margin0+abs(1-(P_Marginals[ZN][2]/M_PERS2))
			IF(M_PERS3>0) margin0=margin0+abs(1-(P_Marginals[ZN][3]/M_PERS3))
			IF(M_PERS4>0) margin0=margin0+abs(1-(P_Marginals[ZN][4]/M_PERS4))

			IF(M_VEHS1>0) margin0=margin0+abs(1-(V_Marginals[ZN][1]/M_VEHS1))
			IF(M_VEHS2>0) margin0=margin0+abs(1-(V_Marginals[ZN][2]/M_VEHS2))
			IF(M_VEHS3>0) margin0=margin0+abs(1-(V_Marginals[ZN][3]/M_VEHS3))
			IF(M_VEHS4>0) margin0=margin0+abs(1-(V_Marginals[ZN][4]/M_VEHS4))

			;	*****************************************************************************
			; 	PRINT DIAGNOSTICS FOR SELECTED ZONE (DebugZone)

			IF(ZN = DebugZone & ITER < MaxIterations)
				PRINT PRINTO=2, LIST="\n-----------------------------------------",
				"\nTAZ = ", zn(4.0), " IPF ITERATION=",ITER(5.0), " TOLERANCE = ", tolerance, "  Aggregate % diff. = ", (margin0*100)(6.2),
				"\n               MRG1    MRG2    MRG3    MRG4",
				"\n WORKER MODEL RESULTS ",M_WRKS0(10.4)," ",M_WRKS1(10.4)," ",M_WRKS2(10.4)," ",M_WRKS3(10.4),
				"\n  TARGET VALUES   ",W_Marginals[ZN][1](10.4)," ",W_Marginals[ZN][2](10.4)," ",W_Marginals[ZN][3](10.4)," ",W_Marginals[ZN][4](10.4),
				"\n\n PERSON MODEL RESULTS ",M_PERS1(10.4)," ",M_PERS2(10.4)," ",M_PERS3(10.4)," ",M_PERS4(10.4),
				"\n  TARGET VALUES   ",P_Marginals[ZN][1](10.4)," ",P_Marginals[ZN][2](10.4)," ",P_Marginals[ZN][3](10.4)," ",P_Marginals[ZN][4](10.4),
				"\n\n VEHICLE MODEL RESULTS",M_VEHS1(10.4)," ",M_VEHS2(10.4)," ",M_VEHS3(10.4)," ",M_VEHS4(10.4),
				"\n  TARGET VALUES   ",V_Marginals[ZN][1](10.4)," ",V_Marginals[ZN][2](10.4)," ",V_Marginals[ZN][3](10.4)," ",V_Marginals[ZN][4](10.4),
				"\n"
			ENDIF

			; check for convergence and break out of LOOP if converged
			IF(margin0 < tolerance)
				CONVERGED='Yes'
				BREAK
			ELSE
				CONVERGED='No'
			ENDIF

			;	*****************************************************************************
			; 	ADJUST DISTRIBUTION BASED ON TARGET MARGINALS
			; 		Zero out cells with zero marginals
			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF(W_Marginals[ZN][1]=0) JOINT_DIST[ZN][1][PERS][VEHS] = 0
						IF(W_Marginals[ZN][2]=0) JOINT_DIST[ZN][2][PERS][VEHS] = 0
						IF(W_Marginals[ZN][3]=0) JOINT_DIST[ZN][3][PERS][VEHS] = 0
						IF(W_Marginals[ZN][4]=0) JOINT_DIST[ZN][4][PERS][VEHS] = 0

 						IF(P_Marginals[ZN][1]=0) JOINT_DIST[ZN][WRKS][1][VEHS] = 0
						IF(P_Marginals[ZN][2]=0) JOINT_DIST[ZN][WRKS][2][VEHS] = 0
						IF(P_Marginals[ZN][3]=0) JOINT_DIST[ZN][WRKS][3][VEHS] = 0
						IF(P_Marginals[ZN][4]=0) JOINT_DIST[ZN][WRKS][4][VEHS] = 0

						IF(V_Marginals[ZN][1]=0) JOINT_DIST[ZN][WRKS][PERS][1] = 0
						IF(V_Marginals[ZN][2]=0) JOINT_DIST[ZN][WRKS][PERS][2] = 0
						IF(V_Marginals[ZN][3]=0) JOINT_DIST[ZN][WRKS][PERS][3] = 0
						IF(V_Marginals[ZN][4]=0) JOINT_DIST[ZN][WRKS][PERS][4] = 0
					ENDLOOP
				ENDLOOP
			ENDLOOP

			;	*****************************************************************************
			; 	FIRST CALCULATE ADJUSTMENT FOR VEHICLE OWNERSHIP
			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF((V_Marginals[ZN][VEHS]>0) && (P_Marginals[ZN][PERS]>0) && (W_Marginals[ZN][WRKS]>0))
							IF(VEHS=1) JOINT_DIST[ZN][WRKS][PERS][1] = JOINT_DIST[ZN][WRKS][PERS][1] * V_Marginals[ZN][1] / M_VEHS1
							IF(VEHS=2) JOINT_DIST[ZN][WRKS][PERS][2] = JOINT_DIST[ZN][WRKS][PERS][2] * V_Marginals[ZN][2] / M_VEHS2
							IF(VEHS=3) JOINT_DIST[ZN][WRKS][PERS][3] = JOINT_DIST[ZN][WRKS][PERS][3] * V_Marginals[ZN][3] / M_VEHS3
							IF(VEHS=4) JOINT_DIST[ZN][WRKS][PERS][4] = JOINT_DIST[ZN][WRKS][PERS][4] * V_Marginals[ZN][4] / M_VEHS4
						ENDIF
					ENDLOOP
				ENDLOOP
			ENDLOOP

			M_VEHS1 = 0, M_VEHS2 = 0, M_VEHS3 = 0, M_VEHS4 = 0
			M_PERS1 = 0, M_PERS2 = 0, M_PERS3 = 0, M_PERS4 = 0
			M_WRKS0 = 0, M_WRKS1 = 0, M_WRKS2 = 0, M_WRKS3 = 0

			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF(VEHS=1) M_VEHS1 = M_VEHS1 + JOINT_DIST[ZN][WRKS][PERS][1]
						IF(VEHS=2) M_VEHS2 = M_VEHS2 + JOINT_DIST[ZN][WRKS][PERS][2]
						IF(VEHS=3) M_VEHS3 = M_VEHS3 + JOINT_DIST[ZN][WRKS][PERS][3]
						IF(VEHS=4) M_VEHS4 = M_VEHS4 + JOINT_DIST[ZN][WRKS][PERS][4]

						IF(PERS=1) M_PERS1 = M_PERS1 + JOINT_DIST[ZN][WRKS][1][VEHS]
						IF(PERS=2) M_PERS2 = M_PERS2 + JOINT_DIST[ZN][WRKS][2][VEHS]
						IF(PERS=3) M_PERS3 = M_PERS3 + JOINT_DIST[ZN][WRKS][3][VEHS]
						IF(PERS=4) M_PERS4 = M_PERS4 + JOINT_DIST[ZN][WRKS][4][VEHS]

						IF(WRKS=1) M_WRKS0 = M_WRKS0 + JOINT_DIST[ZN][1][PERS][VEHS]
						IF(WRKS=2) M_WRKS1 = M_WRKS1 + JOINT_DIST[ZN][2][PERS][VEHS]
						IF(WRKS=3) M_WRKS2 = M_WRKS2 + JOINT_DIST[ZN][3][PERS][VEHS]
						IF(WRKS=4) M_WRKS3 = M_WRKS3 + JOINT_DIST[ZN][4][PERS][VEHS]
					ENDLOOP
				ENDLOOP
			ENDLOOP

			;	*****************************************************************************
			; 	SECOND CALUCLATE ADJUSTMENT FOR HOUSEHOLD SIZE
			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF((V_Marginals[ZN][VEHS]>0) && (P_Marginals[ZN][PERS]>0) && (W_Marginals[ZN][WRKS]>0))
							IF(PERS=1) JOINT_DIST[ZN][WRKS][1][VEHS] = JOINT_DIST[ZN][WRKS][1][VEHS] * P_Marginals[ZN][1] / M_PERS1
							IF(PERS=2) JOINT_DIST[ZN][WRKS][2][VEHS] = JOINT_DIST[ZN][WRKS][2][VEHS] * P_Marginals[ZN][2] / M_PERS2
							IF(PERS=3) JOINT_DIST[ZN][WRKS][3][VEHS] = JOINT_DIST[ZN][WRKS][3][VEHS] * P_Marginals[ZN][3] / M_PERS3
							IF(PERS=4) JOINT_DIST[ZN][WRKS][4][VEHS] = JOINT_DIST[ZN][WRKS][4][VEHS] * P_Marginals[ZN][4] / M_PERS4
						ENDIF
					ENDLOOP
				ENDLOOP
			ENDLOOP

			M_VEHS1 = 0, M_VEHS2 = 0, M_VEHS3 = 0, M_VEHS4 = 0
			M_PERS1 = 0, M_PERS2 = 0, M_PERS3 = 0, M_PERS4 = 0
			M_WRKS0 = 0, M_WRKS1 = 0, M_WRKS2 = 0, M_WRKS3 = 0

			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF(VEHS=1) M_VEHS1 = M_VEHS1 + JOINT_DIST[ZN][WRKS][PERS][1]
						IF(VEHS=2) M_VEHS2 = M_VEHS2 + JOINT_DIST[ZN][WRKS][PERS][2]
						IF(VEHS=3) M_VEHS3 = M_VEHS3 + JOINT_DIST[ZN][WRKS][PERS][3]
						IF(VEHS=4) M_VEHS4 = M_VEHS4 + JOINT_DIST[ZN][WRKS][PERS][4]

						IF(PERS=1) M_PERS1 = M_PERS1 + JOINT_DIST[ZN][WRKS][1][VEHS]
						IF(PERS=2) M_PERS2 = M_PERS2 + JOINT_DIST[ZN][WRKS][2][VEHS]
						IF(PERS=3) M_PERS3 = M_PERS3 + JOINT_DIST[ZN][WRKS][3][VEHS]
						IF(PERS=4) M_PERS4 = M_PERS4 + JOINT_DIST[ZN][WRKS][4][VEHS]

						IF(WRKS=1) M_WRKS0 = M_WRKS0 + JOINT_DIST[ZN][1][PERS][VEHS]
						IF(WRKS=2) M_WRKS1 = M_WRKS1 + JOINT_DIST[ZN][2][PERS][VEHS]
						IF(WRKS=3) M_WRKS2 = M_WRKS2 + JOINT_DIST[ZN][3][PERS][VEHS]
						IF(WRKS=4) M_WRKS3 = M_WRKS3 + JOINT_DIST[ZN][4][PERS][VEHS]
					ENDLOOP
				ENDLOOP
			ENDLOOP

			;	*****************************************************************************
			; 	THIRD CALCULATE ADJUSTMENT FOR WORKERS PER HOUSEHOLD
			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF((V_Marginals[ZN][VEHS]>0) && (P_Marginals[ZN][PERS]>0) && (W_Marginals[ZN][WRKS]>0))
							IF(WRKS=1 && M_WRKS0>0) JOINT_DIST[ZN][1][PERS][VEHS] = JOINT_DIST[ZN][1][PERS][VEHS] * W_Marginals[ZN][1] / M_WRKS0
							IF(WRKS=2 && M_WRKS1>0) JOINT_DIST[ZN][2][PERS][VEHS] = JOINT_DIST[ZN][2][PERS][VEHS] * W_Marginals[ZN][2] / M_WRKS1
							IF(WRKS=3 && M_WRKS2>0) JOINT_DIST[ZN][3][PERS][VEHS] = JOINT_DIST[ZN][3][PERS][VEHS] * W_Marginals[ZN][3] / M_WRKS2
							IF(WRKS=4 && M_WRKS3>0) JOINT_DIST[ZN][4][PERS][VEHS] = JOINT_DIST[ZN][4][PERS][VEHS] * W_Marginals[ZN][4] / M_WRKS3
						ENDIF
					ENDLOOP
				ENDLOOP
			ENDLOOP

			M_VEHS1 = 0, M_VEHS2 = 0, M_VEHS3 = 0, M_VEHS4 = 0
			M_PERS1 = 0, M_PERS2 = 0, M_PERS3 = 0, M_PERS4 = 0
			M_WRKS0 = 0, M_WRKS1 = 0, M_WRKS2 = 0, M_WRKS3 = 0

			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF(VEHS=1) M_VEHS1 = M_VEHS1 + JOINT_DIST[ZN][WRKS][PERS][1]
						IF(VEHS=2) M_VEHS2 = M_VEHS2 + JOINT_DIST[ZN][WRKS][PERS][2]
						IF(VEHS=3) M_VEHS3 = M_VEHS3 + JOINT_DIST[ZN][WRKS][PERS][3]
						IF(VEHS=4) M_VEHS4 = M_VEHS4 + JOINT_DIST[ZN][WRKS][PERS][4]

						IF(PERS=1) M_PERS1 = M_PERS1 + JOINT_DIST[ZN][WRKS][1][VEHS]
						IF(PERS=2) M_PERS2 = M_PERS2 + JOINT_DIST[ZN][WRKS][2][VEHS]
						IF(PERS=3) M_PERS3 = M_PERS3 + JOINT_DIST[ZN][WRKS][3][VEHS]
						IF(PERS=4) M_PERS4 = M_PERS4 + JOINT_DIST[ZN][WRKS][4][VEHS]

						IF(WRKS=1) M_WRKS0 = M_WRKS0 + JOINT_DIST[ZN][1][PERS][VEHS]
						IF(WRKS=2) M_WRKS1 = M_WRKS1 + JOINT_DIST[ZN][2][PERS][VEHS]
						IF(WRKS=3) M_WRKS2 = M_WRKS2 + JOINT_DIST[ZN][3][PERS][VEHS]
						IF(WRKS=4) M_WRKS3 = M_WRKS3 + JOINT_DIST[ZN][4][PERS][VEHS]
					ENDLOOP
				ENDLOOP
			ENDLOOP

			;	*****************************************************************************
			; 	Normalize the Seed Arrays on each iteration just to avoid ending up with bizarre results
			; 		when the matrix is not solvable.
			ZDTOTAL=0

			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						ZDTOTAL = ZDTOTAL + JOINT_DIST[ZN][WRKS][PERS][VEHS]
					ENDLOOP ; Workers
				ENDLOOP ; Persons
			ENDLOOP ; Income

			LOOP WRKS=1,4
				LOOP PERS=1,4
					LOOP VEHS=1,4
						IF(ZDTOTAL>0)
							JOINT_DIST[ZN][WRKS][PERS][VEHS] = JOINT_DIST[ZN][WRKS][PERS][VEHS]/ZDTOTAL
						ELSE
							JOINT_DIST[ZN][WRKS][PERS][VEHS] = 0
						ENDIF
					ENDLOOP ; Workers
				ENDLOOP ; Persons
			ENDLOOP ; Income

			;	*****************************************************************************
			; 	ON THE LAST ITERATION REMOVE CELLS WITH TINY VALUES AND NORMALIZE
			IF (ITER==MaxIterations)
				LOOP WRKS=1,4
					LOOP PERS=1,4
						LOOP VEHS=1,4
							IPWD= (100*WRKS) + (10*PERS) + VEHS
							IF(JOINT_DIST[ZN][WRKS][PERS][VEHS]<0.00001)
								JOINT_DIST[ZN][WRKS][PERS][VEHS]=0.0
							ENDIF
						ENDLOOP ; Workers
					ENDLOOP ; Persons
				ENDLOOP ; Income
			ENDIF

			IF(ITER=MaxIterations)
				ZDTOTAL=0
				LOOP WRKS=1,4
					LOOP PERS=1,4
						LOOP VEHS=1,4
							ZDTOTAL = ZDTOTAL + JOINT_DIST[ZN][WRKS][PERS][VEHS]
						ENDLOOP  ; Workers
					ENDLOOP  ; Persons
				ENDLOOP  ; Income

				LOOP WRKS=1,4
					LOOP PERS=1,4
						LOOP VEHS=1,4
							IF(ZDTOTAL>0)
								JOINT_DIST[ZN][WRKS][PERS][VEHS] = JOINT_DIST[ZN][WRKS][PERS][VEHS]/ZDTOTAL
							ELSE
								JOINT_DIST[ZN][WRKS][PERS][VEHS] = 0
							ENDIF
						ENDLOOP  ; Workers
					ENDLOOP  ; Persons
				ENDLOOP  ; Income
			ENDIF  ; ITER=MaxIterations

			ENDLOOP       ;	END MAIN LOOP -- FOR  ITER=1,MaxIterations

			;-------------------------------------------------------------------------------------------
			;	REPORT FINAL CONVERGENCE DATA FOR EACH ZONE
			IF(ZN==1) PRINT LIST = "HOUSEHOLD CLASSIFICATION IPF CONVERGENCE", PRINTO=3
			PRINT PRINTO=3 LIST = "TAZ=", ZN(3), " ITERATION=", ITER(3.0), " MARGIN=", margin0(6.3),
				" TOLERANCE=", tolerance(6.3), " CONVERGED = ", CONVERGED

			;-------------------------------------------------------------------------------------------
			;AGGREGATE ALL HHSIZE PERCENTAGERS FOR THE WORKER-VEIHICLE LEVEL
			LOOP WRKS=1,4
				LOOP VEHS=1,4
					WV[WRKS][VEHS]=0
					LOOP PERS=1,4
						WV[WRKS][VEHS]=WV[WRKS][VEHS] + JOINT_DIST[ZN][WRKS][PERS][VEHS]
					ENDLOOP
				ENDLOOP
			ENDLOOP

			;-------------------------------------------------------------------------------------------
			;AGGREGATE ALL WORKER PERCENTAGERS FOR THE  HHSIZE-VEIHICLE LEVEL
			LOOP PERS=1,4
				LOOP VEHS=1,4
					PV[PERS][VEHS]=0
					LOOP WRKS=1,4
				 		PV[PERS][VEHS]=PV[PERS][VEHS] + JOINT_DIST[ZN][WRKS][PERS][VEHS]
					ENDLOOP
				ENDLOOP
			ENDLOOP

			;-------------------------------------------------------------------------------------------
			;	WRITE OUT RESULTS WITH ALL SE DATA FIELDS ON ORIGINAL SE.DBF FILE
			;		First, set values for previously existing SE dataset variables
			RO.Z = DBA.2.Z[ZN]
			RO.COUNTY = DBA.2.COUNTY[ZN]
			RO.ACRES = DBA.2.ACRES[ZN]
			RO.TAZ_OLD = DBA.2.TAZ_OLD[ZN]
			RO.FRED_UDA = DBA.2.FRED_UDA[ZN]
			RO.POP = DBA.2.POP[ZN]
			RO.HH = DBA.2.HH[ZN]
			RO.WORK = DBA.2.WORK[ZN]
			RO.VEH = DBA.2.VEH[ZN]
			RO.HTRET = DBA.2.HTRET[ZN]
			RO.IND = DBA.2.IND[ZN]
			RO.OFF = DBA.2.OFF[ZN]
			RO.RET = DBA.2.RET[ZN]
			RO.SER = DBA.2.SER[ZN]
			RO.EMP = DBA.2.EMP[ZN]
			RO.EMP_NOSG = DBA.2.EMP_NOSG[ZN]
			RO.SCHOOL = DBA.2.SCHOOL[ZN]
			RO.UNV = DBA.2.UNV[ZN]
			RO.SG_RET = DBA.2.SG_RET[ZN]
			RO.SG_AIR = DBA.2.SG_AIR[ZN]
			RO.SG_COL = DBA.2.SG_COL[ZN]
			RO.SG_HOS = DBA.2.SG_HOS[ZN]
			RO.SG_NAME = DBA.2.SG_NAME[ZN]
			RO.DISTRICT = DBA.2.DISTRICT[ZN]
			RO.ID = DBA.2.ID[ZN]

			;	Then set newly created variable values
            RO.N=ZN
			RO.W0V0 = WV[1][1]	 * DBA.2.HH[ZN]
			RO.W0V1 = WV[1][2] 	 * DBA.2.HH[ZN]
			RO.W0V2 = WV[1][3] 	 * DBA.2.HH[ZN]
			RO.W0V3 = WV[1][4] 	 * DBA.2.HH[ZN]
			RO.W1V0 = WV[2][1] 	 * DBA.2.HH[ZN]
			RO.W1V1 = WV[2][2] 	 * DBA.2.HH[ZN]
			RO.W1V2 = WV[2][3] 	 * DBA.2.HH[ZN]
			RO.W1V3 = WV[2][4] 	 * DBA.2.HH[ZN]
			RO.W2V0 = WV[3][1] 	 * DBA.2.HH[ZN]
			RO.W2V1 = WV[3][2] 	 * DBA.2.HH[ZN]
			RO.W2V2 = WV[3][3] 	 * DBA.2.HH[ZN]
			RO.W2V3 = WV[3][4] 	 * DBA.2.HH[ZN]
			RO.W3V0 = WV[4][1] 	 * DBA.2.HH[ZN]
			RO.W3V1 = WV[4][2] 	 * DBA.2.HH[ZN]
			RO.W3V2 = WV[4][3] 	 * DBA.2.HH[ZN]
			RO.W3V3 = WV[4][4] 	 * DBA.2.HH[ZN]
			RO.P1V0 = PV[1][1]		 * DBA.2.HH[ZN]
			RO.P1V1 = PV[1][2] 	 * DBA.2.HH[ZN]
			RO.P1V2 = PV[1][3] 	 * DBA.2.HH[ZN]
			RO.P1V3 = PV[1][4] 	 * DBA.2.HH[ZN]
			RO.P2V0 = PV[2][1] 	 * DBA.2.HH[ZN]
			RO.P2V1 = PV[2][2] 	 * DBA.2.HH[ZN]
			RO.P2V2 = PV[2][3] 	 * DBA.2.HH[ZN]
			RO.P2V3 = PV[2][4] 	 * DBA.2.HH[ZN]
			RO.P3V0 = PV[3][1] 	 * DBA.2.HH[ZN]
			RO.P3V1 = PV[3][2] 	 * DBA.2.HH[ZN]
			RO.P3V2 = PV[3][3] 	 * DBA.2.HH[ZN]
			RO.P3V3 = PV[3][4] 	 * DBA.2.HH[ZN]
			RO.P4V0 = PV[4][1] 	 * DBA.2.HH[ZN]
			RO.P4V1 = PV[4][2] 	 * DBA.2.HH[ZN]
			RO.P4V2 = PV[4][3] 	 * DBA.2.HH[ZN]
			RO.P4V3 = PV[4][4] 	 * DBA.2.HH[ZN]
			WRITE RECO=1

		;-------------------------------------------------------------------------------------------
		;	WRITE OUT VALUES FOR ZONES WITH ZERO HOUSEHOLDS
		ELSE		; DBA.2.HH[ZN] EQUAL 0, -- No households in this zone, report zero for all classes
			;	First, set values for previously existing SE dataset variables
			RO.Z = DBA.2.Z[ZN]
			RO.COUNTY = DBA.2.COUNTY[ZN]
			RO.ACRES = DBA.2.ACRES[ZN]
			RO.TAZ_OLD = DBA.2.TAZ_OLD[ZN]
			RO.FRED_UDA = DBA.2.FRED_UDA[ZN]
			RO.POP = DBA.2.POP[ZN]
			RO.HH = DBA.2.HH[ZN]
			RO.WORK = DBA.2.WORK[ZN]
			RO.VEH = DBA.2.VEH[ZN]
			RO.HTRET = DBA.2.HTRET[ZN]
			RO.IND = DBA.2.IND[ZN]
			RO.OFF = DBA.2.OFF[ZN]
			RO.RET = DBA.2.RET[ZN]
			RO.SER = DBA.2.SER[ZN]
			RO.EMP = DBA.2.EMP[ZN]
			RO.EMP_NOSG = DBA.2.EMP_NOSG[ZN]
			RO.SCHOOL = DBA.2.SCHOOL[ZN]
			RO.UNV = DBA.2.UNV[ZN]
			RO.SG_RET = DBA.2.SG_RET[ZN]
			RO.SG_AIR = DBA.2.SG_AIR[ZN]
			RO.SG_COL = DBA.2.SG_COL[ZN]
			RO.SG_HOS = DBA.2.SG_HOS[ZN]
			RO.SG_NAME = DBA.2.SG_NAME[ZN]
			RO.DISTRICT = DBA.2.DISTRICT[ZN]
			RO.ID = DBA.2.ID[ZN]

			;	Then set newly created variable values
			RO.N=ZN
			RO.W0V0 = 0.0
			RO.W0V1 = 0.0
			RO.W0V2 = 0.0
			RO.W0V3 = 0.0
			RO.W1V0 = 0.0
			RO.W1V1 = 0.0
			RO.W1V2 = 0.0
			RO.W1V3 = 0.0
			RO.W2V0 = 0.0
			RO.W2V1 = 0.0
			RO.W2V2 = 0.0
			RO.W2V3 = 0.0
			RO.W3V0 = 0.0
			RO.W3V1 = 0.0
			RO.W3V2 = 0.0
			RO.W3V3 = 0.0
			RO.P1V0 = 0.0
			RO.P1V1 = 0.0
			RO.P1V2 = 0.0
			RO.P1V3 = 0.0
			RO.P2V0 = 0.0
			RO.P2V1 = 0.0
			RO.P2V2 = 0.0
			RO.P2V3 = 0.0
			RO.P3V0 = 0.0
			RO.P3V1 = 0.0
			RO.P3V2 = 0.0
			RO.P3V3 = 0.0
			RO.P4V0 = 0.0
			RO.P4V1 = 0.0
			RO.P4V2 = 0.0
			RO.P4V3 = 0.0
			WRITE RECO=1
			PRINT LIST="\n ", "nZONE=", ZN(4.0), " No Households in this Zone - No IPF performed", PRINTO=3
		ENDIF  ; DBA.2.HH[ZN] equal 0

	ENDLOOP  ; CLOSE ZONE LOOP

ENDIF ; End Analysis

ENDRUN
