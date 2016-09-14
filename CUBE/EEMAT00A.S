;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\EXTERNALTRIPS.DBF",
fields=ZONE,AADT,EE_Total,IEEI
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\EXTERNALTRIPS.DBF"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"

MW[1]=mi.1.1
MW[2]=mi.1.1.t 

IF( I >= {Internal Zones})
  RO.PROD1=ROWSUM(1)
  RO.ATTR1=ROWSUM(2)
  RO.ZONE=I
  RO.EE_Total = RO.PROD1 + RO.ATTR1
  RO.AADT = ZI.1.EXTTOTAL * ZI.1.AADT_FAC
  RO.IEEI = RO.AADT - RO.EE_Total
  
WRITE RECO=1
ENDIF

ENDRUN
