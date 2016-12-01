; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\IEEI_PA.PRN"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\IEEI_{YEAR}_PA.MAT",
    MO=3, NAME=IEEI
FILEI MATI[1] = "{SCENARIO_DIR}\Output\IEEI_{year}.MAT"


MW[1] = mi.1.1
MW[2] = mi.1.1.t
MW[3] = MW[1] + MW[2]

ENDRUN
