; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonWork_D2DFlow_NHB.PRN" MSG='District - to - District Flows NHB'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\DEST_NHB.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_NHB.MAT",
 MO = 1, NAME = NHB

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 10, MISSINGZI=M, MISSINGZO=M
ENDRUN
