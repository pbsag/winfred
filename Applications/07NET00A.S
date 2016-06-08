; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Links with Counts'
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO LINKO = "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\OUTPUT\BASE\ALL_LINKS.DBF",
INCLUDE= V_6,FEDFUNC, COUNT,A,B,dir, FORMAT=DBF

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
;IF (EXT_COUNT>0) DELETE
IF (COUNT=0) DELETE
IF (FEDFUNC=8) DELETE
ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
