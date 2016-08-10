; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX
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
