; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonWork_TLFD_Time_NHB.PRN" MSG='Non-Work Trip Time Frequency NHB'
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\NHB_TIME_TDLF.DBF",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\OP_HWYSKIM.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\DEST_NHB.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\NHB_TIME_TDLF.PRN"

             MW[1]=MI.1.NHB
             MW[2]=MI.2.Total_Time
             gps=26-1
             Array trips=36
             
             ; Time
             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[2]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,36
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=2 VALUEMW=1 RANGE=0-100-1 

ENDRUN
