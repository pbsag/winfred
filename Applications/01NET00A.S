; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK
FILEO NETO = "{SCENARIO_DIR}\WF_{Year}{ALT}1.NET"
FILEI LINKI[2] = "C:\Documents and Settings\svaranasi\Desktop\TEMP\WF_07A.dbf"
FILEI LINKI[1] = "{SCENARIO_DIR}\WF_{Year}{ALT}.NET"

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
CNTSTA=LINKID_TMS

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
