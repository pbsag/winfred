; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\CV_TLFD.PRN" MSG='Trip Length Frequency'
FILEO RECO[3] = "{SCENARIO_DIR}\OUTPUT\TLFD_MUT.DBF",
FIELDS= HIGH,MID,MLOW,MUT_TRIPS(16.8)
FILEO RECO[2] = "{SCENARIO_DIR}\OUTPUT\TLFD_SUT.DBF",
FIELDS= HIGH,MID,LOW,SUT_TRIPS(16.8)
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\TLFD_CV.DBF",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\CV_{Year}.MAT"
FILEO PRINTO[1] = "C:\projects\winfred\CUBE\CVMAT00B.PRN"

             MW[1]=MI.1.1
             MW[2]=MI.1.2
             MW[3]=MI.1.3
             MW[4]=MI.2.Time
             gps=40-1
             Array trips=40, sut_trips = 40, mut_trips =40           

             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=1 RANGE=0-100-1 

             ; SUT
              JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             SUT_trips[group]=SUT_trips[group]+mw[2]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.SUT_TRIPS=SUT_trips[group]
                write reco=2
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.SUT_TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=2 RANGE=0-100-1 
             
              ; MUT
              JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             MUT_trips[group]=MUT_trips[group]+mw[3]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.MUT_TRIPS=MUT_trips[group]
                write reco=3
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.MUT_TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=3 RANGE=0-100-1             
            
ENDRUN
