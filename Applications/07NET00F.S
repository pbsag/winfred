; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="C:\MODELS\VDOT\WIN-FRED-MODEL-FEB0809\WINFRED-MODEL\APPLICATIONS\07NET00D.PRN" MSG='Screenline Analysis'
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEI LINKI[2] = "{CATALOG_DIR}\Calibration Constants\screen.dbf"
FILEO LINKO = "C:\MODELS\VDOT\WIN-FRED-MODEL-FEB0809\WINFRED-MODEL\APPLICATIONS\07NET00B.DBF",
INCLUDE=A,B,COUNT,VT_6,SCLIN
FILEO NETO = "C:\MODELS\VDOT\WIN-FRED-MODEL-FEB0809\WINFRED-MODEL\APPLICATIONS\07NET00B.NET"
;ID is a sequential unique ID for the records
;SCLIN is the screenline number
;LINKID is the ID to find on the link




PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.

ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.

SCLIN=SCLIN
IF(SCLIN=0) DELETE
IF (COUNT=0) DELETE

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS
ENDRUN
