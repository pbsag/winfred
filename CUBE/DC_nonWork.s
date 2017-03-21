; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonWork_@PURP@.PRN" MSG='Apply Destination Choice Model'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\@MCLS_MAT@_MCLS.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\op_Hwyskim.MAT"
FILEI ZDATI[1] = "{SCENARIO_DIR}\OUTPUT\se_classified_{year}{Alternative}.dbf"
FILEI ZDATI[2] = "{SCENARIO_DIR}\OUTPUT\HH_PROD.DBF"
FILEI ZDATI[3] = "{SCENARIO_DIR}\Output\NHBNR_PA_{year}.DBF"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\DESTCHOICE_PARAMETERS.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\DESTCHOICE_DEBUG.RPT"
FILEO PRINTO[2] = "{SCENARIO_DIR}\OUTPUT\DESTCHOICE_SUMMARY.TXT"
FILEO PRINTO[3] = "{SCENARIO_DIR}\OUTPUT\@PURP@@PERIOD@_Zonal_Trips.csv"


ENDRUN
