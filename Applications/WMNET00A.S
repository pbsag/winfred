; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\WMNET00.PRN"
FILEI NODEI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\PandA.dbf"
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\LU.prn"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\Loaded",
EXCLUDE =ZN, TIME, V1T_6, V_6, VC_6, CSPD_6, VDT_6, VHT_6, V1_6, VT_6,ZONE,COUNT
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\CONGESTION_PARAMETERS.dbf"




LOOKUP LOOKUPI=1,
       NAME=LOS,
         LOOKUP[1]=ID, RESULT=FRESEV,
         LOOKUP[2]=ID, RESULT=FRESOM,
         LOOKUP[3]=ID, RESULT=OTHSEV,
         LOOKUP[4]=ID, RESULT=OTHSOM,
       FAIL[3]=0


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.
if(n=170-217) DELETE
if(n=111-135 || n=137-162 || n=164-167) JURIS='Winchester'
if(n=1-110 || n=136 || n=163 || n=168-169) JURIS='Frederick'
if(n=218-249) JURIS = 'External'


_pop=_pop+pop
_hh=_hh+households

log prefix=node var=_pop,_hh

if(n={Total zones}) print list="1",_pop,_hh, printo=1

ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.



CZONE=li.1.ZN
FFTIME=(LI.1.DISTANCE/LI.1.POST_SPD)*60
Volume = li.1.V_6
C_TIME = li.1.TIME_6
VCAP_RATIO = li.1.VC_6
C_SPEED = li.1.CSPD_6
VMT = ROUND(VT_6)*Distance
VHT = li.1.VHT_6
ONE_WAY_VOL = li.1.V_6
TWO_WAY_VOL = li.1.VT_6

if(a<b) TWO_WAY_CNT=li.1.COUNT
if(TWO_WAY_CNT>0)VC_RATIO=TWO_WAY_VOL/TWO_WAY_CNT


SCREEN=li.1.SCRNLN_CODE



;*****************************************************************************************************
;                 Determine congestion level on each link based on Volume to Capacity ratio 
;*****************************************************************************************************

 IF (FACTYPE=1-2)
  IF(VCAP_RATIO<LOS(2,1)) VOL_CAP='Free'
  IF(VCAP_RATIO>=LOS(2,1) && VCAP_RATIO<LOS(1,1)) VOL_CAP='Moderate'
  IF(VCAP_RATIO>=LOS(1,1)) VOL_CAP='Severe'
 ENDIF

 IF (FACTYPE>2)
  IF(VCAP_RATIO<LOS(4,1)) VOL_CAP='Free'
  IF(VCAP_RATIO>=LOS(4,1) && VCAP_RATIO<LOS(3,1)) VOL_CAP='Moderate'
  IF(VCAP_RATIO>=LOS(3,1)) VOL_CAP='Severe'
 ENDIF

;*********************************************************************************************************
;Determine LOS for screenline locations and locations with high, medium and low Volume to Capacity ratios
;*********************************************************************************************************

IF(SCREEN>0) ;=16-39,78-81,54,354,41,104,372,41-53,351,243,54-64,354,361,17,71,62,102,42,372,60)
 SCRNCHK=1
  IF (FACTYPE=1-2)
    IF(VCAP_RATIO<LOS(2,1)) SCRN_VC='Free'
    IF(VCAP_RATIO>=LOS(2,1) && VCAP_RATIO<LOS(1,1)) SCRN_VC='Moderate'
    IF(VCAP_RATIO>=LOS(1,1)) SCRN_VC='Severe'
  ENDIF

  IF (FACTYPE>2)
   IF(VCAP_RATIO<LOS(4,1)) SCRN_VC='Free'
  IF(VCAP_RATIO>=LOS(4,1) && VCAP_RATIO<LOS(3,1)) SCRN_VC='Moderate'
   IF(VCAP_RATIO>=LOS(3,1)) SCRN_VC='Severe'
  ENDIF

ENDIF

;*******************************************************************************************************
                           ; Give names to Facility Types for reporting purposes
;********************************************************************************************************

if(factype=1) FACILITY='Interstate'
if(factype=2) FACILITY='Minor Freeway'
if(factype=3) FACILITY='Principal Arterial'     
if(factype=4) FACILITY='Major Arterial'
if(factype=5) FACILITY='Minor Arterial'
if(factype=6) FACILITY='Major Collector'
if(factype=7) FACILITY='Minor Collector'
if(factype=8) FACILITY='Local'
if(factype=9) FACILITY='High Speed Ramp'
if(factype=10) FACILITY='Low Speed Ramp'
if(factype=11) FACILITY='Centroid Conn'
if(factype=12) FACILITY='External Stn'


;********************************************************************************************************
                                             ; Give names for Area Type Codes 
;********************************************************************************************************

if(LUD=1) AREA_TYPE='Rural'
if(LUD=2) AREA_TYPE='Urban'
if(LUD=3) AREA_TYPE='CBD'

if(CZONE=1-110 || CZONE=136 || CZONE=163 || CZONE=168-169) JURIS='Frederick Cnty'
if(CZONE=111-135 || CZONE=137-162 || CZONE=164-167) JURIS='Winchester City'


if(CZONE=1-110 || CZONE=136 || CZONE=163 || CZONE>167) JCODE=2   ; County
if(CZONE=111-135 || CZONE=137-162 || CZONE=164-167) JCODE=1    ; City



ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN
