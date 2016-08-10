
RUN PGM=NETWORK
 ; FILEI LINKI[1]="2005HWYLOAD.NET"
  FILEI LINKI[1]="C:\projects\roanoke\master_network.mdb\HWNetwork"
  FILEO LINKO="C:\projects\roanoke\2040_hwy_ShapeFile\HWNetwork_Link.SHP" FORMAT=SHP
  FILEO NODEO="C:\projects\roanoke\2040_hwy_ShapeFile\HWNetwork_Node.SHP" FORMAT=SHP
ENDRUN