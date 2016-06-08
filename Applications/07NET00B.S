 ; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\logs\RMSELOG.PRN" MSG='RMSE & Vol/CNT'
FILEO LINKO = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\COUNT_LINKS.dbf"
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\reports\RMSE.PRN"

PARAMETERS  ZONES={Total Zones}

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
_calcheck={Calibration Run}


   ft=FEDFUNC; FTYPE1
   at=LUD; ATYPE1
   LNS=LANES
if (dir=0)
       TOTAL_VOL=ROUND(VT_6/2)
else
      TOTAL_VOL=ROUND(VT_6)
endif
         ;_TOTAL_VOLUME=TOTAL_VOL

   ;DISTANCE=LENGTH
  ; _TOTAL_VOLUME=TOTAL_VOL

  ;if(COUNT>0&EXT_COUNT=0&dir=0) 
     ;count   = ROUND(COUNT)
  ;elseif(COUNT>0&EXT_COUNT=0&dir<>0)
     ;count   = COUNT
  if(COUNT>0&dir=0&FACTYPE<>12) 
     count   = ROUND(COUNT)
  elseif(COUNT>0&dir<>0&FACTYPE<>12)
     count   = COUNT
   ELSEIF(_CALCHECK=0 & FACTYPE<>11)
      COUNT=CAPACITY*{CAPCONFAC}
   ELSE
      COUNT=0
   ENDIF
  
_aK = count
_ak_grp =count*2

  links=1
   lanemiles=LANES*DISTANCE

if(count=0) DELETE

; *****************************
;
; initialize arrays and variables
   ARRAY _err=13, _cns=13, _cnt=13, _RGP=13, _volbyft=100, _cntbyft=100
   ARRAY _volbyat=100, _cntbyat=100, _lnkbyft=100, _lnkbyat=100
   _group=(0.0*ft)
   _RGP[1]=1, _RGP[2]=5000, _RGP[3]=10000, _RGP[4]=20000, _RGP[5]=30000, _RGP[6]=40000, _RGP[7]=50000,
   _RGP[8]=60000, _RGP[9]=70000, _RGP[10]=80000, _RGP[11]=90000, _RGP[12]=100000, _RGP[13]=500000
   IF (A=1)
     LOOP _iter=1,13
           _err[_iter]=0,_cnt[_iter]=0,_cns[_iter]=0
     ENDLOOP
     LOOP _iter=1,99
           _volbyft[_iter]=0, _cntbyft[_iter]=0, _lnkbyft[_iter]=0
           _volbyat[_iter]=0, _cntbyat[_iter]=0, _lnkbyat[_iter]=0
     ENDLOOP
   ENDIF

; establish some English sounding variables for the output network
   _LINKS=links
   _LANEMILES=lanemiles
; calculate and compartmentalize 
   IF(_aK>0) VOLCNT=TOTAL_VOL/_aK, NETDIFF=TOTAL_VOL-_aK, ABSDIFF=ABS(NETDIFF), ERRORSQ=NETDIFF^2, PCTDIFF=100*NETDIFF/_aK _group=1
   
;commented out by Srin for accurate groups creation for Winchester
   IF (_aK_grp>5000) _group=2
   IF (_aK_grp>10000) _group=3
   IF (_aK_grp>20000) _group=4
   IF (_aK_grp>30000) _group=5
   IF (_aK_grp>40000) _group=6
   IF (_aK_grp>50000) _group=7
   IF (_aK_grp>60000) _group=8
   IF (_aK_grp>70000) _group=9
   IF (_aK_grp>80000) _group=10
   IF (_aK_grp>90000) _group=11
   IF (_aK_grp>100000) _group=12

    GRP=_group
    ;IF (_aK>2500) _group=2
    ;IF (_aK>5000) _group=3
    ;IF (_aK>10000) _group=4
    ;IF (_aK>15000) _group=5
    ;IF (_aK>20000) _group=6
    ;IF (_aK>25000) _group=7
    ;IF (_aK>30000) _group=8
    ;IF (_aK>35000) _group=9
    ;IF (_aK>40000) _group=10
    ;IF (_aK>45000) _group=11
    ;IF (_aK>50000) _group=12

   IF (_aK>0) 
   _ERR[_group]=ERRORSQ+_ERR[_group], _CNS[_group]=_aK+_CNS[_group], _CNT[_group]=_CNT[_group]+1
   _ERR[13]=ERRORSQ+_ERR[13], _CNS[13]=_aK+_CNS[13], _CNT[13]=_CNT[13]+1
   ENDIF
IF (_aK>0)  
   _volbyft[ft]=_volbyft[ft]+TOTAL_VOL
   _cntbyft[ft]=_cntbyft[ft]+_aK
   _lnkbyft[ft]=_lnkbyft[ft]+1
   _volbyat[at]=_volbyat[at]+TOTAL_VOL
   _cntbyat[at]=_cntbyat[at]+_aK
   _lnkbyat[at]=_lnkbyat[at]+1
   _volbyft[100]=_volbyft[100]+TOTAL_VOL
   _cntbyft[100]=_cntbyft[100]+_aK
   _lnkbyft[100]=_lnkbyft[100]+1
   _volbyat[100]=_volbyat[100]+TOTAL_VOL
   _cntbyat[100]=_cntbyat[100]+_aK
   _lnkbyat[100]=_lnkbyat[100]+1
endif
CROSSTAB  VAR= _LINKS, VAR= _LANEMILES form=12.0c,
    row=ft, range=0-9-1,0-9,
    col=LNS, range=0-6-1,0-6
IF (_aK>0)
CROSSTAB  VAR= _TOTAL_VOLUME, VAR= _aK form=12.0c,
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4
ENDIF

;====XTABS of Number of Links and Lane-Miles for Links with Traffic Counts and
;====         VOL/VMT/VHT for Count and Volumes and their ratios for links with traffic counts

IF (COUNT>0)
  CONGTIME=TIME_6
  _A_VOL=TOTAL_VOL                    ;Assigned Volume
  _C_VOL=COUNT                        ;Count  
  _A_VMT=DISTANCE*TOTAL_VOL           ;Volume-VMT
  _C_VMT=DISTANCE*COUNT               ;Count-VMT
  _A_VHT=TOTAL_VOL*(CONGTIME/60.)     ;Volume-VHT
  _C_VHT=COUNT*(CONGTIME/60.)         ;Count-VHT
  _C_LINKS=1                          ;Links with Counts on it
  _CLNMLS=lns*distance                ;Lane Miles with traffic count on links


 CROSSTAB VAR=_C_LINKS form=7.0c, VAR=_CLNMLS form=10.2c,
          VAR=_A_VOL form=12.0c, VAR=_C_VOL _A_VMT _C_VMT _A_VHT _C_VHT,  
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4,
    comp=_A_VOL/_C_VOL,form=8.3,
    comp=_A_VMT/_C_VMT,form=8.3,
    comp=_A_VHT/_C_VHT,form=8.3
    

  CROSSTAB VAR=_C_LINKS form=7.0c, VAR=_CLNMLS form=10.2c,
           VAR=_A_VOL form=12.0c, VAR=_C_VOL,_A_VMT,_C_VMT,_A_VHT,_C_VHT, 
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4,
    comp=_A_VOL/_C_VOL,form=8.3,
    comp=_A_VMT/_C_VMT,form=8.3,
    comp=_A_VHT/_C_VHT,form=8.3
 
ENDIF
;ENDIF

ENDPROCESS

; Use this phase to make computations and selections of any data on the LINKI files.




; Use this phase for combining and reporting of working variables.
; =========================================================
; SUMMARY REPORTING
; =========================================================
PHASE=SUMMARY
PRINT LIST="{SCENARIO_FULLNAME}" PRINTO=1
PRINT LIST="{SCENARIO_SHORTNAME}\n" PRINTO=1
; a little loop to write out the Percent Root Mean Square Error
LOOP _iter=1,12  
  if (_iter=1) print list="*********************** ALL COUNT ROOT MEAN SQUARE ERROR SUMMARY ***********************", printo=1
  if (_cnt[_iter]>0) print,        
 list="  Percent RMSE for Volume Group ",_iter(2.0c)," ",_RGP[_iter](7.0c),"-",_RGP[_iter+1](7.0c),": ",sqrt(_err[_iter]/_cnt[_iter])/(_cns[_iter]/_cnt[_iter])*100(5.1),"%,                      N=",_cnt[_iter](5.0CL), PRINTO=1
ENDLOOP
_iter=13
 list="  Percent RMSE for Volume Group ",_iter(2.0c)," ",_RGP[1](7.0c),"-",_RGP[_iter](7.0c),": ",sqrt(_err[_iter]/_cnt[_iter])/(_cns[_iter]/_cnt[_iter])*100(5.1),"%,                      N=",_cnt[_iter](5.0CL), PRINTO=1

; one for Vol/Cnt by FT 
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n ********************** VOLUME AND COUNT SUMMARY BY FEDERAL FUNC **********************", PRINTO=1
if (_cntbyft[_iter]>0) print,
 list="Federal Func Summary for FT=",_iter(3.0c),
 " VOL=",_volbyft[_iter](11.0c),
 " CNT=",_cntbyft[_iter](11.0c),
 " VOL/CNT=",(_volbyft[_iter]/_cntbyft[_iter])(5.2c),
 "   N=",_lnkbyft[_iter](5.0c), PRINTO=1
ENDLOOP

; one for Vol/Cnt by AT/LUD
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n ************************* VOLUME AND COUNT SUMMARY BY LANDUSE ************************", PRINTO=1
if (_cntbyat[_iter]>0) print,
 list="    Landuse Summary for LU=",_iter(3.0c),
 " VOL=",_volbyat[_iter](11.0c),
 " CNT=",_cntbyat[_iter](11.0c),
 " VOL/CNT=",(_volbyat[_iter]/_cntbyat[_iter])(5.2c),
 "   N=",_lnkbyat[_iter](5.0c), PRINTO=1
ENDLOOP

ENDPROCESS

ENDRUN
