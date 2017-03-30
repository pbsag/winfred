
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\TransitSpeeds.PRN" MSG='Transit Speeds'
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\Interim{Year}{Alternative}.NET"
FILEO NETO = "{SCENARIO_DIR}\Output\HWYTSPD.NET"
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
    if ((LM[_nn] >= 26) & (HM[_nn] <= 26)) spdratioM26 = SR[_nn]  
    endif
  ENDLOOP
     ; APPLY DEFAULT CURVES
     IF (_AUTOSPEED>0)
       _TSPD21=spdratioM21*_AUTOSPEED  ; Bus Speeds
       _TSPD26=spdratioM26*_AUTOSPEED  ; Project mode
       
       M21TIMEPK=60*(DISTANCE)/_TSPD21
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
      list=A(7.0),B(7.0),DISTANCE(7.2),_AUTOSPEED(7.2),_TSPD26(7.2),M26TIMEPK(7.2),_CURVEMODE26(7.0)," MODE26"
      list="\n\n"
 ENDIF

 ENDPROCESS

ENDRUN
