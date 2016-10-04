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
