; Script for program MATRIX in file "E:\VDOT\Cville_Winchester_Reporting\Junk\WINFRED-MODEL\APPLICATIONS\WMMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\WMMAT00A.PRN" MSG='Give better names to Trip P and A data'
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT",
Z=#1,HBWP=#2,HBOP=#3,NHBP=#4,HBWA=#5,HBOA=#6,NHBA=#7

FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\PandA.dbf",
FIELDS=Z,N,HBW_P,HBO_P,NHB_P,HBW_A,HBO_A,NHB_A

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.


zones={Total Zones}

RO.HBW_P=zi.1.HBWP
RO.HBO_P=zi.1.HBOP
RO.NHB_P=zi.1.NHBP
RO.HBW_A=zi.1.HBWA
RO.HBO_A=zi.1.HBOA
RO.NHB_A=zi.1.NHBA

N=Z

WRITE RECO=1

ENDRUN


; Script for program NETWORK in file "E:\VDOT\Cville_Winchester_Reporting\Junk\WINFRED-MODEL\APPLICATIONS\WMNET00A.S"
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
if(n=168-217) DELETE
if(n=111-167) JURIS='Winchester'
if(n=1-110) JURIS='Frederick'
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

if(CZONE=1-110 || CZONE>167) JURIS='Frederick Cnty'
if(CZONE=111-167) JURIS='Winchester City'




if(CZONE=1-110|| CZONE>167) JCODE=2   ; County
if(CZONE=111-167) JCODE=1    ; City



ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program MATRIX in file "E:\VDOT\Cville_Winchester_Reporting\Junk\WINFRED-MODEL\APPLICATIONS\WMMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\WMMAT00C.PRN" MSG='Consolidata distribution data for reports'
FILEI MATI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT"
FILEI MATI[3] = "{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\LU.prn",
z=#1,pop=#2,hh=#3

FILEO RECO[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\TPCP.DBF",
 FIELDS=VEHTRIPS,PERTRIPS

FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\TLD.DBF",
 FIELDS = TIME, WORK, OTHER, NHB, TOTAL 


; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

mw[1]=mi.1.1 ; HBW
mw[2]=mi.1.2 ; HBS
mw[3]=mi.1.3 ; HBO


mw[10]=mi.1.4 ; TOTAL person
mw[20]=mi.3.1  ; Vehicle Trip Table

mw[11]=mi.2.4 ; TIME


_TRIPS=rowsum(10)   ; person
_trips1=rowsum(20)  ;vehicle

trips=trips+_trips  ; person
trips1=trips1+_trips1  ; vehicle

log prefix=per var=trips
log prefix=veh var=trips1

pop=@node._pop@
;pop=zi.1.pop

vehtrips=trips1/pop
pertrips=trips/pop

if(i=lastzone)write reco=2


array tl1=60,tl2=60,tl3=60,tl10=60

jloop

group = min(max(round(mw[11]),1),60)

tl1[group]=tl1[group]+mw[1]
tl2[group]=tl2[group]+mw[2]
tl3[group]=tl3[group]+mw[3]
tl10[group]=tl10[group]+mw[10]


endjloop

if (i=zones)

  loop group=1,60
   
   ro.TIME=group
   ro.WORK=tl1[group]
   ro.OTHER=tl2[group]
   ro.NHB=tl3[group]
   
   ro.TOTAL=tl10[group]

   write reco=1

  endloop

endif

ENDRUN


; Script for program MATRIX in file "E:\VDOT\Cville_Winchester_Reporting\Junk\WINFRED-MODEL\APPLICATIONS\WMMAT00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\WMMAT00D.PRN"
FILEI MATI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\Model_Area_Trip_Chracterstics.DBF",
FIELDS=purpose,time,distance,code



; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.


zones={Total Zones}

;For Harrisonburg Region

   mw[1]=mi.1.1                          ;HBW Person Trips
   mw[2]=mi.1.2                          ;HBSch Person Trips
   mw[3]=mi.1.3                          ;HBO Person Trips

   mw[4]=mi.1.4                            ;total
   mw[9]=mi.2.4                          ;Uncongested Times with Terminal Times
   mw[10]=mi.2.2                          ;Uncongested Distances with Terminal Distances

array time=4, dist=4, trips=4
array cnty_time=4, cnty_dist=4, cnty_trips=4
array city_time=4, city_dist=4, city_trips=4


;**************************************************************************************************
;                                          Frederick County w/o City
;**************************************************************************************************
if(z<111)

loop iter=1,4
   mw[13]=mw[iter]*mw[9]                  ;Time calculation
   mw[14]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   city_time[iter]=rowsum(13)+city_time[iter]
   city_dist[iter]=rowsum(14)+city_dist[iter]
   city_trips[iter]=rowsum(iter)+city_trips[iter]
elseif (i=110)
   city_time[4]=city_time[1]+city_time[2]+city_time[3]
   city_dist[4]=city_dist[1]+city_dist[2]+city_dist[3]
   city_trips[4]=city_trips[1]+city_trips[2]+city_trips[3]
endif

if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if(i=110)
    ro.purpose=iters
    ro.time=city_time[iter]/city_trips[iter]
    ro.distance=city_dist[iter]/city_trips[iter]
    code=1
    write reco=1 ; 2
endif

endloop

endif


;**************************************************************************************************
;                                          Winchester City
;**************************************************************************************************

if(z=111-167)

loop iter=1,4
   mw[13]=mw[iter]*mw[9]                  ;Time calculation
   mw[14]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   cnty_time[iter]=rowsum(13)+cnty_time[iter]
   cnty_dist[iter]=rowsum(14)+cnty_dist[iter]
   cnty_trips[iter]=rowsum(iter)+cnty_trips[iter]
elseif (i=167)
   cnty_time[4]=cnty_time[1]+cnty_time[2]+cnty_time[3]
   cnty_dist[4]=cnty_dist[1]+cnty_dist[2]+cnty_dist[3]
   cnty_trips[4]=cnty_trips[1]+cnty_trips[2]+cnty_trips[3]
endif

if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if(i=167)
    ro.purpose=iters
    ro.time=cnty_time[iter]/cnty_trips[iter]
    ro.distance=cnty_dist[iter]/cnty_trips[iter]
    code=2
    write reco=1  ;3
endif

endloop

endif



;**************************************************************************************************
;                                          Model Region
;**************************************************************************************************

loop iter=1,4
   mw[11]=mw[iter]*mw[9]                  ;Time calculation
   mw[12]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   time[iter]=rowsum(11)+time[iter]
   dist[iter]=rowsum(12)+dist[iter]
   trips[iter]=rowsum(iter)+trips[iter]
elseif (i=zones)
   time[4]=time[1]+time[2]+time[3]
   dist[4]=dist[1]+dist[2]+dist[3]
   trips[4]=trips[1]+trips[2]+trips[3]
endif


if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if (i=zones)
    ro.purpose=iters
    ro.time=time[iter]/trips[iter]
    ro.distance=dist[iter]/trips[iter]
    code=3
    write reco=1
endif

endloop


;***************************************************************************************
;***************************************************************************************



ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


if({Calibration Run}=1)
; End of PILOT Script

; Script for program MATRIX in file "E:\VDOT\Cville_Winchester_Reporting\Junk\WINFRED-MODEL\APPLICATIONS\WMMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\WMMAT00B.PRN" MSG='Determine RMSE and other Statistics'
FILEI RECI = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\COUNT_LINKS.dbf"
FILEO RECO[3] = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\VCbyAT",
FIELDS=GRPAT,ERRAT,CNTAT,CNSAT,RMSEAT,VOlAT,VCAT,LIMAT

FILEO RECO[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\VC",
FIELDS=GRPFT,ERRFT,CNTFT,CNSFT,RMSEFT,VOlFT,VCFT,LIMFT

FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\RMSE",
FIELDS=GRP,ERR,CNT,CNS,RMSE,VOl,VC,LIM,
       GRPFT,ERRFT,CNTFT,CNSFT,RMSEFT,VOlFT,VCFT,LIMFT,
       GRPAT,ERRAT,CNTAT,CNSAT,RMSEAT,VOlAT,VCAT,LIMAT

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

array err=10000, cnt=10000, cns=10000, rmse=10000, grp=10000, limit=10000,vol=10000,vc=10000,lim=10000
array errft=10000, cntft=10000, cnsft=10000, rmseft=10000, grpft=10000, limitft=10000,volft=10000,vcft=10000,limft=10000
array errat=10000, cntat=10000, cnsat=10000, rmseat=10000, grpat=10000, limitat=10000,volat=10000,vcat=10000,limat=10000

_err=ri.errorsq

if({Calibration Run}=1)
   _cnt=ri.count
else
   _cnt=ri.capacity
endif

_cns=ri.links
_grp=ri.grp
_vol=ri.total_vol
_ft=ri.factype
_at=ri.LUD


if({Calibration Run}=1)

;**************************************************************************************************************
;                                        RMSE Report only for Base Year
;**************************************************************************************************************

if(ri.grp=1-12)
 ERR[ri.grp]=ERR[ri.grp]+_err
 CNT[ri.grp]=CNT[ri.grp]+_cnt
 CNS[ri.grp]=CNS[ri.grp]+_cns
 RMSE[ri.grp]=(sqrt(ERR[ri.grp]/CNS[ri.grp])/(CNT[ri.grp]/CNS[ri.grp]))*100
 GRP[ri.grp]=ri.grp
 VOL[ri.grp]=VOL[ri.grp]+_vol
 VC[ri.grp]=VOL[ri.grp]/CNT[ri.grp]


endif

 ERR[10000]=ERR[10000]+_err
 CNT[10000]=CNT[10000]+_cnt
 CNS[10000]=CNS[10000]+_cns
 RMSE[10000]=(sqrt(ERR[10000]/CNS[10000])/(CNT[10000]/CNS[10000]))*100
 GRP[10000]=100
 VOL[10000]=VOL[10000]+_vol
 VC[10000]=VOL[10000]/CNT[10000]


if(i=0)
 loop _n=1,10000
  if(RMSE[_n]>0)
    RO.GRP=GRP[_n]
    RO.ERR=ERR[_n]
    RO.CNT=CNT[_n]
    RO.CNS=CNS[_n]
    RO.RMSE=RMSE[_n]
    RO.VOL=VOL[_n]
    RO.VC=VC[_n]

     if(GRP[_n]=1) _lim='1 - 5,000'
     if(GRP[_n]=2) _lim='5,000 - 10,000'
     if(GRP[_n]=3) _lim='10,000 - 20,000'
     if(GRP[_n]=4) _lim='20,000 - 30,000'
     if(GRP[_n]=5) _lim='30,000 - 40,000'
     if(GRP[_n]=6) _lim='40,000 - 50,000'
     if(GRP[_n]=7) _lim='50,000 - 60,000'
     if(GRP[_n]=8) _lim='60,000 - 70,000'
     if(GRP[_n]=9) _lim='70,000 - 80,000'
     if(GRP[_n]=10) _lim='80,000 - 90,000'
     if(GRP[_n]=11) _lim='90,000 - 100,000'
     if(GRP[_n]=12) _lim='More than 100,000'
     if(GRP[_n]=100) _lim='All'

    RO.LIM=_LIM
   Write reco=1
    RO.GRP=0
    RO.ERR=0
    RO.CNT=0
    RO.CNS=0
    RO.RMSE=0
    RO.VOL=0
    RO.VC=0
    RO.LIM=''
  endif
endloop
endif

endif ; base year condition
;*********************************************************************************************************
;                                      Volume to Count Summary by Facility Type
;*********************************************************************************************************

if(ri.factype=1-10)
 CNTFT[ri.factype]=CNTFT[ri.factype]+_cnt
 CNSFT[ri.factype]=CNSFT[ri.factype]+_cns
 ; Only for Base Year
 if({Calibration Run}=1)
   ERRFT[ri.factype]=ERRFT[ri.factype]+_err
   RMSEFT[ri.factype]=(sqrt(ERRFT[ri.factype]/CNSFT[ri.factype])/(CNTFT[ri.factype]/CNSFT[ri.factype]))*100
 endif

 GRPFT[ri.factype]=ri.factype
 VOLFT[ri.factype]=VOLFT[ri.factype]+_vol
 VCFT[ri.factype]=VOLFT[ri.factype]/CNTFT[ri.factype]
endif


 CNTFT[10000]=CNTFT[10000]+_cnt
 CNSFT[10000]=CNSFT[10000]+_cns

  if({Calibration Run}=1)
    RMSEFT[10000]=(sqrt(ERRFT[10000]/CNSFT[10000])/(CNTFT[10000]/CNSFT[10000]))*100
    ERRFT[10000]=ERRFT[10000]+_err
  endif

 GRPFT[10000]=100
 VOLFT[10000]=VOLFT[10000]+_vol
 VCFT[10000]=VOLFT[10000]/CNTFT[10000]


if(i=0)
 loop _n=1,10000
  if(VOLFT[_n]>0)
    RO.GRPFT=GRPFT[_n]
    RO.ERRFT=ERRFT[_n]
    RO.CNTFT=CNTFT[_n]
    RO.CNSFT=CNSFT[_n]
    RO.RMSEFT=RMSEFT[_n]
    RO.VOLFT=VOLFT[_n]
    RO.VCFT=VCFT[_n]

      if(GRPFT[_n]=1) _limft='Interstate'
      if(GRPFT[_n]=2) _limft='Minor Freeway'
      if(GRPFT[_n]=3) _limft='Principal Art'
      if(GRPFT[_n]=4) _limft='Major Art'
      if(GRPFT[_n]=5) _limft='Minor Art'
      if(GRPFT[_n]=6) _limft='Major Collector'
      if(GRPFT[_n]=7) _limft='Minor Collector'
      if(GRPFT[_n]=8) _limft='Local'
      if(GRPFT[_n]=9) _limft='H.S. Ramp'
      if(GRPFT[_n]=10) _limft='L.S. Ramp'
      if(GRPFT[_n]=100) _limft='All'

   RO.LIMFT=_limft
   Write reco=2
   Write reco=1

   RO.GRPFT=0
   RO.GRPFT=0
   RO.ERRFT=0
   RO.CNTFT=0
   RO.CNSFT=0
   RO.RMSEFT=0
   RO.VOLFT=0
   RO.VCFT=0
   RO.LIMFT=''
  endif
endloop
endif

;*********************************************************************************************************
;                      Volume to Count Summary by Area Type
;*********************************************************************************************************

if(ri.AT=1-5)
 ERRAT[ri.AT]=ERRAT[ri.AT]+_err
 CNTAT[ri.AT]=CNTAT[ri.AT]+_cnt
 CNSAT[ri.AT]=CNSAT[ri.AT]+_cns
 RMSEAT[ri.AT]=(sqrt(ERRAT[ri.AT]/CNSAT[ri.AT])/(CNTAT[ri.AT]/CNSAT[ri.AT]))*100
 GRPAT[ri.AT]=ri.AT
 VOLAT[ri.AT]=VOLAT[ri.AT]+_vol
 VCAT[ri.AT]=VOLAT[ri.AT]/CNTAT[ri.AT]
endif

 ERRAT[10000]=ERRAT[10000]+_err
 CNTAT[10000]=CNTAT[10000]+_cnt
 CNSAT[10000]=CNSAT[10000]+_cns
 RMSEAT[10000]=(sqrt(ERRAT[10000]/CNSAT[10000])/(CNTAT[10000]/CNSAT[10000]))*100
 GRPAT[10000]=100
 VOLAT[10000]=VOLAT[10000]+_vol
 VCAT[10000]=VOLAT[10000]/CNTAT[10000]


if(i=0)
 loop _n=1,10000
  if(VOLAT[_n]>0)
    RO.GRPAT=GRPAT[_n]
    RO.ERRAT=ERRAT[_n]
    RO.CNTAT=CNTAT[_n]
    RO.CNSAT=CNSAT[_n]
    RO.RMSEAT=RMSEAT[_n]
    RO.VOLAT=VOLAT[_n]
    RO.VCAT=VCAT[_n]
      
      if(GRPAT[_n]=1) _limat='CBD'
      if(GRPAT[_n]=2) _limat='Urban'
      if(GRPAT[_n]=3) _limat='Rural'
      if(GRPAT[_n]=100) _limat='All'
   RO.LIMAT=_limat
   Write reco=3
   Write reco=1

   RO.GRPAT=0
   RO.GRPAT=0
   RO.ERRAT=0
   RO.CNTAT=0
   RO.CNSAT=0
   RO.RMSEAT=0
   RO.VOLAT=0
   RO.VCAT=0
   RO.LIMAT=''

  endif
endloop

endif

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


endif
; End of PILOT Script

