; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*del {CATALOG_DIR}\CUBE\*.prn /q
*del {CATALOG_DIR}\CUBE\*.bak /q
*del {CATALOG_DIR}\CUBE\*.0?? /q
*del {CATALOG_DIR}\CUBE\trc*.s /q
*IF NOT EXIST "{SCENARIO_DIR}\Output" MKDIR "{SCENARIO_DIR}\Output"
*IF NOT EXIST "{SCENARIO_DIR}\OUTPUT" MKDIR "{SCENARIO_DIR}\OUTPUT"
*IF NOT EXIST "{SCENARIO_DIR}\OUTPUT\LOGS" MKDIR "{SCENARIO_DIR}\OUTPUT\LOGS"

FILEO PRINTO[1] = "{SCENARIO_DIR}\scenario.properties"
 ; Write out catalog keys as scenario.properties
 print list = 'About the scenario'    printo = 1 
 print list = '-----------------------------------'             printo = 1 
 print list = 'SCENARIO_FULLNAME  = ', '{SCENARIO_FULLNAME}'    printo = 1
 print list = 'SCENARIO_SHORTNAME = ', '{SCENARIO_SHORTNAME}'   printo = 1
 print list = 'SCENARIO_CODE      = ', '{SCENARIO_CODE}'        printo = 1
 print list = 'SCENARIO_DIR       = ', '{SCENARIO_DIR}'         printo = 1
 print list = 'CATALOG_DIR        = ', '{CATALOG_DIR}'          printo = 1
 print list = 'Alternative        = ', '{Alternative}'          printo = 1
 print list = 'Description        = ', '{Description}'          printo = 1
 print list = 'Year               = ', '{Year}'                 printo = 1

 print list = '\n \nModel settings'    printo = 1 
 print list = '-----------------------------------'             printo = 1  
 print list = 'Total-Zones        = ', '{Total-Zones}'          printo = 1
 print list = 'ZONESA             = ', '{ZONESA}'               printo = 1 
 print list = 'Internal-Zones     = ', '{Internal-Zones}'       printo = 1
 print list = 'MAXWLKACCLNKS      = ', '{MAXWLKACCLNKS}'        printo = 1
 print list = 'NODEMIN            = ', '{NODEMIN}'              printo = 1
 print list = 'Radius             = ', '{Radius}'               printo = 1
 print list = 'AVGWLKSPD          = ', '{AVGWLKSPD}'            printo = 1
 print list = 'UNIT               = ', '{UNIT}'                 printo = 1
 print list = 'WALKACC            = ', '{WALKACC}'              printo = 1
 
 print list = '\n \nDebug and select link settings'             printo = 1   
 print list = '-----------------------------------'             printo = 1 
 print list = 'DebugDC            = ', '{DebugDC}'              printo = 1 
 print list = 'FromNode           = ', '{FromNode}'             printo = 1
 print list = 'ToNode             = ', '{ToNode}'               printo = 1
 print list = 'SelOrigin          = ', '{SelOrigin}'            printo = 1
 print list = 'SelDest            = ', '{SelDest}'              printo = 1
 print list = 'SelectLink         = ', '{SelectLink}'           printo = 1

 
 
