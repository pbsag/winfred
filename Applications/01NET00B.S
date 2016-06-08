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
