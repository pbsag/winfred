&PROJFIL
11
0
0
Winchester Model Version 3.0
01
00
Run Winchester-Frederick 2003 Model

Fri May 09 14:06:40 2014
K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Calibration Constants\Win-Fred.bmp

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\Win-Fr08.app
VOYAGER


&End_TextAnnotation
English
#PROGRAM0
1
1
2

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\NET00.APP
Network

0
1
0


999999
366
-624
661
-744
0
0
0
#INFIL0
Zonal Data 1
Terminal Times
0
0
*
{SCENARIO_DIR}\TERMTIME.DBF
1
0125
      
999999
49
-585
355
-647
-1
-1
0
#INFIL1
Lookup File 1
SPDCAPCLSS
0
0
*
{CATALOG_DIR}\Calibration Constants\SPDCAPCLASS.dbf
1
0221
      
999999
49
-652
355
-714
-1
-1
0
#INFIL2
Link/Net. 1
Starting Net
0
0
*
{SCENARIO_DIR}\WF_{Year}{ALT}.NET
1
0300
      
255
49
-719
355
-781
-1
-1
0
#OUTFIL0
Network File

0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET
1
0001
      
999999
677
-618
978
-680
0
#OUTFIL1
Matrix File 1
Skims
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\01HWY{Year}A.MAT
1
0101
      
999999
677
-685
978
-747
0
#PROGRAM1
2
1
3

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\TRIPGE00.APP
Trip Generation

0
1
0


999999
375
-972
670
-1092
0
0
0
#INFIL0
Zonal Data 1
External Data
0
0
*
{SCENARIO_DIR}\EXTERNAL{Year}.DBF
1
0001
      
999999
58
-768
364
-830
-1
-1
0
#INFIL1
Zonal Data 2
Employment Data
0
0
*
{SCENARIO_DIR}\EMPDATA{Year}.DBF
1
0002
      
999999
58
-835
364
-897
-1
-1
0
#INFIL2
Zonal Data 3
Stratification Data
0
0
*
{SCENARIO_DIR}\STRATIFY{Year}.DBF
1
0003
      
999999
58
-902
364
-964
-1
-1
0
#INFIL3
Zonal Data 4
Population Data
0
0
*
{SCENARIO_DIR}\POPHHLD{Year}.DBF
1
0004
      
999999
58
-969
364
-1031
-1
-1
0
#INFIL4
Lookup File 1
Production Rates
0
0
*
{CATALOG_DIR}\Calibration Constants\trip-prod-lookup.dbf
1
0011
      
999999
58
-1036
364
-1098
-1
-1
0
#INFIL5
Lookup File 2
Attraction Rates
0
0
*
{CATALOG_DIR}\Calibration Constants\TripAttrRates.dbf
1
0012
      
999999
58
-1103
364
-1165
-1
-1
0
#INFIL6
Lookup File 3
External Split by Purpose
0
0
*
{CATALOG_DIR}\Calibration Constants\PerPurpose.dbf
1
0013
      
999999
58
-1170
364
-1232
-1
-1
0
#INFIL7
Lookup File 4
Auto Occupancy
0
0
*
{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf
1
0014
      
999999
58
-1237
364
-1299
-1
-1
0
#OUTFIL0
ZonalPAData 1
Unbalanced PA table
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN00A.DAT
1
0001
      
999999
686
-966
987
-1028
0
#OUTFIL1
ZonalPAData 1
Balanced PA Table
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT
1
0101
      
999999
686
-1033
987
-1095
0
#PROGRAM2
3
1
4

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\TRIPDI00.APP
Trip Distribution

0
1
0


999999
389
-1409
684
-1529
0
0
0
#INFIL0
Matrix File 1
Skims
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\01HWY{Year}A.MAT
1
0001
      
999999
72
-1337
378
-1399
0
1
0
#INFIL1
Zonal Data 1
P and A
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT
1
0022
      
999999
72
-1404
378
-1466
1
1
0
#INFIL2
Lookup File 1
Friction Factors
0
0
*
{CATALOG_DIR}\Calibration Constants\ffacfin.dbf
1
0032
      
999999
72
-1471
378
-1533
-1
-1
0
#INFIL3
Lookup File 2
Auto Occupancy
0
0
*
{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf
1
0033
      
999999
72
-1538
378
-1600
-1
-1
0
#OUTFIL0
Matrix File 1
PA Veh Trip Table
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT
1
0001
      
999999
700
-1436
1001
-1498
0
#PROGRAM3
4
1
5

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\PATOOD00.APP
PA to OD

0
1
0


999999
1309
-650
1604
-770
0
0
0
#INFIL0
Matrix File 1
AM EE Seed
0
0
*
{SCENARIO_DIR}\AMEE{Year}.PRN
1
0001
      
999999
992
-545
1298
-607
-1
-1
0
#INFIL1
Matrix File 2
PM EE seed
0
0
*
{SCENARIO_DIR}\PMEE{Year}.PRN
1
0002
      
999999
992
-612
1298
-674
-1
-1
0
#INFIL2
Matrix File 3
Daily EE Seed
0
0
*
{SCENARIO_DIR}\DAILYEE{Year}.PRN
1
0003
      
999999
992
-679
1298
-741
-1
-1
0
#INFIL3
Matrix File 1
PA vehicle Trip Table
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT
1
0101
      
999999
992
-746
1298
-808
2
0
0
#INFIL4
Zonal Data 1
External GF Adjustment
0
0
*
{SCENARIO_DIR}\External{Year}-gf.dbf
1
0222
      
999999
992
-813
1298
-875
-1
-1
0
#OUTFIL0
Matrix File 1
AM EE
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}A.MAT
1
0001
      
999999
1620
-578
1921
-640
0
#OUTFIL1
Matrix File 2
PM EE
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}B.MAT
1
0002
      
999999
1620
-645
1921
-707
0
#OUTFIL2
Matrix File 1
OD Daily
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT
1
0101
      
999999
1620
-712
1921
-774
0
#OUTFIL3
Matrix File 1
DAILY EE
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\x2x{Year}.mat
1
0201
      
999999
1620
-779
1921
-841
0
#PROGRAM4
5
1
6

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\TIMEOF00.APP
TIME OF DAY

0
1
0


999999
1347
-1020
1642
-1140
0
0
0
#INFIL0
Matrix File 1
PA Veh Trip Table
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT
1
0001
      
999999
1030
-915
1336
-977
2
0
0
#INFIL1
Lookup File 1
Auto Occupancy
0
0
*
{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf
1
0032
      
999999
1030
-982
1336
-1044
-1
-1
0
#INFIL2
Matrix File 2
AM EE
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}A.MAT
1
0102
      
999999
1030
-1049
1336
-1111
3
0
0
#INFIL3
Matrix File 3
PM EE
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}B.MAT
1
0103
      
999999
1030
-1116
1336
-1178
3
1
0
#INFIL4
Zonal Data 1
External Data
0
0
*
{SCENARIO_DIR}\EXTERNAL{Year}.DBF
1
0122
      
999999
1030
-1183
1336
-1245
-1
-1
0
#OUTFIL0
Matrix File 1
AM TRIP TABLE
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00B.MAT
1
0101
      
999999
1658
-1014
1959
-1076
0
#OUTFIL1
Matrix File 2
PM TRIP TABLE
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00C.MAT
1
0102
      
999999
1658
-1081
1959
-1143
0
#PROGRAM5
6
1
7

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\ASSIGN00.APP
ASSIGNMENT

0
1
0


999999
1417
-1449
1712
-1569
0
0
0
#INFIL0
Matrix File 1
DAILY TRIP TABLE
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT
1
0001
      
999999
1100
-1344
1406
-1406
3
2
0
#INFIL1
Network File

0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET
1
0021
      
999999
1100
-1411
1406
-1473
0
0
0
#INFIL2
Turn Penalties

0
0
*
{SCENARIO_DIR}\TURNPEN{Year}.PEN
1
0024
      
999999
1100
-1478
1406
-1540
-1
-1
0
#INFIL3
Matrix File 1
AM TRIP TABLE
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00B.MAT
1
0101
      
999999
1100
-1545
1406
-1607
4
0
0
#INFIL4
Matrix File 1
PM TRIP TABLE
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00C.MAT
1
0201
      
999999
1100
-1612
1406
-1674
4
1
0
#OUTFIL0
Network File
DAILY LOADED NETWORK
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET
1
0022
      
255
1728
-1377
2029
-1439
0
#OUTFIL1
Network File
AM LOADED NETWORK
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\AMLOADED_{Year}.NET
1
0122
      
999999
1728
-1444
2029
-1506
0
#OUTFIL2
Network File
PM LOADED NETWORK
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\PMLOADED_{Year}.NET
1
0222
      
999999
1728
-1511
2029
-1573
0
#OUTFIL3
Matrix File 1
Congested Skim
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT
1
0301
      
999999
1728
-1578
2029
-1640
0
#PROGRAM6
7
1
8

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\ANALYS00.APP
Analysis

0
1
0


999999
2276
-795
2571
-915
0
0
0
#INFIL0
Link/Net. 1
Daily Loaded Network
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET
1
0001
      
999999
1959
-657
2265
-719
5
0
0
#INFIL1
Lookup File 1
Screen Lines
0
0
*
{CATALOG_DIR}\Calibration Constants\screen.dbf
1
0321
      
999999
1959
-724
2265
-786
-1
-1
0
#INFIL2
Zonal Data 1
Trip P and A
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT
1
0601
      
999999
1959
-791
2265
-853
1
1
0
#INFIL3
Matrix File 1
Person TT
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT
1
0603
      
999999
1959
-858
2265
-920
2
0
0
#INFIL4
Matrix File 2
Cong Skim
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT
1
0604
      
999999
1959
-925
2265
-987
5
3
0
#INFIL5
Matrix File 3
Daily TT
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT
1
0605
      
999999
1959
-992
2265
-1054
3
2
0
#OUTFIL0
Print Data 1
RMSE Report
0
0
*
{CATALOG_DIR}\Output\{Scenario_FullName}\reports\RMSE.PRN
1
0104
      
999999
2587
-723
2888
-785
0
#OUTFIL1
Print Data 1
Detailed RMSE Report
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\reports\detRMSE.PRN
1
0204
      
999999
2587
-790
2888
-852
0
#OUTFIL2
Record File 1
Links with Screenlines
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\screenline.dbf
1
0421
      
999999
2587
-857
2888
-919
0
#OUTFIL3
Record File 1
Screenline Summary
0
0
*
{CATALOG_DIR}\output\{Scenario_FullName}\Screenline_Summary.dbf
1
0521
      
999999
2587
-924
2888
-986
0
#PROGRAM7
8
1
1

K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\SETUP00.APP
SETUP

0
1
0


999999
886
-412
1181
-532
0
0
0
