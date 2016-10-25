;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EEMAT00B.PRN"
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\IEEI_AdjustedTrips.DBF",
fields=ZONE,AADT,EE_Total,IEEI
FILEI ZDATI[1] = "{SCENARIO_DIR}\INPUT\EXTERNALTRIPS.DBF"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"  ;Seed EE trip table after growth for given year are applied

; Sum EE productions and Attractions
; Adjust for AADT ?????
; Tabulate IEEI as difference between AADT and EE Total Trips grown to current year

; Working matrices specified to cause generation of matrix control totals
MW[1]=mi.1.1
MW[2]=mi.1.1.t 

IF( I > {Internal Zones})
  RO.PROD1=ROWSUM(1)    
  RO.ATTR1=ROWSUM(2)
  RO.ZONE=I
  RO.EE_Total = RO.PROD1 + RO.ATTR1
  RO.AADT = ZI.1.EXTTOTAL * ZI.1.GRWTH
  RO.IEEI = RO.AADT - RO.EE_Total
  
WRITE RECO=1
ENDIF

ENDRUN
