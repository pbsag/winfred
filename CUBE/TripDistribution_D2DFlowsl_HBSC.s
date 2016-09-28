; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\TripDistribution_D2DFlowsl_HBSC.PRN" MSG='HBSC District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_HBSC.MAT",
 MO = 1, NAME = HBSC

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 12, MISSINGZI=M, MISSINGZO=M
ENDRUN
