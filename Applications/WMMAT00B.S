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
