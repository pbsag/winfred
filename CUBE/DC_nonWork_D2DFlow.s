; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\non-work.d2d_flowsPRN" MSG='District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_@PURP@.MAT",
 MO = 1, NAME = @PURP@

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 12, MISSINGZI=M, MISSINGZO=M
ENDRUN
