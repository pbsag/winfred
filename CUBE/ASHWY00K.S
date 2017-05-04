; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\Output\Logs\HighwayAssign_PM.PRN" MSG='Load Final Trips onto Network PM'
FILEI TURNPENI = "{SCENARIO_DIR}\INPUT\TURNPENALTIES.PEN"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\SL_LOADED_PM.MAT",
MO=6-10, NAME=SL_DA,SL_SR,SL_IEEI, SL_CV, SL_CV_MUT
FILEI NETI = "{SCENARIO_DIR}\OUTPUT\PRELOADED_PM.NET"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\ODAUTO_PM.MAT"
FILEO NETO = "{SCENARIO_DIR}\OUTPUT\LOADED_PM.NET",
      DEC = 0

;Set run PARAMETERS and Controls
PARAMETERS ZONES={Total ZONES}, MAXITERS=500, COMBINE=EQUI, GAP= 0.0, RELATIVEGAP = 0.00001
PCE=1.5

PHASE=LINKREAD
    LW.EEVOL = LI.V_1 
    
   T0 = 60* (LI.DISTANCE/LI.FFSPEED)
  ; T0 = 60* (LI.DISTANCE/LI.POST_SPEED)
  C  = LI.CAPE_PM

  LW.COSTa = T0 + 0.25*LI.DISTANCE
  LW.COSTb = T0 + 0.25*LI.DISTANCE
  LW.COSTc = T0 + 0.25*LI.DISTANCE
  LW.COSTd = T0 + 0.25*LI.DISTANCE
    LW.COSTe = T0 + 0.25*LI.DISTANCE
  IF (LI.TRAFF_PHB = 'N') ADDTOGROUP = 1
  
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
  IF(LI.FACTYPE=1,2,9)    LINKCLASS=1 ; Freeway
  IF(LI.FACTYPE=3,4)    LINKCLASS=2 ; Major Arterial
  IF(LI.FACTYPE=5,10)      LINKCLASS=3 ; Minor Arterial
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
  PATHLOAD PATH=LW.COSTa , MW[1] = MI.1.1, VOL[1] = MW[1],  PENI = 1,
      MW[6] = MI.1.1, SELECTLINK=({SelectLink}), VOL[6]=MW[6] ,EXCLUDEGROUP = 1
  PATHLOAD PATH=LW.COSTb , MW[2] = MI.1.2, VOL[2] = MW[2],  PENI = 1, 
      MW[7] = MI.1.2, SELECTLINK=({SelectLink}), VOL[7]=MW[7]  ,EXCLUDEGROUP = 1
  PATHLOAD PATH=LW.COSTc , MW[3] = MI.1.3, VOL[3] = MW[3],  PENI = 1,
      MW[8] = MI.1.3, SELECTLINK=({SelectLink}), VOL[8]=MW[8]  ,EXCLUDEGROUP = 1
  PATHLOAD PATH=LW.COSTd , MW[4] = MI.1.4, VOL[4] = MW[4],  PENI = 1,
      MW[9] = MI.1.4, SELECTLINK=({SelectLink}), VOL[9]=MW[9]  ,EXCLUDEGROUP = 1
  PATHLOAD PATH=LW.COSTd , MW[5] = MI.1.7*PCE, VOL[5] = MW[5],  PENI = 1,
      MW[10] = MI.1.7*PCE, SELECTLINK=({SelectLink}), VOL[10]=MW[10]  ,EXCLUDEGROUP = 1
  
ENDPHASE

PHASE=ADJUST

function {
    V=VOL[1]+VOL[2]+VOL[3]+VOL[4]+VOL[5]+  LW.EEVOL ; Add preloaded EE Volumes here
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
  LW.COSTe=TIME + 0.25*LI.DISTANCE  
ENDPHASE
ENDRUN
