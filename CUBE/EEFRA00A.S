
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EEFRA00A.PRN" MSG='Future year EE Table'
FILEI MATI[1] = "{CATALOG_DIR}\PARAMS\EE_seed.MAT"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\INPUT\EXTERNALTRIPS.DBF"
; This table contains the base year external station counts (EE AND IEEI)
;   and a growth rate (field name = GRWTH).
;   GRWTH is = 1 for the base year.  
;   Future year tables are identical to the base year table except for the values of GRWTH.

FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT",
 MO=3,2,NAME = EE_TRIPS_AUTO, EE_TRIPS_TRK,DEC=1*D

; Apply growth rate to base year EE seed matrix marginals
;  to obtain EE Marginals.
; Fratar external seed table to Productions and Attractions.

PARAMETERS MAXRMSE=0.0001 MAXITERS=25
; USE A LOOKUP FILE TO find appropriate factors (1.0 is assumed unless expressly provided)
LOOKUP LOOKUPI=1, LIST=Y,
  NAME=GROWTHF,
  LOOKUP[1]=ZONE,RESULT=GRWTH,
  LOOKUP[2]=ZONE,RESULT=GRWTH,
  FAIL[1]=1,FAIL[2]=1,FAIL[3]=1

SETPA PGF[1]=GROWTHF(1,I) AGF[1]=MAX(GROWTHF(2,I),0.000001) MW[1]=MI.1.1 

LOOKUP LOOKUPI=1, LIST=Y,
  NAME=TRKPCT,
  LOOKUP[1]=ZONE,RESULT=PCT_TRUCK,
  LOOKUP[2]=ZONE,RESULT=PCT_TRUCK,
  FAIL[1]=1,FAIL[2]=1,FAIL[3]=1

SETPA PGF[2]=TRKPCT(1,I) AGF[2]=TRKPCT(2,I) MW[2]=MW[1]

MW[3]=MW[1]-MW[2]



ENDRUN
