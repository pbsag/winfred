; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_4.PRN" MSG='ADD LAND USE DATA TO ZONES'
FILEI NODEI[2] = "{SCENARIO_DIR}\Input\se.dbf"
FILEO NETO = "{SCENARIO_DIR}\Output\merge zone.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\ZONE.NET"

merge record=true
PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
_AX=A.X
_BX=B.X
_AY=A.Y
_BY=B.Y
;Find the mid point of each link

;add directionl notations to each link
; already done earlier

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
