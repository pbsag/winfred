; Script for program GENERATION in file "C:\Projects\winfred\Cube\CV_TripGen.S"
;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\CV_TripGen.PRN" MSG='CV Trip Generation'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\CVRATES.CSV"
FILEO PAO[1] = "{SCENARIO_DIR}\Output\CV_PA_{year}.DBF",
FORM=10.3, DBF=T, LIST=Z, P[1], P[2], P[3], A[1], A[2], A[3]
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\se.dbf"

ZONES={Internal Zones}

LOOKUP, LOOKUPI=1, 
	NAME=CVRates,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
	INTERPOLATE=N, FAIL[1]=0, FAIL[2]=0, FAIL[3]=0, LIST=Y

PHASE=ILOOP

	P[1]=	(IND*CVRates(1,1))+((RET + SG_RET)*CVRates(1,2))+(HTRET*CVRates(1,3))+(OFF*CVRates(1,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(1,5))+(HH*CVRates(1,6))
  
	P[2]=	(IND*CVRates(2,1))+((RET + SG_RET)*CVRates(2,2))+(HTRET*CVRates(2,3))+(OFF*CVRates(2,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(2,5))+(HH*CVRates(2,6))
	P[3]= (IND*CVRates(3,1))+((RET + SG_RET)*CVRates(3,2))+(HTRET*CVRates(3,3))+(OFF*CVRates(3,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(3,5))+(HH*CVRates(3,6))
  
	A[1]=P[1]
  A[2]=P[2]
  A[3]=P[3]
  
ENDPHASE

PHASE=ADJUST
  BALANCE NHB=1
ENDPHASE

ENDRUN


; Script for program DISTRIBUTION in file "C:\Projects\winfred\Cube\CV_TripDistribution.S"
;;<<Default Template>><<DISTRIBUTION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\CV_TripDistribution.PRN" MSG='CV Trip Distribution'
FILEO MATO[1] = "{SCENARIO_DIR}\Output\CV_{Year}.MAT",
  MO=1-3, NAME=FourTire, SixTire, Combo, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT"
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\CV_PA_{year}.DBF"


PAR maxiters=20 maxrmse=10

setpa  P[1]=ZI.1.P1, P[2]=ZI.1.P2, P[3]=ZI.1.P3,		; Set P and A Fields 1-3 = 4-tire, 6-tire, and combo
			A[1]=ZI.1.A1, A[2]=ZI.1.A2, A[3]=ZI.1.A3

; Estmated Gamma Function parameters,  Define array of coefficients and poplate.
	ARRAY alpha=3
	ARRAY beta=3
	ARRAY epsilon=3

; Coefficients are set the the default NCDOT Small Area Travel Demand Model Procedures Manual
;     for all three CV types.  Further testing and calibration may be needed.
  alpha[1] = 4.6750
	beta[1] = 0.2916
	epsilon[1] = 0.1390

	alpha[2] = 4.6750
	beta[2] = 0.2916
	epsilon[2] = 0.1390

	alpha[3] = 4.6750
	beta[3] = 0.2916
	epsilon[3] = 2.4000

MW[10]=mi.1.1      ; total travel time

; First replace any 0 times with a very small travel time to avoid
;  failure of the exponentiation calculation.
JLOOP
  IF (MW[10]=0)
    MW[10]=0.0000001
    ENDIF
  ENDJLOOP

;calculate friction factor using the gamma function
LOOP CVType=1,3
  CVIDX=10+CVType
	MW[CVIDX] = alpha[CVType] * (MW[10]^beta[CVType]) * EXP(epsilon[CVType]*MW[10])
	ENDLOOP  

;apply the results of gamma formulation
LOOP PURP= 1, 3
  CVIDX=10+PURP
	PAF=0
	MW[PURP] = A[PURP] * MW[CVIDX]
	ATTRSUM=ROWSUM(PURP)
	IF (ATTRSUM>0) PAF=P[PURP]/ATTRSUM
	MW[PURP]=PAF * MW[PURP]
ENDLOOP

; ========GENERATE FREQUENCY REPORTS BASED ON TIME============
FREQUENCY VALUEMW=1 BASEMW=10, RANGE=0-42,
TITLE='** CV 4-Tire Travel Time Frequency **'

FREQUENCY VALUEMW=2 BASEMW=10, RANGE=0-42,
TITLE='** SUT 6-Tire Travel Time Frequency **'

FREQUENCY VALUEMW=3 BASEMW=10, RANGE=0-42,
TITLE='** MUT Combo Travel Time Frequency **'

ENDRUN


; Script for program MATRIX in file "C:\Projects\winfred\Cube\CV_TimeOfDay.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\CV_TimeOfDay.PRN" MSG='CV TOD Distribution'
FILEO MATO[4] = "{SCENARIO_DIR}\Output\CV_{year}_NT.MAT",
 MO=41-43, NAME=CV_NT, SUT_NT, MUT_NT, DEC=D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\CV_{year}_PM.MAT",
 MO=31-33, NAME=CV_PM, SUT_PM, MUT_PM, DEC=D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\CV_{year}_MD.MAT",
 MO=21-23, NAME=CV_MD, SUT_MD, MUT_MD, DEC=D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\CV_{Year}_AM.MAT",
 MO=11-13, NAME=CV_AM, SUT_AM, MUT_AM, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\Output\CV_{Year}.MAT"

ZONES={Total Zones}

;Define array of time of day factors
;Note that time of day factors for CV trips are the same for PA as AP trips.
;  So rather than apply a PA TOD and an AP TOD and then recombining the table
;  by time period we can simply apply double the PA (or AP)TOD rate.

ARRAY TODFct=4
TODFct[1] = 0.0458 * 2 	;AM Factor
TODFct[2] = 0.1652 * 2  ;MD Factor 
TODFct[3] = 0.1634 * 2  ;PM Factor 
TODFct[4] = 0.1256 * 2  ;NT Factor 

MW[1]=mi.1.1      ;CV  Daily Trips
MW[2]=mi.1.2      ;SUT Daily Trips
MW[3]=mi.1.3      ;MUT Daily Trips

LOOP TOD=1,4                              
  LOOP CVType=1,3 
     TODTable = (10*TOD)+ CVType
    MW[TODTable] = MW[CVType] * TODFct[TOD]
  ENDLOOP
ENDLOOP
ENDRUN


; Script for program MATRIX in file "C:\Projects\winfred\Cube\CV_TLFD.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\CV_TLFD.PRN" MSG='Trip Length Frequency'
FILEO RECO[3] = "{SCENARIO_DIR}\OUTPUT\TLFD_MUT.DBF",
FIELDS= HIGH,MID,MLOW,MUT_TRIPS(16.8)
FILEO RECO[2] = "{SCENARIO_DIR}\OUTPUT\TLFD_SUT.DBF",
FIELDS= HIGH,MID,LOW,SUT_TRIPS(16.8)
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\TLFD_CV.DBF",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\CV_{Year}.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\CV_TLF_Data.PRN"

             MW[1]=MI.1.1
             MW[2]=MI.1.2
             MW[3]=MI.1.3
             MW[4]=MI.2.Time
             gps=40-1
             Array trips=40, sut_trips = 40, mut_trips =40           

             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=1 RANGE=0-100-1 

             ; SUT
              JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             SUT_trips[group]=SUT_trips[group]+mw[2]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.SUT_TRIPS=SUT_trips[group]
                write reco=2
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.SUT_TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=2 RANGE=0-100-1 
             
              ; MUT
              JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             MUT_trips[group]=MUT_trips[group]+mw[3]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.MUT_TRIPS=MUT_trips[group]
                write reco=3
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.MUT_TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=3 RANGE=0-100-1             
            
ENDRUN


