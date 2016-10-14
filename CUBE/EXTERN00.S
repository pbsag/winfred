; Script for program FRATAR in file "C:\projects\winfred\CUBE\EEFRA00A.S"

; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EEFRA00A.PRN" MSG='Future year EE Table'
FILEI MATI[1] = "{CATALOG_DIR}\PARAMS\EE_seed.MAT"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\INPUT\EXTERNALTRIPS.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT",
 MO=1,NAME = EE_TRIPS, DEC=1*D

; Apply growth rate to base year EE seed matrix marginals
;  to obtain future year target through trips at external
;  stations.
; Fratar external seed table to Productions and Attractions.


PARAMETERS MAXRMSE=0.0001 MAXITERS=25
; USE A LOOKUP FILE TO find appropriate factors (1.0 is assumed unless expressly provided)
LOOKUP LOOKUPI=1, LIST=Y,
  NAME=GROWTHF,
  LOOKUP[1]=ZONE,RESULT=GRWTH_{YEAR},
  LOOKUP[2]=ZONE,RESULT=GRWTH_{YEAR},
  FAIL[1]=1,FAIL[2]=1,FAIL[3]=1

SETPA PGF[1]=GROWTHF(1,I) AGF[1]=GROWTHF(2,I) MW[1]=MI.1.1 

ENDRUN


; Script for program MATRIX in file "C:\projects\winfred\Cube\EE_HwySkims.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_HwySkims.PRN" MSG='Process Highway Skims'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT",
 MO=11-15,DEC=5*D,NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME
FILEI MATI[1] = "{SCENARIO_DIR}\Output\IMPED11.MAT"

FILLMW MW[1]=MI.1.1(5)                ; highway skims

; Reset invalid values to zero
; Matrices in the Matrix File IMPED11.MAT
;   1 = TIME
;   2 = DIST
;   3 = OTERM
;   4 = DTERM
;   5 = TOTAL_TIME

;  For skim values that are extraordinaryly large, set the value to 0.
  JLOOP
      IF (MW[1] > 1000)
          MW[11] = 0
      ELSE
          MW[11] = MW[1]
      ENDIF

      IF (MW[2] > 1000)
          MW[12] = 0
      ELSE
          MW[12] = MW[2]
      ENDIF

      IF (MW[3] > 1000)
          MW[13] = 0
      ELSE
          MW[13] = MW[3]
      ENDIF

      IF (MW[4] > 1000)
          MW[14] = 0
      ELSE
          MW[14] = MW[4]
      ENDIF

      IF (MW[5] > 1000)
          MW[15] = 0
      ELSE
          MW[15] = MW[5]
      ENDIF

      ENDJLOOP

ENDRUN


; Script for program GENERATION in file "C:\projects\winfred\Cube\EE_TripGen.S"
;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_TripGen.PRN" MSG='IEEI_TripGen'
FILEI ZDATI[2] = "{SCENARIO_DIR}\INPUT\EXTERNALTRIPS.DBF"
FILEO PAO[1] = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF",
FORM=10.3, DBF=T, LIST=Z, P[1], A[1]
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\se.dbf"

ZONES={Total Zones}

PHASE=ILOOP
  CoeffHH     = 0.423546369 * 2
  CoeffIND    = 0.235065256 * 2
  CoeffSER    = 0.158333776 * 2
  CoeffOFFHTR = 0.148286574 * 2
  CoeffRET    = 0.208675310 * 2
  CoeffSG     = 0.225389103 * 2
				  	; adjustent factor reflects change required to make estimated trip generation rates match observed trips

GrwthRate=1.0								; for future year models, replace this 1.0 with the assumed growth rate       

  IF (I<={Internal Zones})
    TOTALSG = ZI.1.SG_RET + ZI.1.SG_HOS + ZI.1.SG_AIR + ZI.1.SG_COL
    OFFHTRET = ZI.1.OFF + ZI.1.HTRET
    A[1]=(ZI.1.HH * CoeffHH) + (ZI.1.IND * CoeffIND) + (ZI.1.RET * CoeffRET) +
       (OFFHTRET * CoeffOFFHTR) + (ZI.1.SER * CoeffSER) + (TOTALSG * CoeffSG)
    P[1]= 0
  ELSE
    A[1]=0
    P[1]= ZI.2.IEEI
  ENDIF
  ENDPHASE

PHASE=ADJUST
  BALANCE A2P=1
  
REPORT A=Y P=Y
ENDPHASE
 

ENDRUN


; Script for program MATRIX in file "C:\projects\winfred\Cube\EE_nonResident_NHB.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_nonResident_NHB.PRN" MSG='NR-NHB Model'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\NHBNR_PA_{year}.DBF",
 FIELDS=Z, NHBNR_P, NHBNR_A
FILEI RECI = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF"


ZONES = {Total Zones}
NHB_PCT = .30 ; 30% of External trips make NHB trips inside the region

RO.Z=RI.Z
RO.NHBNR_P = RI.P1 * NHB_PCT
RO.NHBNR_A = RI.A1 * NHB_PCT
WRITE RECO=1

ENDRUN


; Script for program DISTRIBUTION in file "C:\projects\winfred\Cube\EE_TripDistribution.S"
;;<<Default Template>><<DISTRIBUTION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_TripDistribution.PRN" MSG='IEEI_TripDist'
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\IEEI_{year}.MAT",
 MO=1, NAME=TRIPS, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT"

PAR maxiters=20 maxrmse=10
setpa p[1]=zi.1.p1, a[1]=zi.1.a1  ;Set P and A Fields

; Gamma Function parameters
alpha   =  1.3544
beta    = -4.0016
epsilon =  .14

MW[2]=mi.1.1      ; total travel time

; First replace any 0 times with a very small travel time to avoid
;  failure of the exponentiation calculation.
JLOOP
  IF (MW[2]=0)
    MW[2]=.1
    ENDIF
  ENDJLOOP

;calculate friction factor using the gamma function
mw[3]  = (alpha * (MW[2]^beta) * EXP(epsilon*MW[2]))

;apply the results of gamma formulation
PAF=0
MW[1] = A[1] * MW[3]
ATTRSUM=ROWSUM(1)
IF (ATTRSUM>0) PAF=P[1]/ATTRSUM
MW[1]=PAF * MW[1]


; ========GENERATE FREQUENCY REPORTS BASED ON TIME============
FREQUENCY VALUEMW=1 BASEMW=2, RANGE=0-42,
TITLE='** IEEI Travel Time Frequency **'
ENDRUN


; Script for program MATRIX in file "C:\projects\winfred\Cube\IEEI_TOD.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\IEEI_TOD.PRN" MSG='IEEI TOD'
FILEO MATO[4] = "{SCENARIO_DIR}\Output\IEEI_{year}_NT.MAT",
 MO=34, NAME=IEEI_NT, DEC=D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\IEEI_{year}_PM.MAT",
 MO=33, NAME=IEEI_PM, DEC=D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\IEEI_{year}_MD.MAT",
 MO=32, NAME=IEEI_MD, DEC=D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\IEEI_{year}_AM.MAT",
 MO=31, NAME=IEEI_AM, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\Output\IEEI_{year}.MAT"
ZONES={Total Zones}

;Define arrays of time of day factors
ARRAY IEFct=4
IEFct[1] = 0.03 	;AM IE Factor
IEFct[2] = 0.28   ;MD IE Factor 
IEFct[3] = 0.08   ;PM IE Factor 
IEFct[4] = 0.11   ;NT IE Factor 

ARRAY EIFct=4
EIFct[1] = 0.16 	;AM EI Factor
EIFct[2] = 0.20   ;MD EI Factor 
EIFct[3] = 0.03   ;PM EI Factor 
EIFct[4] = 0.11   ;NT EI Factor 

MW[1]=mi.1.1      ;IEEI Daily Trips
MW[2]=mi.1.1.T    ;IEEI Daily Trips

;  MW[11] through MW[14] are the working tables (four time periods) for IE trips
;  MW[21] through MW[24] are the working tables (four time periods) for EI trips
;  MW[31] through MW[34] are the final output tables (four time periods) for total IEEI trips.

LOOP TOD=1,4                          
  IETable = (10) + TOD
  MW[IETable] = MW[2] * IEFct[TOD]
  
  EITable = (20) + TOD
  MW[EITable] = MW[1] * EIFct[TOD]
  
  TODTable = (30) + TOD
  MW[TODTable] = MW[IETable] + MW[EITable]
ENDLOOP

ENDRUN


; Script for program MATRIX in file "C:\projects\winfred\Cube\EE_TOD.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_TOD.PRN" MSG='EE TOD'
FILEO MATO[4] = "{SCENARIO_DIR}\Output\EE_{year}_NT.MAT",
MO=14, NAME=EE_NT, DEC=1*D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\EE_{year}_PM.MAT",
MO=13, NAME=EE_PM, DEC=1*D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\EE_{year}_MD.MAT",
MO=12, NAME=EE_MD, DEC=1*D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\EE_{year}_AM.MAT",
 MO=11, NAME=EE_AM, DEC=1*D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"


MW[1]=mi.1.1     ;EE Daily Trips

ZONES={Total Zones}

;Define arrays of time of day factors
ARRAY EEFct=4
EEFct[1] = 0.141	;AM IE Factor
EEFct[2] = 0.458	;MD IE Factor
EEFct[3] = 0.154	;PM IE Factor
EEFct[4] = 0.247  ;NT IE Factor




;  MW[11] through MW[14] are the working tables (four time periods) for EE trips

LOOP TOD=1,4                          
  EETable = (10) + TOD
  MW[EETable] = MW[1] * EEFct[TOD]
ENDLOOP
ENDRUN


