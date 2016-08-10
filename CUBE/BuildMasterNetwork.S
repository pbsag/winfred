; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
PRINT FORM=5.0,
    list =  "function=SHAPE2NETWORK",
    "\n shpi=", '{CATALOG_DIR}', "\MasterNetwork\Master_Node.SHP",      ; point shape
    "\n shpi=", '{CATALOG_DIR}', "\MasterNetwork\Master_Link.SHP",     ; line shape
    "\n neto=", '{CATALOG_DIR}', "\MasterNetwork\Master_highway.net",
    '\n PointNodeNumField="N"',
    "\n AnodeField=A",
    "\n BnodeField=B",
    '\n LevelField=""',
    "\n ClearABValues=T",
    "\n DirectionOption=1",
    '\n DirectionField=""',
    "\n AddDistanceField=Y",
    "\n DistanceScale=2.22",
    "\n NodeGroupingLimit=1",
    "\n StartingNewNode=1000",
    "\n HighestZone=270",
  "\n \n endfunction",
 FILE = "{CATALOG_DIR}\CUBE\SHAPE_TO_NET.S"

*CUBE {CATALOG_DIR}\CUBE\Shape_to_Net.s /Command /CloseWhenDone /Minimize /NoSplash

*DELETE "{CATALOG_DIR}\CUBE\Shape_to_Net.s"
