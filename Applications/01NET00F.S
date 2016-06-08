; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK
FILEO NETO = "{SCENARIO_DIR}\WF1_{Year}{ALT}.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\WF_{Year}{ALT}.NET"

PROCESS  PHASE=INPUT FILEI=ni.1
;Use this phase to modify data as it is read, such as recoding node numbers.
if (N>167 & N<200)

N=(N+50)
CENTROID=N
endif

ENDPROCESS

PROCESS  PHASE=INPUT FILEI=li.1
if (A>167 & A<200)

A=(A+50)
endif

if (B>167 & B<200)

B=(B+50)
endif
ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.

ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.


ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
