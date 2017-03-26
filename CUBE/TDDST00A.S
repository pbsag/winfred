; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\Output\LOGS\HBUTripDistributions.PRN" MSG='Gravity Model - HBU'
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\Output\HBU_FFFile.csv"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\OP_Hwyskim.MAT"
FILEI ZDATI[2] = "{SCENARIO_DIR}\Output\HBU_ATTR.dbf"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Dest_HBU.MAT",
 MO=1,NAME=UNV
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\HBU_PROD.DBF"

  LOOKUP,
   LOOKUPI=1,
   INTERPOLATE=Y, NAME=FF,
    LOOKUP[1]=1,RESULT=2
    
  ;   output distributed trips by purpose
  PARAMETERS
    ZONES={TOTAL ZONES},MAXITERS=25
    
  ;    setup the working p's and a's
  SETPA P[1]=Zi.1.HBU  A[1]=Zi.2.UNVA

  ;  get the los matrix into work matrix 11
  MW[11] = MI.1.Total_Time
  MW[12] = MI.1.Distance


  ;  do gravity models, each followed by a frequency summation
  GRAVITY   PURPOSE=1, LOS=MW[11], FFACTORS=FF
  ;

; The DISTRIBUTION module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  The module has a built in GRAVITY statement for implementing this commonly
; used distribution method.  User defined distribution process can also be defined.

ENDRUN
