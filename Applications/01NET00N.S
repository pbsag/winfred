; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01NET00N.PRN" MSG='INSERT LINK AREA TYPE ON THE NETWORK'
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\ATYPE NETOWRK{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\AREA TYPE.PRN"
FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\PROCESSED.NET"


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
LOOKUP NAME=ATYPE,
 LOOKUP[1]=1, RESULT=2,
 INTERPOLATE=N, LOOKUPI=1, list=y


AT1=ATYPE(1,ZN)


if(CBD=1)
 AT1=1
endif

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
