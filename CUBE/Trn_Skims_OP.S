;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\Trn_Skims_OP.PRN" MSG='OP-Walk Access Paths / Skims'
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
