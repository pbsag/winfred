;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\IEEI_TOD.PRN" MSG='IEEI TOD'
FILEO MATO[4] = "{SCENARIO_DIR}\Output\IEEI_{year}_NT.MAT",
 MO=34, NAME=IEEI_NT, DEC=D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\IEEI_{year}_PM.MAT",
 MO=33, NAME=IEEI_PM, DEC=D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\IEEI_{year}_MD.MAT",
 MO=32, NAME=IEEI_MD, DEC=D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\IEEI_{year}_AM.MAT",
 MO=31, NAME=IEEI_AM, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\IEEI_{YEAR}_PA.MAT"
ZONES={Total Zones}

;Define arrays of time of day factors
ARRAY IEFct=4
IEFct[1] = 0.03 	;AM IE Factor
IEFct[2] = 0.28   ;MD IE Factor 
IEFct[3] = 0.08   ;PM IE Factor 
IEFct[4] = 0.11   ;NT IE Factor 

ARRAY EIFct=4
EIFct[1] = 0.16 	;AM EI Factor
EIFct[2] = 0.20   ;MD EI Factor 
EIFct[3] = 0.03   ;PM EI Factor 
EIFct[4] = 0.11   ;NT EI Factor 

MW[1] = mi.1.1 * 2      ;IEEI Daily Attractions
MW[2] = mi.1.1.T * 2    ;IEEI Daily Productions

;  MW[11] through MW[14] are the working tables (four time periods) for IE trips
;  MW[21] through MW[24] are the working tables (four time periods) for EI trips
;  MW[31] through MW[34] are the final output tables (four time periods) for total IEEI trips.

LOOP TOD=1,4                          
  IETable = (10) + TOD
  MW[IETable] = MW[2] * IEFct[TOD]
  
  EITable = (20) + TOD
  MW[EITable] = MW[1] * EIFct[TOD]
  
  TODTable = (30) + TOD
  MW[TODTable] = MW[IETable] + MW[EITable]
ENDLOOP

ENDRUN
