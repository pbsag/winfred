LOOP PER = 1, 4, 1

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (PER=1) ; AM
PERIOD_COL=3
PERIOD_NAME = 'AM'

ELSEIF (PER=2) ; MD
PERIOD_COL=4
PERIOD_NAME = 'MD'

ELSEIF (PER=3) ; PM
PERIOD_COL=5
PERIOD_NAME = 'PM'

ELSEIF (PER=4) ; NT 
PERIOD_COL=6
PERIOD_NAME = 'NT'

ENDIF


; End of PILOT Script

; Script for program HIGHWAY in file "C:\projects\roanoke\Cube\HighwayAssign_Preload.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="C:\projects\ROANOKE\CUBE\ASHWY00A.PRN" MSG='Preload External Trips'
FILEO MATO[1] = "{SCENARIO_DIR}\Output\SL_Preloaded_@PERIOD_NAME@.MAT",
MO=2, NAME=SL_EE
FILEI NETI = "{SCENARIO_DIR}\Output\RVTPOBase{Year}{Alternative}.NET"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\ODAUTO_@PERIOD_NAME@.MAT"
FILEO PATHO[1] = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.PTH"
FILEO NETO = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.NET",
      DEC = 0

;Set run PARAMETERS and Controls
PARAMETERS ZONES={Total ZONES}, MAXITERS=1, COMBINE=EQUI, GAP= 0.0, RELATIVEGAP = 0.00001

PHASE=LINKREAD

   T0 = 60* (LI.DISTANCE/LI.FFSPEED)
 ;  T0 = 60* (LI.DISTANCE/LI.FFS)
  C  = LI.CAPE_@PERIOD_NAME@

  LW.COSTa = T0 + 0.25*LI.DISTANCE
  
/*
1	Interstate/Principal Freeway
2	Minor Freeway
3	Principal Arterial
4	Major Arterial
5	Minor Arterial
6	Major Collector
7	Minor Collector
8	Local
9	High-speed Ramp
10	Low-speed Ramp
11	Centroid Connector
12	External Station Connector
*/

; Group facility types
  IF(LI.FACTYPE=1,2,9,10)    LINKCLASS=1 ; Freeway
  IF(LI.FACTYPE=3,4)    LINKCLASS=2 ; Major Arterial
  IF(LI.FACTYPE=5)      LINKCLASS=3 ; Minor Arterial
  IF(LI.FACTYPE=6,7)    LINKCLASS=4 ; Collector
  IF(LI.FACTYPE=8)      LINKCLASS=5 ; Local
  IF(LI.FACTYPE>10)     LINKCLASS=6 ; Connectors

ENDPHASE

PHASE=ILOOP
  ; Assign EE trips 
  PATHLOAD PATH=LW.COSTa,  MW[1] = MI.1.5, VOL[1] = MW[1], 
     MW[2] = MI.1.5, SELECTLINK=({SelectLink}), VOL[2]=MW[2] 
  
                                                                                                                                                                                                        
ENDPHASE

PHASE=ADJUST

function {
    ; V=VOL[1]+VOL[2]+VOL[3]+VOL[4]
    V=VOL[1]
    TC[1] = Min(T0 * (1 + 0.83*(V/C)^5.5), T0*100)    ; Freeway        
    TC[2] = Min(T0 * (1 + 0.83*(V/C)^3.7), T0*100)    ; Major Arterial         
    TC[3] = Min(T0 * (1 + 0.83*(V/C)^2.8), T0*100)    ; Minor Arterial    
    TC[4] = Min(T0 * (1 + 0.2*(V/C)^4), T0*100)       ; Collector
    TC[5] = Min(T0 * (1 + 0.6*(V/C)^5.5), T0*100)     ; Local
    TC[6] = T0                                        ; Connectors                       
    }

  LW.COSTa=TIME + 0.25*LI.DISTANCE
  
ENDPHASE
ENDRUN


; Script for program HIGHWAY in file "C:\projects\roanoke\Cube\HighwayAssign.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\Output\Logs\@PERIOD_NAME@.PRN" MSG='Load Final Trips onto Network'
FILEO MATO[1] = "{SCENARIO_DIR}\Output\SL_Loaded_@PERIOD_NAME@.MAT",
MO=5-8, NAME=SL_DA,SL_SR,SL_IEEI, SL_CV
FILEI NETI = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.NET"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\ODAUTO_@PERIOD_NAME@.MAT"
FILEO PATHO[1] = "{SCENARIO_DIR}\Output\LOADED_@PERIOD_NAME@.PTH"
FILEO NETO = "{SCENARIO_DIR}\Output\LOADED_@PERIOD_NAME@.NET",
      DEC = 0

;Set run PARAMETERS and Controls
PARAMETERS ZONES={Total ZONES}, MAXITERS=500, COMBINE=EQUI, GAP= 0.0, RELATIVEGAP = 0.00001

PHASE=LINKREAD
    LW.EEVOL = LI.V_1 
    
   T0 = 60* (LI.DISTANCE/LI.FFSPEED)
  ; T0 = 60* (LI.DISTANCE/LI.POST_SPEED)
  C  = LI.CAPE_@PERIOD_NAME@ 

  LW.COSTa = T0 + 0.25*LI.DISTANCE
  LW.COSTb = T0 + 0.25*LI.DISTANCE
  LW.COSTc = T0 + 0.25*LI.DISTANCE
  LW.COSTd = T0 + 0.25*LI.DISTANCE
  
/*
1	Interstate/Principal Freeway
2	Minor Freeway
3	Principal Arterial
4	Major Arterial
5	Minor Arterial
6	Major Collector
7	Minor Collector
8	Local
9	High-speed Ramp
10	Low-speed Ramp
11	Centroid Connector
12	External Station Connector
*/

; Group facility types
  IF(LI.FACTYPE=1,2,9,10)    LINKCLASS=1 ; Freeway
  IF(LI.FACTYPE=3,4)    LINKCLASS=2 ; Major Arterial
  IF(LI.FACTYPE=5)      LINKCLASS=3 ; Minor Arterial
  IF(LI.FACTYPE=6,7)    LINKCLASS=4 ; Collector
  IF(LI.FACTYPE=8)      LINKCLASS=5 ; Local
  IF(LI.FACTYPE>10)     LINKCLASS=6 ; Connectors

ENDPHASE

PHASE=ILOOP
/*
  PATHLOAD VOL[1] = MI.1.1,  PATH=LW.COSTa  
  PATHLOAD VOL[2] = MI.1.2,  PATH=LW.COSTb 
  PATHLOAD VOL[3] = MI.1.3,  PATH=LW.COSTc  
  PATHLOAD VOL[4] = MI.1.4,  PATH=LW.COSTd 
  */
  PATHLOAD PATH=LW.COSTa , MW[1] = MI.1.1, VOL[1] = MW[1],   
      MW[5] = MI.1.1, SELECTLINK=({SelectLink}), VOL[5]=MW[5] 
  PATHLOAD PATH=LW.COSTb , MW[2] = MI.1.2, VOL[2] = MW[2],
     ; MW[6] = MI.1.2, SELECTLINK=(L= 4451-4424), VOL[6]=MW[6]      
  MW[6] = MI.1.2, SELECTLINK=({SelectLink}), VOL[6]=MW[6]    
  PATHLOAD PATH=LW.COSTc , MW[3] = MI.1.3, VOL[3] = MW[3] ,
      MW[7] = MI.1.3, SELECTLINK=({SelectLink}), VOL[7]=MW[7]  
  PATHLOAD PATH=LW.COSTd , MW[4] = MI.1.4, VOL[4] = MW[4], 
      MW[8] = MI.1.4, SELECTLINK=({SelectLink}), VOL[8]=MW[8]    
  
ENDPHASE

PHASE=ADJUST

function {
    V=VOL[1]+VOL[2]+VOL[3]+VOL[4]+  LW.EEVOL ; Add preloaded EE Volumes here
   ; V=VOL[1]+VOL[2]+VOL[4]
     ; TC[1] = Min(T0 * (1 + 0.83*(V/C)^5.5), T0*100)    ; Freeway     
     ; TC[2] = Min(T0 * (1 + 0.83*(V/C)^3.7), T0*100)    ; Major Arterial  
    TC[1] = Min(T0 * (1 + 0.65*(V/C)^4.5), T0*100)    ; Freeway        
    TC[2] = Min(T0 * (1 + 0.65*(V/C)^4.0), T0*100)    ; Major Arterial         
    TC[3] = Min(T0 * (1 + 0.83*(V/C)^2.8), T0*100)    ; Minor Arterial    
    TC[4] = Min(T0 * (1 + 0.2*(V/C)^4), T0*100)       ; Collector
    TC[5] = Min(T0 * (1 + 0.6*(V/C)^5.5), T0*100)     ; Local
    TC[6] = T0                                        ; Connectors                       
    }

  LW.COSTa=TIME + 0.25*LI.DISTANCE
  LW.COSTb=TIME + 0.25*LI.DISTANCE
  LW.COSTc=TIME + 0.25*LI.DISTANCE
  LW.COSTd=TIME + 0.25*LI.DISTANCE
  
ENDPHASE
ENDRUN


ENDLOOP

; Script for program NETWORK in file "C:\projects\roanoke\Cube\HighwayAssign_MergeNetworks.s"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\Merge_Hwy_Assignments.PRN"
FILEO NETO = "{SCENARIO_DIR}\Output\LOADED_{Year}{Alternative}.NET",
 EXCLUDE = V_1, VC_1, V1_1, V2_1, V3_1, V4_1, VT_1, V1T_1, V2T_1, V3T_1, V4T_1
FILEI LINKI[4] = "{SCENARIO_DIR}\Output\LOADED_NT.NET"
FILEI LINKI[3] = "{SCENARIO_DIR}\Output\LOADED_PM.NET"
FILEI LINKI[2] = "{SCENARIO_DIR}\Output\LOADED_MD.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\LOADED_AM.NET"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\Hwy_eval_period.csv"
 
 
; =========================================================
; LINKMERGE PHASE
; =========================================================
PHASE=LINKMERGE  
; Total Volume
/*
AM_Vol=li.1.V_2 + li.1.V_1
MD_Vol=li.2.V_2 + li.2.V_1
PM_Vol=li.3.V_2 + li.3.V_1
NT_Vol=li.4.V_2 + li.4.V_1
*/
AM_Vol=li.1.V_2 
MD_Vol=li.2.V_2
PM_Vol=li.3.V_2 
NT_Vol=li.4.V_2 
Total_Vol = AM_Vol + MD_Vol + PM_Vol + NT_Vol

; Drive Alone
AM_DA=li.1.V1_2 
MD_DA=li.2.V1_2 
PM_DA=li.3.V1_2 
NT_DA=li.4.V1_2 
TOTAL_DA = AM_DA + MD_DA + PM_DA + NT_DA

; ShareRide 2+
AM_SR=li.1.V2_2 
MD_SR=li.2.V2_2 
PM_SR=li.3.V2_2 
NT_SR=li.4.V2_2 
TOTAL_SR = AM_SR + MD_SR + PM_SR + NT_SR

; IEEI
AM_IEEI=li.1.V3_2 
MD_IEEI=li.2.V3_2 
PM_IEEI=li.3.V3_2 
NT_IEEI=li.4.V3_2 
TOTAL_IEEI = AM_IEEI + MD_IEEI + PM_IEEI + NT_IEEI

; Commercial Vehicles
AM_CV=li.1.V4_2 
MD_CV=li.2.V4_2 
PM_CV=li.3.V4_2 
NT_CV=li.4.V4_2 
TOTAL_CV = AM_CV + MD_CV + PM_CV + NT_CV

; EE
AM_EX=li.1.V1_1 
MD_EX=li.2.V1_1 
PM_EX=li.3.V1_1 
NT_EX=li.4.V1_1 
TOTAL_EX = AM_EX + MD_EX + PM_EX + NT_EX


; Select Link Volumes
sl_DA=li.1.V5_2 +li.2.V5_2 +li.3.V5_2 +li.4.V5_2  
sl_SR=li.1.V6_2 +li.2.V6_2 +li.3.V6_2 +li.4.V6_2  
sl_IEEI=li.1.V7_2 +li.2.V7_2 +li.3.V7_2 +li.4.V7_2  
sl_CV=li.1.V8_2 +li.2.V8_2 +li.3.V8_2 +li.4.V8_2  
sl_EE=li.1.V2_1 +li.2.V2_1 +li.3.V2_1 +li.4.V2_1  
sl_tot=sl_DA+ sl_SR +  sl_IEEI + sl_CV + sl_EE

;Sum period specific loaded attributes to all period (24 hour)...
VDT_1 = li.1.VDT_2 + li.2.VDT_2 + li.3.VDT_2 + li.4.VDT_2
VHT_1 = li.1.VHT_2 + li.2.VHT_2 + li.3.VHT_2 + li.4.VHT_2

if(VHT_2>0) 
  CSPD_2 = VDT_2/VHT_2
else 
  CSPD_2 = 0
endif

if(CSPD_2>0) 
  TIME_2 = 60*DISTANCE/CSPD_2 
else 
  TIME_2 = 60*DISTANCE/FFSPEED 
endif

; write out peak and off-peak congested time to use in feedback
SPEED_PK_CNG =  li.1.CSPD_2
TIME_PK_CNG = li.1.TIME_2
SPEED_OP_CNG =  li.2.CSPD_2
TIME_OP_CNG = li.2.TIME_2

; Group facility types
oft=LI.1.FACTYPE                                 ; Facility Type
if (oft = 1 | oft =2 | oft =9 | oft = 10) ft = 1 ; Freeway       
if (oft = 3 | oft =4)                     ft = 2 ; Major Arterial
if (oft = 5)                              ft = 3 ; Minor Arterial
if (oft = 6 | oft = 7 | oft = 8)          ft = 4 ; Collector + Local         
if (oft = 10)                             ft = 5 ; Connectors   

; Write a header file for links
 if (A=1) print CSV=T,list='ScreenLine', 'A','B','Area Type','Fac Type','Fac Type Group', 'FFSPEED', 'Count' ,'Volume','Distance', 'AM_Vol', 'MD_Vol',  'PM_Vol', 'NT_Vol',  'AM_VMT', 'MD_VMT' , 'PM_VMT' , 'NT_VMT',   
 'AM_VHT', 'MD_VHT' , 'PM_VHT' , 'NT_VHT', 'AM_Speed', 'MD_Speed' , 'PM_Speed' , 'NT_Speed' printo=1 
 
IF (Li.1.AAWDT>0)
 ; Write out links with counts
 print CSV=T list = LI.1.SCREENLN , LI.1.A, LI.1.B, LI.1.ATYPE, LI.1.FACTYPE, FT,  FFSPEED, LI.1.AAWDT, TOTAL_VOL, LI.1.DISTANCE,  AM_Vol, MD_Vol,  PM_Vol, NT_Vol, li.1.VDT_2, li.2.VDT_2, li.3.VDT_2 , li.4.VDT_2, li.1.VHT_2,  li.2.VHT_2,  li.3.VHT_2,  li.4.VHT_2, li.1.CSPD_2, li.2.CSPD_2, li.3.CSPD_2, li.4.CSPD_2 printo=1

 ENDIF
 
 
ENDPROCESS
ENDRUN


; Script for program NETWORK in file "C:\projects\roanoke\Cube\HighwayAssign_Evaluate.s"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\Hwy_eval.PRN"
FILEO PRINTO[2] = "{SCENARIO_DIR}\Output\Hwy_eval_links.csv"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\LOADED_{Year}{Alternative}.NET"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\Hwy_eval.csv"

; =========================================================
; LINKMERGE PHASE
; =========================================================
PHASE=LINKMERGE

; Netwok attribute information
LNS=LI.1.LANEs
TOTAL_VOL=ROUND(LI.1.TOTAL_VOL)     ; Total Volume
oft=LI.1.FACTYPE                     ; Facility Type
atg=LI.1.ATYPE                      ; Area Type

ftg=INT(LI.1.FACTYPE/10)
sl=LI.1.SCREENLN              ;MPO Scrreenline/Cutline

count=LI.1.AAWDT               ; Count
_countsum=_countsum+count      ;  
if ((count>0)&(sl=0)) sl=98    ; Counts with MPO Screenline/Cutline of ZERO are reported as SL/CL of 98

_distmile=DISTANCE                 ; distance in mile   
_ctimehr=TIME_1/60                 ; Congestime time in hour
VOLVMT=ROUND(TOTAL_VOL*_distmile)  ; VMT-Volume
VOLVHT=ROUND(TOTAL_VOL*_ctimehr)   ; VHT-Volume
CNTVMT=ROUND(count*_distmile)      ; VMT-Count
CNTVHT=ROUND(count*_ctimehr)       ; VHT-Count

; Group facility types
if (oft = 1 | oft =2 | oft =9 | oft = 10) ft = 1 ; Freeway       
if (oft = 3 | oft =4)                     ft = 2 ; Major Arterial
if (oft = 5)                              ft = 3 ; Minor Arterial
if (oft = 6 | oft = 7 | oft = 8)          ft = 4 ; Collector + Local         
if (oft = 10)                             ft = 5 ; Connectors    
 
; initialize arrays and variables
   ARRAY _err=10, _cns=10, _cnt=10, _RGP=10, _vols=10
   ARRAY FT_ERR=100, FT_CNS=100, FT_CNT=100, FT_VOLS=100
   
   ARRAY _lnkbyft=100, _volbyft=100, _cntbyft=100
   ARRAY _volbyftg=100, _volbyatg=100, _cntbyftg=100, _cntbyatg=100
   ARRAY _lnkbyftg=100, _lnkbyatg=100
   ARRAY _volbyLNS=100, _cntbyLNS=100, _lnkbyLNS=100
   ARRAY _volbysl=100, _cntbysl=100, _lnkbysl=100
   ARRAY _volbysl2=100, _cntbysl2=100, _lnkbysl2=100
   ARRAY _volbycord=1000, _cntbycord=1000, _lnkbycord=1000
   ARRAY _volbyscord=5000, _cntbyscord=5000, _lnkbyscord=5000
   ARRAY _volbycnty=100, _cntbycnty=100, _lnkbycnty=100

   ARRAY _vmtvbyft=100, _vmtcbyft=100
   ARRAY _vmtvbyftg=100, _vmtcbyftg=100
   ARRAY _vmtvbyatg=100, _vmtcbyatg=100
   ARRAY _vmtvbyLNS=100, _vmtcbyLNS=100
   ARRAY _vmtvbysl=100, _vmtcbysl=100
   ARRAY _vmtvbysl2=100, _vmtcbysl2=100
   ARRAY _vmtvbycnty=100, _vmtcbycnty=100  
   ARRAY _vmtvbycord=1000, _vmtcbycord=1000
   ARRAY _vmtvbyscord=5000, _vmtcbyscord=5000

   ARRAY _vhtvbyft=100, _vhtcbyft=100
   ARRAY _vhtvbyftg=100, _vhtcbyftg=100
   ARRAY _vhtvbyatg=100, _vhtcbyatg=100
   ARRAY _vhtvbyLNS=100, _vhtcbyLNS=100
   ARRAY _vhtvbysl=100, _vhtcbysl=100
   ARRAY _vhtvbysl2=100, _vhtcbysl2=100
   ARRAY _vhtvbycnty=100, _vhtcbycnty=100  
   ARRAY _vhtvbycord=1000, _vhtcbycord=1000
   ARRAY _vhtvbyscord=5000, _vhtcbyscord=5000

   _RGP[1]=1, _RGP[2]=5000, _RGP[3]=10000, _RGP[4]=15000, _RGP[5]=20000, _RGP[6]=30000, _RGP[7]=50000,
   _RGP[8]=60000, _RGP[9]=1000000
   
   IF (A=1)
     LOOP _iter=1,10
         _err[_iter]=0,_cnt[_iter]=0,_cns[_iter]=0,_vols[_iter]=0
     ENDLOOP

     LOOP _iter=1,100
           FT_ERR[_iter]=0, FT_CNS[_iter]=0, FT_CNT[_iter]=0, FT_VOLS[_iter]=0
           _volbyft[_iter]=0, _cntbyft[_iter]=0, _lnkbyft[_iter]=0
           _volbyftg[_iter]=0, _cntbyftg[_iter]=0, _lnkbyftg[_iter]=0
           _volbyatg[_iter]=0, _cntbyatg[_iter]=0, _lnkbyatg[_iter]=0
           _volbyLNS[_iter]=0, _cntbyLNS[_iter]=0, _lnkbyLNS[_iter]=0
           _volbysl[_iter]=0, _cntbysl[_iter]=0, _lnkbysl[_iter]=0
           _volbysl2[_iter]=0, _cntbysl2[_iter]=0, _lnkbysl2[_iter]=0
           _volbycnty[_iter]=0, _cntbycnty[_iter]=0, _lnkbycnty[_iter]=0

           _vmtvbyft[_iter]=0, _vmtcbyft[_iter]=0
           _vmtvbyftg[_iter]=0, _vmtcbyftg[_iter]=0
           _vmtvbyatg[_iter]=0, _vmtcbyatg[_iter]=0
           _vmtvbyLNS[_iter]=0, _vmtcbyLNS[_iter]=0
           _vmtvbysl[_iter]=0, _vmtcbysl[_iter]=0
           _vmtvbysl2[_iter]=0, _vmtcbysl2[_iter]=0
           _vmtvbycnty[_iter]=0, _vmtcbycnty[_iter]=0
           _vhtvbyft[_iter]=0, _vhtcbyft[_iter]=0
           _vhtvbyftg[_iter]=0, _vhtcbyftg[_iter]=0
           _vhtvbyatg[_iter]=0, _vhtcbyatg[_iter]=0
           _vhtvbyLNS[_iter]=0, _vhtcbyLNS[_iter]=0
           _vhtvbysl[_iter]=0, _vhtcbysl[_iter]=0
           _vhtvbysl2[_iter]=0, _vhtcbysl2[_iter]=0
           _vhtvbycnty[_iter]=0, _vhtcbycnty[_iter]=0
     ENDLOOP


     LOOP _iter=1,1000
           _volbycord[_iter]=0, _cntbycord[_iter]=0, _lnkbycord[_iter]=0

           _vmtvbycord[_iter]=0, _vmtcbycord[_iter]=0
           _vhtvbycord[_iter]=0, _vhtcbycord[_iter]=0
     ENDLOOP

     LOOP _iter=1,5000
         _volbyscord[_iter]=0, _cntbyscord[_iter]=0, _lnkbyscord[_iter]=0

         _vmtvbyscord[_iter]=0, _vmtcbyscord[_iter]=0
         _vhtvbyscord[_iter]=0, _vhtcbyscord[_iter]=0
     ENDLOOP

   ENDIF


; calculate and compartmentalize
   IF (COUNT>0) VOLCNT=TOTAL_VOL/COUNT, _TVOL=TOTAL_VOL, NETDIFF=TOTAL_VOL-COUNT, ABSDIFF=ABS(NETDIFF), ERRORSQ=NETDIFF^2, PCTDIFF=100*NETDIFF/COUNT, _group=1
   IF (COUNT>  5000) _group=2
   IF (COUNT> 10000) _group=3
   IF (COUNT> 15000) _group=4
   IF (COUNT> 20000) _group=5
   IF (COUNT> 30000) _group=6
   IF (COUNT> 50000) _group=7
   IF (COUNT> 60000) _group=8
   
   IF (COUNT>0)
     _ERR[_group]=ERRORSQ+_ERR[_group], _CNS[_group] = COUNT+_CNS[_group], _cnt[_group]= _cnt[_group]+1, _VOLS[_group]=_TVOL+_VOLS[_group]
     _ERR[9]=ERRORSQ+_ERR[9], _CNS[9]=COUNT+_CNS[9], _CNT[9]=_CNT[9]+1, _VOLS[9]=_TVOL+_VOLS[9]
     
     FT_ERR[ft]=ERRORSQ+ FT_ERR[ft], FT_CNS[ft]=COUNT+FT_CNS[ft], FT_CNT[ft]=FT_CNT[ft]+1, FT_VOLS[ft]=_TVOL+FT_VOLS[ft]
     FT_ERR[100]=ERRORSQ+FT_ERR[100], FT_CNS[100]=COUNT+FT_CNS[100], FT_CNT[100]=FT_CNT[100]+1, FT_VOLS[100]=_TVOL+FT_VOLS[100]
   ENDIF

  ; Write a header file for links
 if (A=1) print CSV=T,list='ScreenLine', 'A','B','Area Type','Fac Type','Fac Type Group','Volume','Count','Distance' printo=2   
   
IF (COUNT>0)

;2-digit FT
   _volbyft[ft]=_volbyft[ft]+TOTAL_VOL
   _cntbyft[ft]=_cntbyft[ft]+COUNT
   _vmtvbyft[ft]=_vmtvbyft[ft]+VOLVMT
   _vmtcbyft[ft]=_vmtcbyft[ft]+CNTVMT
   _vhtvbyft[ft]=_vhtvbyft[ft]+VOLVHT
   _vhtcbyft[ft]=_vhtcbyft[ft]+CNTVHT
   _lnkbyft[ft]=_lnkbyft[ft]+1

   _volbyft[100]=_volbyft[100]+TOTAL_VOL
   _cntbyft[100]=_cntbyft[100]+COUNT
   _vmtvbyft[100]=_vmtvbyft[100]+VOLVMT
   _vmtcbyft[100]=_vmtcbyft[100]+CNTVMT
   _vhtvbyft[100]=_vhtvbyft[100]+VOLVHT
   _vhtcbyft[100]=_vhtcbyft[100]+CNTVHT
   _lnkbyft[100]=_lnkbyft[100]+1

;1-digit FTG
   _volbyftg[ftg]=_volbyftg[ftg]+TOTAL_VOL
   _cntbyftg[ftg]=_cntbyftg[ftg]+COUNT
   _vmtvbyftg[ftg]=_vmtvbyftg[ftg]+VOLVMT
   _vmtcbyftg[ftg]=_vmtcbyftg[ftg]+CNTVMT
   _vhtvbyftg[ftg]=_vhtvbyftg[ftg]+VOLVHT
   _vhtcbyftg[ftg]=_vhtcbyftg[ftg]+CNTVHT
   _lnkbyftg[ftg]=_lnkbyftg[ftg]+1

   _volbyftg[100]=_volbyftg[100]+TOTAL_VOL
   _cntbyftg[100]=_cntbyftg[100]+COUNT
   _vmtvbyftg[100]=_vmtvbyftg[100]+VOLVMT
   _vmtcbyftg[100]=_vmtcbyftg[100]+CNTVMT
   _vhtvbyftg[100]=_vhtvbyftg[100]+VOLVHT
   _vhtcbyftg[100]=_vhtcbyftg[100]+CNTVHT
   _lnkbyftg[100]=_lnkbyftg[100]+1

;1-digit AT
   _volbyatg[atg]=_volbyatg[atg]+TOTAL_VOL
   _cntbyatg[atg]=_cntbyatg[atg]+COUNT
   _vmtvbyatg[atg]=_vmtvbyatg[atg]+VOLVMT
   _vmtcbyatg[atg]=_vmtcbyatg[atg]+CNTVMT
   _vhtvbyatg[atg]=_vhtvbyatg[atg]+VOLVHT
   _vhtcbyatg[atg]=_vhtcbyatg[atg]+CNTVHT
   _lnkbyatg[atg]=_lnkbyatg[atg]+1

   _volbyatg[100]=_volbyatg[100]+TOTAL_VOL
   _cntbyatg[100]=_cntbyatg[100]+COUNT
   _vmtvbyatg[100]=_vmtvbyatg[100]+VOLVMT
   _vmtcbyatg[100]=_vmtcbyatg[100]+CNTVMT
   _vhtvbyatg[100]=_vhtvbyatg[100]+VOLVHT
   _vhtcbyatg[100]=_vhtcbyatg[100]+CNTVHT
   _lnkbyatg[100]=_lnkbyatg[100]+1

;No of Lanes
   _volbyLNS[LNS]=_volbyLNS[LNS]+TOTAL_VOL
   _cntbyLNS[LNS]=_cntbyLNS[LNS]+COUNT
   _vmtvbyLNS[LNS]=_vmtvbyLNS[LNS]+VOLVMT
   _vmtcbyLNS[LNS]=_vmtcbyLNS[LNS]+CNTVMT
   _vhtvbyLNS[LNS]=_vhtvbyLNS[LNS]+VOLVHT
   _vhtcbyLNS[LNS]=_vhtcbyLNS[LNS]+CNTVHT
   _lnkbyLNS[LNS]=_lnkbyLNS[LNS]+1

   _volbyLNS[100]=_volbyLNS[100]+TOTAL_VOL
   _cntbyLNS[100]=_cntbyLNS[100]+COUNT
   _vmtvbyLNS[100]=_vmtvbyLNS[100]+VOLVMT
   _vmtcbyLNS[100]=_vmtcbyLNS[100]+CNTVMT
   _vhtvbyLNS[100]=_vhtvbyLNS[100]+VOLVHT
   _vhtcbyLNS[100]=_vhtcbyLNS[100]+CNTVHT
   _lnkbyLNS[100]=_lnkbyLNS[100]+1

;MPO Screenline/Cutline
   _volbysl[sl]=_volbysl[sl]+TOTAL_VOL
   _cntbysl[sl]=_cntbysl[sl]+COUNT
   _vmtvbysl[sl]=_vmtvbysl[sl]+VOLVMT
   _vmtcbysl[sl]=_vmtcbysl[sl]+CNTVMT
   _vhtvbysl[sl]=_vhtvbysl[sl]+VOLVHT
   _vhtcbysl[sl]=_vhtcbysl[sl]+CNTVHT
   _lnkbysl[sl]=_lnkbysl[sl]+1

   _volbysl[100]=_volbysl[100]+TOTAL_VOL
   _cntbysl[100]=_cntbysl[100]+COUNT
   _vmtvbysl[100]=_vmtvbysl[100]+VOLVMT
   _vmtcbysl[100]=_vmtcbysl[100]+CNTVMT
   _vhtvbysl[100]=_vhtvbysl[100]+VOLVHT
   _vhtcbysl[100]=_vhtcbysl[100]+CNTVHT
   _lnkbysl[100]=_lnkbysl[100]+1

   
   
 ; Write out links with counts
 print CSV=T list = LI.1.SCREENLN , LI.1.A, LI.1.B, LI.1.ATYPE, LI.1.FACTYPE, FT,  LI.1.TOTAL_VOL, LI.1.AAWDT, LI.1.DISTANCE printo=2

endif


ENDPHASE

; =========================================================
; SUMMARY REPORTING
; =========================================================
PHASE=SUMMARY

if (_countsum>0)   ;condition on _countsum>0

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ Loop to write out the Percent Root Mean Square Error
LOOP _iter=1,8

   if (_iter=1) vol_label = '    1 -  5000', _limit='100'
   if (_iter=2) vol_label = ' 5000 - 10000', _limit=' 45'
   if (_iter=3) vol_label = '10000 - 15000', _limit=' 35'
   if (_iter=4) vol_label = '15000 - 20000', _limit=' 30'
   if (_iter=5) vol_label = '20000 - 30000', _limit=' 27'
   if (_iter=6) vol_label = '30000 - 50000', _limit=' 25'
   if (_iter=7) vol_label = '50000 - 60000', _limit=' 20'
   if (_iter=8) vol_label = 'Above 60000' , _limit=' 19'
   
   ; Write header
   if (_iter=1) print CSV=T, list = 'ALL DAY: Volume Count Deviation Summary' printo=1
   if (_iter=1) print CSV=T, list = '\n A. Volume Count % Diff By Volume Group' printo=1
   if (_iter=1) print CSV=T, list = '\n Vol Grp', 'Count Range', 'Volume', 'Count',  'Model Dev(%)', 'Target', 'No of Links' printo=1
  
   if (_cnt[_iter]>0) print CSV=T, 
   list= _iter(2.0c),   
            vol_label,
            _vols[_iter],
            _cns[_iter],
            ((_VOLS[_iter]/_cns[_iter])-1)*100,
            _limit,
            _cnt[_iter] PRINTO=1

ENDLOOP    

_iter=9, vol_label = 'All ', _limit=' 10'
  print CSV=T,  list = _iter(2.0c),  
          vol_label, 
          _vols[_iter],
 					_cns[_iter],
          ((_VOLS[_iter]/_cns[_iter])-1)*100,
          _limit,
          _cnt[_iter], PRINTO=1
 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Summary for Vol/Cnt by FT2 
_iter=0
LOOP _iter=1,100

   if (_iter=1) _limit=' 20%' , fac_Label = 'Freeway          ', pct_diff =  '7%'
   if (_iter=2) _limit=' 35%' , fac_Label = 'Major Arterial   ', pct_diff = '10%'
   if (_iter=3) _limit=' 50%' , fac_Label = 'Minor Arterial   ', pct_diff = '15%'
   if (_iter=4) _limit=' 90%' , fac_Label = 'Collector & Local', pct_diff = '25%'    
   if (_iter=5) _limit=' 50%' , fac_Label = 'Connectors       ', pct_diff = ' NA'
   if (_iter=100) _limit=' 20%', fac_Label = 'Total           ', pct_diff = '10%'

  ; -- Volume and Count difference by Facility types
  if (_iter=1) print list="\n","\n B. Volume Count  % Diff  by Facility Type " PRINTO=1
  if (_iter=1) print CSV=T,list='Type','FT2 Grp','No of Links','Volume','Count','Target % Deviation','Model % Deviation' printo=1
   
  if ((_cntbyft[_iter]>0)&(_iter<100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
          pct_diff,
          ((_volbyft[_iter]/_cntbyft[_iter]) -1)*100 PRINTO=1
     
 if (_iter=100) _limit=' 30- 40%'
  ENDLOOP
  
_iter=100   
 if ((_cntbyft[100]>0)&(_iter=100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,  
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
           pct_diff,
          ((_volbyft[_iter]/_cntbyft[_iter])-1)*100 PRINTO=1
       

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; --  Volume and Count RMSE difference by Facility types  
_iter=0
LOOP _iter=1,100

   if (_iter=1) _limit=' 20%' , fac_Label = 'Freeway          ', pct_diff =  '7%'
   if (_iter=2) _limit=' 35%' , fac_Label = 'Major Arterial   ', pct_diff = '10%'
   if (_iter=3) _limit=' 50%' , fac_Label = 'Minor Arterial   ', pct_diff = '15%'
   if (_iter=4) _limit=' 90%' , fac_Label = 'Collector & Local', pct_diff = '25%'    
   if (_iter=5) _limit=' 50%' , fac_Label = 'Connectors       ', pct_diff = ' NA'
   if (_iter=100) _limit=' 20%', fac_Label = 'Total           ', pct_diff = '10%'

; -- Volume and Count difference by Facility types
if (_iter=1) print list="\n","\n B. Volume and Count RMSE by Facility Type" PRINTO=1
if (_iter=1) print CSV=T,list='Type','FT2 Grp','No of Links','Volume','Count','TARGET RMSE','MODEL RMSE' printo=1 

  if ((_cntbyft[_iter]>0)&(_iter<100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
          _limit,     
          sqrt(FT_err[_iter]/(FT_cnt[_iter]-1))/(FT_cns[_iter]/FT_cnt[_iter])*100 PRINTO=1
     
 if (_iter=100) _limit=' 30- 40%'
  ENDLOOP
  
_iter=100   
 if ((_cntbyft[100]>0)&(_iter=100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,  
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
          _limit,     
          sqrt(FT_err[_iter]/(FT_cnt[_iter]-1))/(FT_cns[_iter]/FT_cnt[_iter])*100 PRINTO=1
                  
 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Summary for Vol/Cnt by FT1 
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n C. VOLUME AND COUNT SUMMARY BY 1-DIGIT FACILITY TYPE ", PRINTO=1
  if (_iter=1) print CSV=T,list='FT Grp','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 
  
  if ((_cntbyftg[_iter]>0)&(_iter<100)) print CSV=T,
    list=_iter(3.0c),
         _lnkbyftg[_iter],
         _volbyftg[_iter],
         _cntbyftg[_iter],
         ((_volbyftg[_iter]/_cntbyftg[_iter])-1)*100,

         _vmtvbyftg[_iter],
         _vmtcbyftg[_iter],
         ((_vmtvbyftg[_iter]/_vmtcbyftg[_iter])-1)*100,

         _vhtvbyftg[_iter],
         _vhtcbyftg[_iter],
         ((_vhtvbyftg[_iter]/_vhtcbyftg[_iter])-1)*100, PRINTO=1
     

 if ((_cntbyftg[100]>0)&(_iter=100))  print CSV=T,
    list= "ALL",
     _lnkbyftg[_iter],
     _volbyftg[_iter],
     _cntbyftg[_iter],
     ((_volbyftg[_iter]/_cntbyftg[_iter])-1)*100,
     _vmtvbyftg[_iter],
     _vmtcbyftg[_iter],
     ((_vmtvbyftg[_iter]/_vmtcbyftg[_iter])-1)*100,
     _vhtvbyftg[_iter],
     _vhtcbyftg[_iter],
     ((_vhtvbyftg[_iter]/_vhtcbyftg[_iter])-1)*100, PRINTO=1

ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ Summary for for Vol/Cnt by AT1
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n D. VOLUME AND COUNT SUMMARY BY 1-DIGIT AREA TYPE", PRINTO=1
  if (_iter=1) print CSV=T,list='AT Grp','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 


  if ((_cntbyatg[_iter]>0)&(_iter<100)) print CSV=T,
    list=_iter(3.0c),
         _lnkbyatg[_iter],

         _volbyatg[_iter],
         _cntbyatg[_iter],
         ((_volbyatg[_iter]/_cntbyatg[_iter])-1)*100,

         _vmtvbyatg[_iter],
         _vmtcbyatg[_iter],
         ((_vmtvbyatg[_iter]/_vmtcbyatg[_iter])-1)*100,

         _vhtvbyatg[_iter],
         _vhtcbyatg[_iter],
         ((_vhtvbyatg[_iter]/_vhtcbyatg[_iter])-1)*100, PRINTO=1


 if ((_cntbyatg[100]>0)&(_iter=100)) print CSV=T,
    list= "ALL",
         _lnkbyatg[_iter],

         _volbyatg[_iter],
         _cntbyatg[_iter],
         ((_volbyatg[_iter]/_cntbyatg[_iter])-1)*100,

         _vmtvbyatg[_iter],
         _vmtcbyatg[_iter],
         ((_vmtvbyatg[_iter]/_vmtcbyatg[_iter])-1)*100,

         _vhtvbyatg[_iter],
         _vhtcbyatg[_iter],
         ((_vhtvbyatg[_iter]/_vhtcbyatg[_iter])-1)*100, PRINTO=1

ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ one for Vol/Cnt by LNS 
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n E. VOLUME AND COUNT SUMMARY BY LANES PER DIRECTION ", PRINTO=1
  if (_iter=1) print CSV=T,list='Lanes/Direction','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 

  if ((_cntbyLNS[_iter]>0)&(_iter<100)) print CSV=T,
    list=_iter(3.0c),
         _lnkbyLNS[_iter],

         _volbyLNS[_iter],
         _cntbyLNS[_iter],
         ((_volbyLNS[_iter]/_cntbyLNS[_iter])-1)*100,

         _vmtvbyLNS[_iter],
         _vmtcbyLNS[_iter],
         ((_vmtvbyLNS[_iter]/_vmtcbyLNS[_iter])-1)*100,
         
         _vhtvbyLNS[_iter],
         _vhtcbyLNS[_iter],
         ((_vhtvbyLNS[_iter]/_vhtcbyLNS[_iter])-1)*100, PRINTO=1

 if ((_cntbyLNS[100]>0)&(_iter=100)) print CSV=T,
    list= "ALL",
         _lnkbyLNS[_iter],

         _volbyLNS[_iter],
         _cntbyLNS[_iter],
         ((_volbyLNS[_iter]/_cntbyLNS[_iter])-1)*100,

         _vmtvbyLNS[_iter],
         _vmtcbyLNS[_iter],
         ((_vmtvbyLNS[_iter]/_vmtcbyLNS[_iter])-1)*100,
         
         _vhtvbyLNS[_iter],
         _vhtcbyLNS[_iter],
         ((_vhtvbyLNS[_iter]/_vhtcbyLNS[_iter])-1)*100, PRINTO=1

ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ one for Vol/Cnt by SL (MPO Scrrenline/Cutline)
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n F. VOLUME AND COUNT SUMMARY BY MPO SCREENLINE & CUTLINE ", PRINTO=1
  if (_iter=1) print CSV=T,list='Screen/Cut-Line','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 
                                 
  if ((_cntbySL[_iter]>0)&(_iter<100)) print CSV=T,
    list= _iter(3.0c),
          _lnkbySL[_iter],

          _volbySL[_iter],
          _cntbySL[_iter],
          ((_volbySL[_iter]/_cntbySL[_iter])-1)*100,

          _vmtvbySL[_iter],
          _vmtcbySL[_iter],
          ((_vmtvbySL[_iter]/_vmtcbySL[_iter])-1)*100,

          _vhtvbySL[_iter],
          _vhtcbySL[_iter],
          ((_vhtvbySL[_iter]/_vhtcbySL[_iter])-1)*100, PRINTO=1
 
 if ((_cntbySL[100]>0)&(_iter=100)) print CSV=T,
    list= "ALL",
          _lnkbySL[_iter],

          _volbySL[_iter],
          _cntbySL[_iter],
          ((_volbySL[_iter]/_cntbySL[_iter])-1)*100,

          _vmtvbySL[_iter],
          _vmtcbySL[_iter],
          ((_vmtvbySL[_iter]/_vmtcbySL[_iter])-1)*100,

          _vhtvbySL[_iter],
          _vhtcbySL[_iter],
          ((_vhtvbySL[_iter]/_vhtcbySL[_iter])-1)*100, 
 "\n Note: Counts with MPO Screenline/Cutline of ZERO are reported as SL/CL of 98", PRINTO=1


ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

endif ; condition on _countsum>0

ENDPHASE

ENDRUN


