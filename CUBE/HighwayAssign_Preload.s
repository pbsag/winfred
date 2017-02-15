; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\HighwayAssign_Preload_@PERIOD_NAME@.PRN" MSG='Preload External Trips'
FILEI TURNPENI = "{SCENARIO_DIR}\Input\TurnPenalties.pen"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\SL_Preloaded_@PERIOD_NAME@.MAT",
MO=2, NAME=SL_EE
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
   IF (LI.TRAFF_PHB = 'Y') ADDTOGROUP = 1
 
ENDPHASE

PHASE=ILOOP
  ; Assign EE trips 
  PATHLOAD PATH=LW.COSTa,  MW[1] = MI.1.5, VOL[1] = MW[1], 
     MW[2] = MI.1.5, SELECTLINK=({SelectLink}), VOL[2]=MW[2] , EXCLUDEGROUP=1
                                                                         
ENDPHASE
PHASE=ADJUST
FUNCTION { V =VOL[1] }
ENDPHASE


ENDRUN
