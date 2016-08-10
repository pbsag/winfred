; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_6.PRN" MSG='INSERT LINK AREA TYPE ON THE NETWORK'
FILEO LINKO = "{SCENARIO_DIR}\Output\link_atype{Year}{Alternative}.DBF",
 FORMAT = DBF, 
  INCLUDE = A, B, DISTANCE, FACTYPE, LANES, POST_SPD, ATYPE
FILEO NETO = "{SCENARIO_DIR}\Output\ATYPE NETWORK{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\Output\AREA TYPE.PRN"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\PROCESSED.NET"


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE
; Use this phase to make computations and selections of any data on the LINKI files.
LOOKUP NAME=ATYPE1,
 LOOKUP[1]=1, RESULT=2,
 INTERPOLATE=N, LOOKUPI=1

ATYPE=ATYPE1(1,LI.1.ZN)


ENDPROCESS


PROCESS  PHASE=SUMMARY
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
