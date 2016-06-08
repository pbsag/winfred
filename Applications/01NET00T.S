; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00B.PRN" MSG='Consolidate into 3 Area Types'
FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\ATYPE NETOWRK{Year}{Alternative}.NET"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\Final_AT_{Year}{Alternative}.NET"


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
; Use this phase for combining and reporting of working variables.
If (AT1=1)
    LUD=3
Elseif (AT1=2,3,4)
    LUD=2
Else
    LUD=1
Endif

ENDPROCESS

ENDRUN
