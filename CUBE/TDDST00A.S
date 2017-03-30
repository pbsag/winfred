; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\Output\LOGS\HBUTripDistributions.PRN" MSG='HBU Distribution'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\OP_Hwyskim.MAT"
FILEI ZDATI[2] = "{SCENARIO_DIR}\Output\HBU_ATTR.dbf"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Dest_HBU.MAT",
 MO=1,NAME=UNV
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\HBU_PROD.DBF"

    
  ;   output distributed trips by purpose
  PARAMETERS
    ZONES={TOTAL ZONES},MAXITERS=25
    
  ;    setup the working p's and a's
  SETPA P[1]=Zi.1.HBU  A[1]=Zi.2.UNVA

  ;  get the los matrix into work matrix 11
  MW[11] = MI.1.Total_Time
  PAF=0
  MW[1] = A[1] * MW[11]
  ATTRSUM=ROWSUM(1)
  IF (ATTRSUM>0) PAF=P[1]/ATTRSUM
  MW[1]=PAF * MW[1]



 
ENDRUN
