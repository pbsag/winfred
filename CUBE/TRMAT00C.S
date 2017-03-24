; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\Logs\TOD_Model_NT.PRN" MSG='Convert PA Trips to OD Trips - NT'

FILEI MATI[7] = "{SCENARIO_DIR}\OUTPUT\CV_{YEAR}_NT.MAT"
FILEI MATI[6] = "{SCENARIO_DIR}\OUTPUT\EE_{YEAR}_NT.MAT"
FILEI MATI[5] = "{SCENARIO_DIR}\OUTPUT\IEEI_{YEAR}_NT.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\NHB_MCTRIPS.MAT"
FILEI MATI[4] = "{SCENARIO_DIR}\OUTPUT\HBSC_MCTRIPS.MAT"
FILEI MATI[3] = "{SCENARIO_DIR}\OUTPUT\HBO_MCTRIPS.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\HBW_MCTRIPS.MAT"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\TOD_FACS.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\ODAUTO_NT.MAT",
MO = 1,3-8 NAME = DA, SR, IEEI, CV, EE_AUTO, EE_TRK, CV_MUT
PARAMETERS  ZONES={Total Zones}

; Read alternative specific Constants
LOOKUP, NAME=TOD_FACS, LOOKUP[1]=1, RESULT=5, INTERPOLATE=N, , LIST=Y, LOOKUPI=1

HBW_PA  = TOD_FACS(1,1)       
HBW_AP  = TOD_FACS(1,2)     
HBO_PA  = TOD_FACS(1,3)     
HBO_AP  = TOD_FACS(1,4)     
HBSC_PA = TOD_FACS(1,5) 
HBSC_AP = TOD_FACS(1,6) 
NHB_PA  = TOD_FACS(1,7)    
NHB_AP  = TOD_FACS(1,8)  

;  CONVERT P/A MATRIX TO O/D

; Drive Alone trips
MW[1]= MI.1.1 * NHB_PA +  MI.1.1.T * NHB_AP +
       MI.2.1 * HBW_PA +  MI.2.1.T * HBW_AP +
       MI.3.1 * HBO_PA +  MI.3.1.T * HBO_AP +
       MI.4.1 * HBSC_PA +  MI.4.1.T * HBSC_AP

; Share ride trips
MW[2]= MI.1.2 * NHB_PA +  MI.1.2.T * NHB_AP +
       MI.2.2 * HBW_PA +  MI.2.2.T * HBW_AP +
       MI.3.2 * HBO_PA +  MI.3.2.T * HBO_AP +
       MI.4.2 * HBSC_PA +  MI.4.2.T * HBSC_AP
       
MW[3] = MW[2]/2.19 ; shareride vehicle trips

MW[4] = MI.5.1 ; IEEI trips

MW[5] = MI.7.1 + MI.7.2  ; CV and CV_SUT trips
MW[8] = MI.7.3 ; CV_MUT trips

MW[6] = MI.6.1 ; EE Auto trips
MW[7] = MI.6.2 ; EE TRK trips

ENDRUN
