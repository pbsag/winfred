; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\Output\Logs\FreeFlowSpeeds.PRN" MSG='Build Initial Skims'
FILEI NETI = "{SCENARIO_DIR}\Output\Interim{Year}{Alternative}.net"
FILEI TURNPENI = "{SCENARIO_DIR}\Input\TurnPenalties.pen"
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\ZONAL AT{Year}{Alternative}.DBF",
Z = N
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\Term_Time.dbf"

FILEO MATO[1] = "{SCENARIO_DIR}\Output\IMPED11.MAT",
      MO=1-5, NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME,
      DEC=2,2,0,0,2

;# lookup table for terminal times based on area type
LOOKUP LOOKUPI=1, NAME=Term_Time,
         LOOKUP[1]=ATYPE, RESULT=OTIME,
         LOOKUP[2]=ATYPE, RESULT=DTIME,
       FAIL[3]=0
; example of use: v=Term_Time(2,25)
; look for 25 in the ATYPE field and returns the DTIME value


PARAMETERS  ZONES={Total Zones}



PROCESS PHASE=LINKREAD

  ; use FF_SPEED as speed for initial skim
  SPEED = LI.FFSPEED

ENDPROCESS

PROCESS PHASE=ILOOP

  ;# skim network for time and distance
  PATH=COST,MW[1]=PATHTRACE(TIME,1),MW[2]=PATHTRACE(LI.DISTANCE)
  MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time is half of the time to the nearest zone.
  MW[2][I] = 0                ; Set Intrazonal Dist = 0

  IF(i < {Internal Zones})  ;# terminal times only exist for internal Zones
    JLOOP
      MW[3] = Term_Time(1, zi.1.ATYPE[i])       ;origin terminal time
      MW[4] = Term_Time(2, zi.1.ATYPE[j])       ;destination terminal time
    ENDJLOOP
  ELSE ;# external stations
    MW[3] = 0
    MW[4] = 0
  ENDIF

  ;# Total Impedance including terminal times
  MW[5] = MW[1]+MW[3]+MW[4]

ENDPROCESS

ENDRUN
