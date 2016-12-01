;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EEMAT00B.PRN" MSG='Apply Growth Rates to IEEI'
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\IEEI_AdjustedTrips.DBF",
fields=ZONE,AADT,EE_Total,IEEI
FILEI ZDATI[1] = "{SCENARIO_DIR}\INPUT\EXTERNALTRIPS.DBF"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"

; Sum EE productions and Attractions
; Adjust totals at external stations by the same growth factor as was used to adjust EE trips 
;    to generate future AADT totals at external stations (adjustment is 1 for base year)
; Tabulate IEEI as difference between future AADT and future EE total trips

;;NOTE----this approach assumes that the growth applied to an external 
;;     station is the same for EE as it is for IEEI trips at that same station.

; Working matrices to allow calculation of production and attraction totals
MW[1]=mi.1.1
MW[2]=mi.1.1.t 

IF( I > {Internal Zones})
  RO.PROD1=ROWSUM(1)    
  RO.ATTR1=ROWSUM(2)
  RO.ZONE=I
  RO.EE_Total = (RO.PROD1 + RO.ATTR1)/2 
  RO.AADT = ZI.1.EXTTOTAL * ZI.1.GRWTH
  RO.IEEI = RO.AADT - RO.EE_Total
  
WRITE RECO=1
ENDIF

ENDRUN
