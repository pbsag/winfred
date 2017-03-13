; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\HighwayAssign_Preload_@PERIOD_NAME@.PRN" MSG='Preload External Trips'
FILEI TURNPENI = "{SCENARIO_DIR}\Input\TurnPenalties.pen"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\SL_Preloaded_@PERIOD_NAME@.MAT",
MO=3-4, NAME=SL_EE_AUTO,SL_EE_TRK
FILEI NETI = "{SCENARIO_DIR}\Output\Interim{Year}{Alternative}.NET"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\ODAUTO_@PERIOD_NAME@.MAT"
FILEO PATHO[1] = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.PTH"
FILEO NETO = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.NET",
      DEC = 0

;Set run PARAMETERS and Controls
PARAMETERS ZONES={Total ZONES}, MAXITERS=1, COMBINE=EQUI, GAP= 0.0, RELATIVEGAP = 0.00001

PHASE=LINKREAD

   T0 = 60* (LI.DISTANCE/LI.FFSPEED)
   C  = LI.CAPE_@PERIOD_NAME@
   LW.COSTa = T0 + 0.25*LI.DISTANCE
   LW.COSTb = T0 + 0.25*LI.DISTANCE
   IF (LI.TRAFF_PHB = 'N') ADDTOGROUP = 1
 
ENDPHASE

PHASE=ILOOP
  ; Assign EE trips 
  PATHLOAD PATH=LW.COSTa,  MW[1] = MI.1.5, VOL[1] = MW[1], PENI = 1,
     MW[3] = MI.1.5, SELECTLINK=({SelectLink}), VOL[3]=MW[3] , EXCLUDEGROUP=1
  PATHLOAD PATH=LW.COSTb,  MW[2] = MI.1.6, VOL[2] = MW[2], PENI = 1,
     MW[4] = MI.1.6, SELECTLINK=({SelectLink}), VOL[4]=MW[4] , EXCLUDEGROUP=1
                                                                         
ENDPHASE
PHASE=ADJUST
FUNCTION { V =VOL[1]+VOL[2] }
ENDPHASE


ENDRUN
