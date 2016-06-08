; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\06HWY00C.PRN" MSG='PM ASSIGNMENT'
FILEI NETI = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"
FILEI MATI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00C.MAT"
FILEO NETO = "{CATALOG_DIR}\output\{Scenario_FullName}\PMLOADED_{Year}.NET"
FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN",
MISSINGLINK=1


PARAMETERS MAXITERS ={ITERS},                 ; maximum number of iterations
           GAP=0.01
FUNCTION TC[1]=T0 *(1 + 0.15* (V/C) ^ 4)

PHASE=LINKREAD
     ;IF (LI.YEAROPEN=2030) ADDTOGROUP=9
     T0 =(LI.DISTANCE/LI.POST_SPD)*60
     ;LW.DISTANCE=LI.LENGTH
    ; C=(LI.TOTAL_CAPA)*0.75
     C=(LI.CAPACITY)
  ENDPHASE
  
Function V=VOL[1]
PHASE=ILOOP                              ; main loop for module
         PATH=TIME, PENI=1, ;, EXCLUDEGROUP=9,                  ; build path based on time  
        ; VOL[1]=MI.1.TotPMVeh, mw[1]=MI.1.TotPMVeh, selectlink= (L=192-2059),          ; load trips from input matrix
         Vol[1]=mw[1],
         mw[1]=MI.1.TotPMVeh
ENDPHASE


ENDRUN
