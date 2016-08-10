; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_3.PRN" MSG='INSERT LINK DATA TO NETWORK'
FILEI LINKI[1] = "{SCENARIO_DIR}\Input\highway.net"
FILEI LINKI[2] = "{SCENARIO_DIR}\Output\CLOSEST.DBF"
FILEO NETO = "{SCENARIO_DIR}\Output\ZONE.NET"

MERGE RECORD=TRUE, LAST=ZN
PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.

   ;# The distance for centroid connectors is the straight-line distance rather 
   ;# than the distance on the file.
   IF(FACTYPE >= 11)   ;# cc are 11 and 12
     DISTANCE = DIST_XY
   ENDIF

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
