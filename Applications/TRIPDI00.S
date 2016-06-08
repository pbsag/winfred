; Script for program DISTRIBUTION in file "C:\1Projects\VDOT\Win-Fred-Model-Jan0709\WinFred-Model\Applications\03DST00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\03DST00A.PRN" MSG='Vehicle Trip Table Estimation'
FILEI LOOKUPI[2] = "{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\01HWY{Year}A.MAT"
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT",
Z=#1, P1=#2, P2=#3, P3=#4, A1=#5, A2=#6, A3=#7 
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\ffacfin.dbf"
FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT",
MO=1-3,7,17 NAME=HBW,HBO,NHB,TotPerPA,TotVehPA  

MAXITERS={AITERS},MAXRMSE=1              ; set max iterations and
                                                     ; closure criteria
/*Commented out by TCG for the use of DBF file*/
;-----------------------------------------------------------
   ;LOOKUP,
 ;FILE = "{SCENARIO_DIR}\FFACFIN.PRN",
 ;INTERPOLATE=Y, NAME=FF,    ; friction factor lookup
        ;LOOKUP[1]=1,RESULT=2,
        ;LOOKUP[2]=1,RESULT=3,
        ;LOOKUP[3]=1,RESULT=4
;--------------------------------------------------------------

   LOOKUP,lookupi=1,name=FF,           ; friction factor lookup                 
   LOOKUP[1]=ROW,RESULT=HBW,
   LOOKUP[2]=ROW,RESULT=HBO,
   LOOKUP[3]=ROW,RESULT=NHB,
 INTERPOLATE=Y

    SETPA P[1]=P1  A[1]=A1                           ; setup the P & A arrays
    SETPA P[2]=P2  A[2]=A2
    SETPA P[3]=P3  A[3]=A3


    MW[10] = MI.1.TOTTIME                               ; put time into matrix 10

    GRAVITY   PURPOSE=1, LOS=MW[10], FFACTORS=FF;, KFACTORS=MI.3.KFACTOR     ; run 3 gravity models
    FREQUENCY VALUEMW=1  BASEMW=10,  RANGE=1-100     ; frequency distribution
    GRAVITY   PURPOSE=2, LOS=MW[10], FFACTORS=FF;, KFACTORS=MI.3.KFACTOR 
    FREQUENCY VALUEMW=2  BASEMW=10,  RANGE=1-100
    GRAVITY   PURPOSE=3, LOS=MW[10], FFACTORS=FF;, KFACTORS=MI.3.KFACTOR
    FREQUENCY VALUEMW=3  BASEMW=10,  RANGE=1-100

; MW[20]=mi.2.DailyEE

;---------------------------------------------
;lookup name=autoocc,
       ;lookup[1]=1, result=2,       ; Morning Peak
       ;list=y,
;              AM      PM
     ;r='1     1.11',          ; HBW Auto Occupancy
     ;r='2     1.56',          ; HBO Auto Occupancy
    ; r='3     1.56'          ; NHB Auto Occupancy
;------------------------------------------------     

   lookup, lookupi=2, name=autoocc,
   lookup[1]=ROW, result=AUTOOCC,       ; Morning peak
   INTERPOLATE=N

   MW[11]=MW[1]/autoocc(1,1)
   MW[12]=MW[2]/autoocc(1,2)
   MW[13]=MW[3]/autoocc(1,3)

   MW[7]=MW[1]+MW[2]+MW[3]

   MW[17]=MW[11]+MW[12]+MW[13]


ENDRUN


