; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\BuildWalkAccessConenctors.PRN" MSG='Build Walk Access Connectors'
FILEO REPORTO = "{SCENARIO_DIR}\Output\LOGS\TNPTR00B.PRN"
FILEO NTLEGO = "{SCENARIO_DIR}\Output\NTLEG.TEM"
FILEO NETO = "{SCENARIO_DIR}\Output\NTLEG.NET"
FILEI FACTORI[1] = "{CATALOG_DIR}\Params\transit\WalkPrem.FAC"
FILEI FAREI = "{CATALOG_DIR}\Params\transit\TFARES.FAR"
FILEI SYSTEMI = "{CATALOG_DIR}\Params\transit\TSYSD.PTS"
FILEI LINEI[1] = "{SCENARIO_DIR}\Input\TROUTE.LIN"
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
