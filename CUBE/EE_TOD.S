; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_TOD.PRN" MSG='EE TOD'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\EE_TOD_RATES.dbf"
FILEO MATO[4] = "{SCENARIO_DIR}\Output\EE_{year}_NT.MAT",
MO=14,18, NAME=EE_NT_AUTO,EE_NT_TRK, DEC=1*D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\EE_{year}_PM.MAT",
MO=13,17, NAME=EE_PM_AUTO,EE_PM_TRK, DEC=1*D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\EE_{year}_MD.MAT",
MO=12,16, NAME=EE_MD_AUTO,EE_MD_TRK, DEC=1*D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\EE_{year}_AM.MAT",
 MO=11,15, NAME=EE_AM_AUTO,EE_AM_TRK, DEC=1*D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"


ZONES={Total Zones}
LOOKUP LOOKUPI=1,
       NAME=TODFAC,
         LOOKUP[1]=PERIOD, RESULT=SHARE,
         FAIL[1]=0,FAIL[2]=0,FAIL[3]=0,
         LIST=Y    
MW[1]=mi.1.1     ;EE Daily Auto Trips

;  MW[11] through MW[14] are the working tables (four time periods) for EE trips
LOOP TOD=1,4                          
  EETable = (10) + TOD
  MW[EETable] = MW[1] * TODFAC(1,TOD)
ENDLOOP

 
MW[2]=mi.1.2     ;EE Daily TRK Trips

;  MW[15] through MW[18] are the working tables (four time periods) for EE trips
LOOP TOD=1,4                          
  EETable = (14) + TOD
  MW[EETable] = MW[2] * TODFAC(1,TOD)
ENDLOOP
ENDRUN
