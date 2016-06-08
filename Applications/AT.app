&PROJFIL
EXP0 0 1Link/Net. 1    {SCENARIO_DIR}\WF_{Year}{ALT}.NET                           
EXP0 1 1Node File 2    {SCENARIO_DIR}\Land Use_{Year}.dbf                          
EXP0 2 1Lookup File 1  {CATALOG_DIR}\Calibration Constants\AT.dbf                  
EXP0 0 0Network File   {CATALOG_DIR}\Output\{Scenario_FullName}\Final_AT_{Year}{Alternative}.NET
11
1
0
Area Type model
01
00
Area Type Model
Area Type
Fri May 09 13:50:22 2014

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\NET00.APP
K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\AT.APP
VOYAGER


&End_TextAnnotation
English
#PROGRAM0
2
1
1

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\NETWOR00.APP
Network

0
1
0


999999
830
-1157
1015
-1263
0
0
0
#INFIL0
Link/Net. 1
Starting Net
0
0
*
{SCENARIO_DIR}\WF_{Year}{ALT}.NET
1
0001
      
255
606
-1135
822
-1182
-1
-9
1
#INFIL1
Node File 2
Lan Use Data
0
0
*
{SCENARIO_DIR}\Land Use_{Year}.dbf
1
0112
      
4227200
606
-1185
822
-1232
-1
-9
1
#INFIL2
Lookup File 1
Area Type Table
0
0
*
{CATALOG_DIR}\Calibration Constants\AT.dbf
1
0221
      
999999
606
-1235
822
-1282
-1
-9
1
#OUTFIL0
Network File
Network with Area type
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\Final_AT_{Year}{Alternative}.NET
1
0701
      
999999
1027
-1185
1239
-1232
1
