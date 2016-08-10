; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='EE TOD'
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
