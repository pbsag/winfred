; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\work_d2d_flows.PRN" MSG='HBW District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_HBW.MAT",
 MO = 1, NAME = HBW

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 12, MISSINGZI=M, MISSINGZO=M
ENDRUN
