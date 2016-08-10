; Script for program NETWORK in file "C:\projects\roanoke\Cube\TransitSpeeds.S"

; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\TransitSpeeds.PRN" MSG='Transit Speeds'
FILEO NETO = "{SCENARIO_DIR}\Output\HWYTSPD.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\RVTPOBase{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\transit\TRANSPD.dbf"


PROCESS PHASE=LINKMERGE

  ;If auto travel time is not present or is zero, a default value of 15 mph is used.
  IF (FFSPEED>0)
    _AUTOSPEED=FFSPEED
  ELSE
    _AUTOSPEED=15
  ENDIF

   ; COMPUTE FREE FLOW TIME ON NETWORK
  FF_TIME=ROUND(100*(DISTANCE)/FFSPEED*60)/100

  ; COMPUTE WALKTIME ON NETWORK
  WALKTIME=ROUND(100*(DISTANCE)/{AVGWLKSPD}*60)/100


  ;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

;************************************************************************************************
;* DEFAULT TRANSIT SPEEDS SET EQUAL TO AUTO SPEEDS. APPLY APPROPRIATE TRANSIT SPEED CURVES HERE.*
;************************************************************************************************

lookup name=curve,
     lookup[1]=CURVE_NO, result=LOW_MODE,
     lookup[2]=CURVE_NO, result=HIGH_MODE,
     lookup[3]=CURVE_NO, result=LOW_FT,
     lookup[4]=CURVE_NO, result=HIGH_FT,
     lookup[5]=CURVE_NO, result=LOW_AT,
     lookup[6]=CURVE_NO, result=HIGH_AT,
     lookup[7]=CURVE_NO, result=SPEEDRATIO,
     interpolate=n,fail=0,0,0,list=y,lookupi=1
array lm=500,hm=500,lf=500,hf=500,la=500,ha=500,sr=500

loop _nn=1,500
   LM[_nn]=CURVE(1,_nn)
   HM[_nn]=CURVE(2,_nn)
   LF[_nn]=CURVE(3,_nn)
   HF[_nn]=CURVE(4,_nn)
   LA[_nn]=CURVE(5,_nn)
   HA[_nn]=CURVE(6,_nn)
   SR[_nn]=CURVE(7,_nn)
if (lm[_nn]>0) _numberofcurves=_nn ; obtain the total number of curves fromt he curve file
if (lm[_nn]<=0) break
endloop

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

  LOOP _nn=1,_numberofcurves
    if ((FACTYPE >= LF[_nn]) & (FACTYPE <= HF[_nn]) & (ATYPE >= LA[_nn]) & (ATYPE <= HA[_nn]))
    if ((LM[_nn] >= 21) & (HM[_nn] <= 21)) spdratioM21 = SR[_nn]
    if ((LM[_nn] >= 22) & (HM[_nn] <= 22)) spdratioM22 = SR[_nn]
    if ((LM[_nn] >= 26) & (HM[_nn] <= 26)) spdratioM26 = SR[_nn]  
    
    endif
  ENDLOOP
     ; APPLY DEFAULT CURVES
     IF (_AUTOSPEED>0)
       _TSPD21=spdratioM21*_AUTOSPEED  ; Bus Speeds
       _TSPD22=spdratioM22*_AUTOSPEED  ; Circulator Speeds (assumed same as buses)
       _TSPD26=spdratioM26*_AUTOSPEED  ; Project mode
       
       M21TIMEPK=60*(DISTANCE)/_TSPD21
       M22TIMEPK=60*(DISTANCE)/_TSPD22
       M26TIMEPK=60*(DISTANCE)/_TSPD26
       
 
 
     ENDIF
    
      ; WALK CONTROLS
      WALKTIME=60*DISTANCE/{AVGWLKSPD}
 IF (FACTYPE=1-2,9-10)
      WALKTIME=999.99
 ENDIF
 

 IF((A={FromNode}) && (B={ToNode}))

      list="\n\n"
      list="     An     Bn   Dist   ASpd   TSpd   Ttim    Crv"
      list=A(7.0),B(7.0),DISTANCE(7.2),_AUTOSPEED(7.2),_TSPD21(7.2),M21TIMEPK(7.2),_CURVEMODE21(7.0)," MODE21"
      list=A(7.0),B(7.0),DISTANCE(7.2),_AUTOSPEED(7.2),_TSPD22(7.2),M22TIMEPK(7.2),_CURVEMODE22(7.0)," MODE22"
      list=A(7.0),B(7.0),DISTANCE(7.2),_AUTOSPEED(7.2),_TSPD26(7.2),M26TIMEPK(7.2),_CURVEMODE26(7.0)," MODE26"
      list="\n\n"
 ENDIF

 ENDPROCESS

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\projects\roanoke\Cube\Build_WalkAccess_Connectors.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\BuildWalkAccessConenctors.PRN" MSG='Build Walk Access Connectors'
FILEO REPORTO = "{SCENARIO_DIR}\Output\LOGS\TNPTR00B.PRN"
FILEO NTLEGO = "{SCENARIO_DIR}\Output\NTLEG.TEM"
FILEO NETO = "{SCENARIO_DIR}\Output\NTLEG.NET"
FILEI FACTORI[1] = "{CATALOG_DIR}\Params\transit\WalkPrem.FAC"
FILEI FAREI = "{CATALOG_DIR}\Params\transit\TFARES.FAR"
FILEI SYSTEMI = "{CATALOG_DIR}\Params\transit\TSYSD.PTS"
FILEI LINEI[1] = "{SCENARIO_DIR}\Input\TROUTE_{Year}.LIN"
FILEI NETI = "{SCENARIO_DIR}\Output\HWYTSPD.NET"

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

; OVERALL PARAMETERS OF RUN
PARAMETERS USERCLASSES=1,FARE=N, MAPSCALE={UNIT.n,RadioBtn-CHARACTER,"","0.01 Miles", ,"0.1 Miles","0.01 Miles"}, HDWAYPERIOD=1,
           NOROUTEERRS=999999, NOROUTEMSGS=999999,
           TRANTIME=LW.TRANTIME,
           TRANTIME[21]=LI.M21TIMEPK,
           TRANTIME[22]=LI.M22TIMEPK,
           TRANTIME[26]=LI.M26TIMEPK

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

REPORT LINES=T
PROCESS PHASE=LINKREAD
           LW.TRANTIME=LI.M21TIMEPK
           LW.WALKTIME=LI.WALKTIME
           LW.WALKDISTANCE=LI.DISTANCE
           LW.DISTANCE=LI.DISTANCE
ENDPROCESS

PROCESS PHASE=DATAPREP

  ; 1 - Generate Walk Access Connectors
 
 GENERATE, COST=(LW.WALKDISTANCE),EXTRACTCOST=(LW.WALKTIME),MAXCOST=200*{WALKACC,EditBox-REAL,"Average Walk Distance (miles)","0.6"},LIST=T,EXCLUDELINK=(LI.FACTYPE=1-2,9-10),
            NTLEGMODE=1,MAXNTLEGS=200*{MAXWLKACCLNKS},DIRECTION=3,ONEWAY=F,FROMNODE=1-{ZONESA,EditBox-INTEGER,"Total number of zones including externals","266"},TONODE={NODEMIN,EditBox-INTEGER,"First non-zone node number","1000"}-99999

 ; 4 - Generate All-Walk Connectors
  GENERATE, COST=(LW.WALKDISTANCE),EXTRACTCOST=(LW.WALKTIME),MAXCOST=200*7,LIST=T,EXCLUDELINK=(LI.FACTYPE=1-2,9-10),
            NTLEGMODE=4,MAXNTLEGS=200*{MAXWLKACCLNKS},DIRECTION=3,ONEWAY=F,FROMNODE=1-{ZONESA},TONODE=1-{ZONESA}

ENDPROCESS


ENDRUN


; Script for program MATRIX in file "C:\projects\roanoke\Cube\WalkAccess_Connectors_by_Mode.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\WalkAccess_ByMode.PRN" MSG='Subdivide Connectors into Separate Files by Mode'
FILEO PRINTO[2] = "{SCENARIO_DIR}\Output\NTLEG4.NTL"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\NTLEG1_TEM.NTL"
FILEI RECI = "{SCENARIO_DIR}\Output\NTLEG.TEM"

s1=strpos('NT',reci)
s2=strpos('LEG',reci)
s3=strpos('MODE',reci)
s4=strpos('COST',reci)
s5=strpos('DIST',reci)
s6=strpos('ONEWAY',reci)
s7=strpos('XN',reci)

; get the origin and destination zone
s8=(s3-s2)
leg1=substr(reci,s2,s8)
s9=strpos('=',leg1)
s10=strpos('-',leg1)
s11=(s9+1)
s12=(s10-1)
s13=(s10+1)
zonei=val(substr(leg1,s11,s12))
zonej=val(substr(leg1,s13,strlen(leg1)))

; get the mode number
s14=(s4-s3)
mode1=substr(reci,s3,s14)
s15=strpos('=',mode1)
s16=(s15+1)
mode=val(substr(mode1,s16,strlen(mode1)))

; get the time on the connector (cost field in the NT leg file)
s17=(s5-s4)
time1=substr(reci,s4,s17)
s18=strpos('=',time1)
s19=(s18+1)
time=val(substr(time1,s19,strlen(time1)))

; get the distance
s20=(s6-s5)
dist1=substr(reci,s5,s20)
s21=strpos('=',dist1)
s22=(s21+1)
dist=val(substr(dist1,s22,strlen(dist1)))

; get the rest of the string
s23=substr(reci,s6,strlen(reci))

if (i==1 && _ctr==0)
  PRINT LIST=";;<<PT>>;;", PRINTO=1
  PRINT LIST=";;<<PT>>;;", PRINTO=1
  _ctr = _ctr + 1
endif
;modes - walk, pnr, knr, all-walk, platcform connectors, sidewalk
if (mode=1) PRINT LIST="NT LEG=",zonei(5.0),"-",zonej(5.0)," MODE=",mode(2.0)," COST=",time(6.2)," DIST=",dist(5.2)," ",s23,PRINTO=1
if (mode=4) PRINT LIST="NT LEG=",zonei(5.0),"-",zonej(5.0)," MODE=",mode(2.0)," COST=",time(6.2)," DIST=",dist(5.2)," ",s23,PRINTO=2

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\projects\roanoke\Cube\Trn_Skims_PK.S"
;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\Trn_PK_Skims.PRN" MSG='PK-Walk Access Paths / Skims'
FILEI NTLEGI[1] = "{SCENARIO_DIR}\Output\NTLEG1_TEM.NTL"
FILEO MATO[2] = "{SCENARIO_DIR}\Output\PK_TSKIMPrem.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO MATO[1] = "{SCENARIO_DIR}\Output\PK_TSKIMBus.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO ROUTEO[2] = "{SCENARIO_DIR}\Output\PK_TPATHPrem.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO ROUTEO[1] = "{SCENARIO_DIR}\Output\PK_TPATHBus.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO REPORTO = "{SCENARIO_DIR}\Output\PK_TransitWalk.rpt"
FILEO NETO = "{SCENARIO_DIR}\Output\PK_TransitWalk.NET"
FILEI FACTORI[2] = "{CATALOG_DIR}\Params\transit\WalkPrem.FAC"
FILEI FACTORI[1] = "{CATALOG_DIR}\Params\transit\WalkBus.FAC"
FILEI FAREI = "{CATALOG_DIR}\Params\transit\TFARES.FAR"
FILEI SYSTEMI = "{CATALOG_DIR}\Params\transit\TSYSD.PTS"
FILEI LINEI[1] = "{SCENARIO_DIR}\Input\TROUTE_{Year}.LIN"
FILEI NETI = "{SCENARIO_DIR}\Output\HWYTSPD.NET"

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

   ; OVERALL PARAMETERS
   PARAMETERS USERCLASSES=1-2,FARE=N, MAPSCALE={UNIT}, HDWAYPERIOD=1,
         NOROUTEERRS=999999, NOROUTEMSGS=999999,
         TRANTIME=LW.TRANTIME,
         TRANTIME[21]=LI.M21TIMEPK,
         TRANTIME[22]=LI.M22TIMEPK,
         TRANTIME[26]=LI.M26TIMEPK

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    
   PROCESS PHASE=LINKREAD
         LW.TRANTIME=LI.M21TIMEPK
         LW.WALKTIME=LI.WALKTIME
         LW.WALKDISTANCE=LI.DISTANCE
         LW.DISTANCE=LI.DISTANCE
   ENDPROCESS

   PROCESS PHASE=DATAPREP

         ;Generate walk-access links
         GENERATE READNTLEGI=1
    ENDPROCESS

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

    PROCESS PHASE=SKIMIJ
         MW[1]=TIMEA(0,1)                                                              ; Walk time
         MW[2]=TIMEA(0,21)                                                             ; All bus time
         MW[3]=TIMEA(0,22)                                                              ; Trolley time
         MW[4]=TIMEA(0,26)                                                             ; Project mode time

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    IF(BRDINGS(0,TMODES) > 0)
         MW[5]=BRDINGS(0,TMODES)-1                                                   ; Number of transfers
    ELSE
         MW[5]=0
    ENDIF
         MW[6]=IWAITA(0)                                                              ; Initial wait time
         MW[7]=XWAITA(0)                                                              ; Transfer wait time
         MW[8]=FAREA(0)                                                               ; Fare matrix
         MW[9]=TIMEA(0,ALLMODES)                                                      ; Time on all modes
    ENDPROCESS

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\projects\roanoke\Cube\Trn_Skims_OP.S"
;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\Trn_OP_Skims.PRN" MSG='OP-Walk Access Paths / Skims'
FILEI NTLEGI[1] = "{SCENARIO_DIR}\OUTPUT\NTLEG1_TEM.NTL"
FILEI NETI = "{SCENARIO_DIR}\OUTPUT\HWYTSPD.NET"
FILEO MATO[2] = "{SCENARIO_DIR}\Output\OP_TSKIMPrem.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO MATO[1] = "{SCENARIO_DIR}\Output\OP_TSKIMBus.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO ROUTEO[2] = "{SCENARIO_DIR}\Output\OP_TPATHPrem.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO ROUTEO[1] = "{SCENARIO_DIR}\Output\OP_TPATHBus.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO REPORTO = "{SCENARIO_DIR}\Output\OP_TransitWalk.rpt"
FILEO NETO = "{SCENARIO_DIR}\Output\OP_TransitWalk.NET"
FILEI FACTORI[2] = "{CATALOG_DIR}\Params\transit\WalkPrem.FAC"
FILEI FACTORI[1] = "{CATALOG_DIR}\Params\transit\WalkBus.FAC"
FILEI FAREI = "{CATALOG_DIR}\Params\transit\TFARES.FAR"
FILEI SYSTEMI = "{CATALOG_DIR}\Params\transit\TSYSD.PTS"
FILEI LINEI[1] = "{SCENARIO_DIR}\Input\TROUTE.LIN"

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

   ; OVERALL PARAMETERS
   PARAMETERS USERCLASSES=1-2,FARE=N, MAPSCALE={UNIT}, HDWAYPERIOD=2,
         NOROUTEERRS=999999, NOROUTEMSGS=999999,
         TRANTIME=LW.TRANTIME,
         TRANTIME[21]=LI.M21TIMEPK,
         TRANTIME[22]=LI.M22TIMEPK,
         TRANTIME[26]=LI.M26TIMEPK

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    
   PROCESS PHASE=LINKREAD
         LW.TRANTIME=LI.M21TIMEPK
         LW.WALKTIME=LI.WALKTIME
         LW.WALKDISTANCE=LI.DISTANCE
         LW.DISTANCE=LI.DISTANCE
   ENDPROCESS

   PROCESS PHASE=DATAPREP

         ;Generate walk-access links
         GENERATE READNTLEGI=1
    ENDPROCESS

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

    PROCESS PHASE=SKIMIJ
         MW[1]=TIMEA(0,1)                                                              ; Walk time
         MW[2]=TIMEA(0,21)                                                             ; All bus time
         MW[3]=TIMEA(0,22)                                                              ; Trolley time
         MW[4]=TIMEA(0,26)                                                             ; Project mode time

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    IF(BRDINGS(0,TMODES) > 0)
         MW[5]=BRDINGS(0,TMODES)-1                                                   ; Number of transfers
    ELSE
         MW[5]=0
    ENDIF
         MW[6]=IWAITA(0)                                                              ; Initial wait time
         MW[7]=XWAITA(0)                                                              ; Transfer wait time
         MW[8]=FAREA(0)                                                               ; Fare matrix
         MW[9]=TIMEA(0,ALLMODES)                                                      ; Time on all modes
    ENDPROCESS

ENDRUN


