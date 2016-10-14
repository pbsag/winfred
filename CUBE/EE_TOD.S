; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_TOD.PRN" MSG='EE TOD'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\EE_TOD_RATES.dbf"
FILEO MATO[4] = "{SCENARIO_DIR}\Output\EE_{year}_NT.MAT",
MO=14, NAME=EE_NT, DEC=1*D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\EE_{year}_PM.MAT",
MO=13, NAME=EE_PM, DEC=1*D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\EE_{year}_MD.MAT",
MO=12, NAME=EE_MD, DEC=1*D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\EE_{year}_AM.MAT",
 MO=11, NAME=EE_AM, DEC=1*D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"


ZONES={Total Zones}
LOOKUP LOOKUPI=1,
       NAME=TODFAC,
         LOOKUP[1]=PERIOD, RESULT=SHARE,
         FAIL[1]=0,FAIL[2]=0,FAIL[3]=0,
         LIST=Y    
MW[1]=mi.1.1     ;EE Daily Trips

;  MW[11] through MW[14] are the working tables (four time periods) for EE trips
LOOP TOD=1,4                          
  EETable = (10) + TOD
  MW[EETable] = MW[1] * TODFAC(1,TOD)
ENDLOOP
ENDRUN
