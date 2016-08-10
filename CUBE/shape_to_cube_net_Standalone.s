
RUN PGM=CUBE Parameters='/Command /CloseWhenDone /Minimize /NoSplash'

  function=SHAPE2NETWORK
    shpi="C:\projects\roanoke\MasterNetwork\Master_Node.SHP" ; point shape
    shpi="C:\projects\roanoke\MasterNetwork\Master_Link.SHP" ; line shape
    neto="C:\projects\roanoke\MasterNetwork\Master_highway.net"
    PointNodeNumField="N"
    AnodeField=A
    BnodeField=B
    LevelField=""
    ClearABValues=T
    DirectionOption=1
    DirectionField=""
    AddDistanceField=N
    DistanceScale=2.22
    NodeGroupingLimit=1
    StartingNewNode=1000
    HighestZone=270
  
  endfunction
  
ENDRUN
