; Script for program NETWORK in file "C:\projects\rvtpo\CUBE\FBNET00A.S"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\output\Logs\export_to_geodatabase.prn" MSG='Export NET to Geodatabase'
FILEO NETO = "{SCENARIO_DIR}\output\output.gdb\loaded_network"
FILEI LINKI[1] = "{CATALOG_DIR}\Maps\empty.gdb\HWNetwork"
FILEI LINKI[2] = "{SCENARIO_DIR}\OUTPUT\LOADED_{Year}{Alternative}.NET"
;FILEI GEOMI[1] = "{CATALOG_DIR}\MasterNetwork\cubeShapeFile_2012A.shp"
 
ENDRUN


