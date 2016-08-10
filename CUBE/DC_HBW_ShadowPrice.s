;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Shadow Price'

FILEI ZDATI[1] = "{SCENARIO_DIR}\OUTPUT\HBW_shadowPrice.DBF"
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\HBW_shadowPrice.DBF",
 fields=Z,PROD1,ATTR1,SizeTerm,Shadow_price
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"

MW[1]=mi.1.1
MW[2]=mi.1.1.t
MW[3]=mi.1.2

RO.PROD1=ROWSUM(1)
RO.ATTR1=ROWSUM(2)
RO.Z=I
RO.SizeTerm = MW[3][I]
Ro.prev =  ZI.1.SHADOW_PRIC 

IF (RO.ATTR1 > 0 )
  RO.Shadow_price = Ro.prev + LOG(MW[3][I]/RO.ATTR1)
ENDIF

WRITE RECO=1
ENDRUN
