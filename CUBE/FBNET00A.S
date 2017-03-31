;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\output\Logs\FBNET00A.prn" MSG='Export NET to Geodatabase'
FILEI LINKI[1] = "{CATALOG_DIR}\Maps\WinFredGeoDatabase.mdb\MasterNetwork"
FILEO NETO = "{CATALOG_DIR}\maps\WinFredGeoDatabase.mdb\loaded_{Year}{Alternative}"
FILEI LINKI[2] = "{SCENARIO_DIR}\OUTPUT\LOADED_{Year}{Alternative}.NET"
 
ENDRUN
