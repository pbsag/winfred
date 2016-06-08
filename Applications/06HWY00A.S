; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\06HWY00A.PRN" MSG='DAILY'
FILEI NETI = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"
FILEI MATI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT"
FILEO NETO = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\06HWY00A.MAT",
MO=1, Name=Sellnk

FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN",
MISSINGLINK=1


PARAMETERS MAXITERS = {ITERS},                 ; maximum number of iterations
           GAP=0.005,
           RMSE=.005
FUNCTION TC[1]=T0 *(1 + 0.84* (V/C) ^ 5.5) ;Freeways
;FUNCTION TC[1]=T0 *(1 + 0.15* (V/C) ^ 4) ;Freeways
FUNCTION TC[2]=T0 *(1 + 0.56* (V/C) ^ 3.6) ;Arterials
FUNCTION TC[3]=T0 *(1 + 0.8* (V/C) ^ 2.5)    ;Locals and Collectors
FUNCTION TC[4]=T0 ;Centroid Connectros

PHASE=LINKREAD
     ;If (LI.YEAROPEN=2030) ADDTOGROUP=9
     T0 =(LI.DISTANCE/LI.POST_SPD)*60
     ;LW.DISTANCE=LI.LENGTH
  ;  C=((LI.TOTAL_CAPA)*0.75)/0.10
     C=((LI.CAPACITY))*{CAPCONFAC}
FACTYPE=LI.FACTYPE
if(FACTYPE=1-2,9,10)
 linkclass=1
endif
if(FACTYPE=3-5)
linkclass=2
endif
if(FACTYPE=6-8)
linkclass=3
endif
if(FACTYPE=11-12)
linkclass=4
endif
  ENDPHASE

Function V=VOL[1]
PHASE=ILOOP                              ; main loop for module
         PATH=TIME, PENI=1, ;, EXCLUDEGROUP=9,                    ; build path based on time  
         ;VOL[1]=MI.1.TotVehODAdj, mw[1]=MI.1.TotVehODAdj, selectlink = (L=3244-3484),    ; load trips from input matrix
         Vol[1]=mw[1],
         mw[1]=MI.1.TotVehOD   
         
ENDPHASE

PROCESS PHASE=ADJUST
; This phase is automatically run after the ILOOP phase.  The volume-delay functions (TC) are
; automatically recomputed in this phase to update the link congested travel times based 
; on the volumes from the ILOOP phase.  User defined link computations (LW.varname) that 
; need to be updated based on the new congested travel times should be coded in this phase.

  PARAMETERS COMBINE=EQUI, RELATIVEGAP=0.0001

ENDPROCESS

PHASE=CONVERGE
  IF (ITERATION < 6) BREAK; Do not even test for Iterations 2-5
  IF (GAP[ITERATION]<GAPCUTOFF & GAP[ITERATION-1]<GAPCUTOFF & GAP[ITERATION-2]<GAPCUTOFF)
     BALANCE = 1
  ENDIF
ENDPHASE


ENDRUN
