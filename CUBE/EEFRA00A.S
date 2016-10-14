
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EEFRA00A.PRN" MSG='Future year EE Table'
FILEI MATI[1] = "{CATALOG_DIR}\PARAMS\EE_seed.MAT"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\EXTERNALTRIPS.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT",
 MO=1,NAME = EE_TRIPS, DEC=1*D

; Apply growth rate to base year EE seed matrix marginals
;  to obtain future year target through trips at external
;  stations.
; Fratar external seed table to Productions and Attractions.


PARAMETERS MAXRMSE=0.0001 MAXITERS=25
; USE A LOOKUP FILE TO find appropriate factors (1.0 is assumed unless expressly provided)
LOOKUP LOOKUPI=1, LIST=Y,
  NAME=GROWTHF,
  LOOKUP[1]=ZONE,RESULT=GRWTH_{YEAR},
  LOOKUP[2]=ZONE,RESULT=GRWTH_{YEAR},
  FAIL[1]=1,FAIL[2]=1,FAIL[3]=1

SETPA PGF[1]=GROWTHF(1,I) AGF[1]=GROWTHF(2,I) MW[1]=MI.1.1 

ENDRUN
