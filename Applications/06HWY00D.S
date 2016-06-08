; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\06HWY00D.PRN" MSG='Congested Skim'
FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT",
MO=1,2,3,4,                                     ; write MW to table 1
NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"

FILEI ZDATI[1] = "{SCENARIO_DIR}\TERMTIME.DBF"
FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN"
FILEI NETI = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"

PHASE=LINKREAD
; Use this phase to obtain initial values from the input network (LI.varname) and compute 
; link values (LW.varname) that can be used in other phases.

     ;If (LI.YEAROPEN=2030) ADDTOGROUP=9 
     LW.TIME=LI.TIME_6
     ;LW.DISTANCE=LI.LENGTH
     C=LI.CAPACITY

   

ENDPHASE


PHASE=ILOOP
; This phase performs a zonal loop (I=1,Zones).  This phase is required and must contain
; at least 1 PATHLOAD statement.  Almost all MATRIX operation are available in this phase
; and the PATHLOAD statement can be used to build and load paths for assignment
                                  ; loop through all production zones
     PATHLOAD PATH = LW.TIME,  PENI=1,;, EXCLUDEGROUP=9,                       ; develop path based on TIME
              MW[1] = PATHTRACE(LW.TIME), NOACCESS=10000,          ; trace/skim the TIME variable
              MW[2]= PATHTRACE(LI.DISTANCE), NOACCESS=0
     MW[1][i]=(0.5*((ZI.1.AREA[i])^0.5)*60)/20     
     IF (ZI.1.AREA[i]<=3.0) 
        MW[1][i]=(0.5*(ZI.1.Area[i]^0.5)*60)/20 ;intra zonal
     ENDIF     
     IF (ZI.1.Area[i]<=0.11) ;intra zonal
        MW[1][i]=100000000
     ENDIF
     
     MW[3]=ZI.1.TERMTIME[i]+ZI.1.TERMTIME[j]
     IF (i>{IZONES})
      JLOOP
        IF (j>{IZONES})
        MW[1]=100000000
        ENDIF
      ENDJLOOP
     ENDIF
     MW[4]=MW[1]+MW[3]
ENDPHASE
 


ENDRUN
