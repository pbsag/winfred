; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\Output\Logs\TripDistribution_GravityModel_HBSC.PRN" MSG='Gravity Model - HBSC'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\OP_Hwyskim.mat"
FILEI ZDATI[2] = "{SCENARIO_DIR}\OUTPUT\se_classified_{year}{Alternative}.dbf"
FILEI ZDATI[1] = "{SCENARIO_DIR}\OUTPUT\HH_PROD.DBF"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\Output\HBSC_FFFile.CSV"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT",
 MO=1,NAME=HBSC

  LOOKUP,
   LOOKUPI=1,
   INTERPOLATE=Y, NAME=FF,
    LOOKUP[1]=1,RESULT=2

  ;   output distributed trips by purpose
  PARAMETERS
    ZONES={TOTAL ZONES},MAXITERS=25
    
  ;    setup the working p's and a's
  SETPA P[1]=Zi.1.HBSCP  A[1]=Zi.2.SCHOOL 

  ;  get the los matrix into work matrix 11
  MW[11] = MI.1.Total_Time
  MW[12] = MI.1.Distance


  ;  do gravity models, each followed by a frequency summation
  GRAVITY   PURPOSE=1, LOS=MW[11], FFACTORS=FF
  ;
  FREQUENCY VALUEMW=1,  BASEMW=12,  RANGE=1-11, TITLE='HBSC TRIP LENGTH FREQUENCY'
  FREQUENCY VALUEMW=1,  BASEMW=11,  RANGE=1-24, TITLE='HBSC TRIP TIME LENGTH FREQUENCY'
  ;
  FREQUENCY VALUEMW=1,  BASEMW=11,  RANGE=1-15, TITLE='HBSC TRIP LENGTH FREQUENCY'

ENDRUN
