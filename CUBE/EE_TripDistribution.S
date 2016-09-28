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
