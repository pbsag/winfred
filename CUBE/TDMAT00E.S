; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonwork_TLFD_HBO.PRN" MSG='Non-Work Trip Length Frequency HBO'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBO.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\OP_Hwyskim.MAT"
FILEO RECO[1] = "{SCENARIO_DIR}\Output\HBO_TDLF.dbf",
  FIELDS= HIGH, MID, LOW, TRIPS(16.8)
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\HBO_TDLF.PRN"

  MW[1]=MI.1.HBO
  MW[2]=MI.2.Distance
  MW[3]=MI.2.Time
  gps=22-1
  Array trips=22
           
  ; Distance
  JLOOP
    ;group = min(max(round(mw[2]),1),50)
    group = min(INT(mw[2]/1),gps) + 1
    trips[group]=trips[group]+mw[1]
  ENDJLOOP
          
  IF (i=zones)
    LOOP group=1,22
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
