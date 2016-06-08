; Script for program NETWORK in file "C:\1Projects\VDOT\Win-Fred-Model-Jan0709\WinFred-Model\APPLICATIONS\01NET00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Compute SpeedCap Class'


; example of use: v=NEWSPDCAPTABLE(1,25)
; look for 25 in the SPDCAPCLS field and returns the CAPACITY value


FILEI LINKI[1] = "{SCENARIO_DIR}\WF_{Year}{ALT}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\SPDCAPCLASS.dbf"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}A.NET"


;Use this phase to modify data as it is read, such as recoding node numbers.
      ; MO=1,2,3,4,                                     ; write MW to table 1
       ;NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"





PROCESS  PHASE=LINKMERGE  

;Distance Checks
;DISTANCE=LENGTH
DISTANCE =(1/1609)*SQRT((a.X-b.X)^2+(a.Y-b.Y)^2)
IF (FACTYPE=12) DISTANCE=0.01

;SPDCAPCLS COMPUTATION

IF (FACTYPE=1&LUD=1) SPDCAPCLS=11

IF (FACTYPE=1&LUD=2) SPDCAPCLS=12

IF (FACTYPE=1&LUD=3) SPDCAPCLS=13

IF (FACTYPE=1&LUD=2) SPDCAPCLS=21

IF (FACTYPE=2&LUD=1) SPDCAPCLS=21

IF (FACTYPE=2&LUD=2) SPDCAPCLS=22

IF (FACTYPE=2&LUD=3) SPDCAPCLS=23

IF (FACTYPE=3&LUD=1) SPDCAPCLS=31

IF (FACTYPE=3&LUD=2) SPDCAPCLS=32

IF (FACTYPE=3&LUD=3) SPDCAPCLS=33

IF (FACTYPE=4&LUD=1) SPDCAPCLS=41

IF (FACTYPE=4&LUD=2) SPDCAPCLS=42

IF (FACTYPE=4&LUD=3) SPDCAPCLS=43

IF (FACTYPE=5&LUD=1) SPDCAPCLS=51

IF (FACTYPE=5&LUD=2) SPDCAPCLS=52

IF (FACTYPE=5&LUD=3) SPDCAPCLS=53

IF (FACTYPE=6&LUD=1) SPDCAPCLS=61

IF (FACTYPE=6&LUD=2) SPDCAPCLS=62
IF (FACTYPE=6&LUD=3) SPDCAPCLS=63

IF (FACTYPE=7&LUD=1) SPDCAPCLS=71

IF (FACTYPE=7&LUD=2) SPDCAPCLS=72

IF (FACTYPE=7&LUD=3) SPDCAPCLS=73

IF (FACTYPE=8&LUD=1) SPDCAPCLS=81

IF (FACTYPE=8&LUD=2) SPDCAPCLS=82

IF (FACTYPE=8&LUD=3) SPDCAPCLS=83

IF (FACTYPE=9&LUD=1) SPDCAPCLS=91

IF (FACTYPE=9&LUD=2) SPDCAPCLS=92

IF (FACTYPE=9&LUD=3) SPDCAPCLS=93

IF (FACTYPE=10&LUD=1) SPDCAPCLS=101

IF (FACTYPE=10&LUD=2) SPDCAPCLS=102

IF (FACTYPE=10&LUD=3) SPDCAPCLS=103

IF (FACTYPE=10&LUD=1) SPDCAPCLS=101

IF (FACTYPE=10&LUD=2) SPDCAPCLS=102

IF (FACTYPE=10&LUD=3) SPDCAPCLS=103

IF (FACTYPE=11&LUD=1) SPDCAPCLS=111

IF (FACTYPE=11&LUD=2) SPDCAPCLS=112

IF (FACTYPE=11&LUD=3) SPDCAPCLS=113

IF (FACTYPE=12&LUD=1) SPDCAPCLS=121

IF (FACTYPE=12&LUD=2) SPDCAPCLS=122

IF (FACTYPE=12&LUD=3) SPDCAPCLS=123

ENDPROCESS





ENDRUN


; Script for program NETWORK in file "C:\1Projects\VDOT\Win-Fred-Model-Jan0709\WinFred-Model\Applications\01NET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Capacity and Speed Estimation'

LOOKUP LOOKUPI=1,
       NAME=NEWSPDCAPTABLE,
         LOOKUP[1]=SPDCAPCLS, RESULT=CAPACITY,
         LOOKUP[2]=SPDCAPCLS, RESULT=speed,
       FAIL[3]=0
; example of use: v=NEWSPDCAPTABLE(1,25)
; look for 25 in the SPDCAPCLS field and returns the CAPACITY value


FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}A.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\NEWSPD-CAP-TABLE.dbf"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"


;Use this phase to modify data as it is read, such as recoding node numbers.
      ; MO=1,2,3,4,                                     ; write MW to table 1
       ;NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"





PROCESS  PHASE=LINKMERGE  
speed_old=post_spd

if (spdcapcls =11-23, 91-110) linkclass=1
if (spdcapcls =31-43) linkclass=2
if (spdcapcls =51-83,111-123) linkclass=3
; Use this phase to make computations and selections of any data on the LINKI files.

  ; If (LI.YEAROPEN=2030) ADDTOGROUP=9 
    ; LW.TIME=(LI.LENGTH/LI.POSTEDSPD)*60
   ;  LW.DISTANCE=LI.LENGTH
    ; C=LI.TOTAL_CAPA
CAPACITY=NEWSPDCAPTABLE(1,SPDCAPCLS)*LANES
post_spd=NEWSPDCAPTABLE(2,SPDCAPCLS)

ENDPROCESS




ENDRUN


; Script for program HIGHWAY in file "C:\1Projects\VDOT\Win-Fred-Model-Jan0709\WinFred-Model\Applications\01HWY00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\01HWY00A.PRN" MSG='Highway Skims'
FILEI ZDATI[1] = "{SCENARIO_DIR}\TERMTIME.DBF"
FILEI NETI = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\TURNPEN{Year}.PEN"

FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\01HWY{Year}A.MAT",
MO=1,2,3,4,                                     ; write MW to table 1
NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"

PHASE=LINKREAD
; Use this phase to obtain initial values from the input network (LI.varname) and compute 
; link values (LW.varname) that can be used in other phases.

     ;If (LI.YEAROPEN=2030) ADDTOGROUP=9 
     LW.TIME=(LI.DISTANCE/LI.POST_SPD)*60
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
     IF (i>167)
      JLOOP
        IF (j>167)
        MW[1]=100000000
        ENDIF
      ENDJLOOP
     ENDIF
     MW[4]=MW[1]+MW[3]
ENDPHASE


ENDRUN


