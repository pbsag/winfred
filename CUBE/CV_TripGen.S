;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\CV_TripGen.PRN" MSG='CV Trip Generation'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\CVRATES.CSV"
FILEO PAO[1] = "{SCENARIO_DIR}\Output\CV_PA_{year}.DBF",
FORM=10.3, DBF=T, LIST=Z, P[1], P[2], P[3], A[1], A[2], A[3]
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\se.dbf"

ZONES={Internal Zones}

LOOKUP, LOOKUPI=1, 
	NAME=CVRates,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
	INTERPOLATE=N, FAIL[1]=0, FAIL[2]=0, FAIL[3]=0, LIST=Y

PHASE=ILOOP

	P[1]=	(IND*CVRates(1,1))+((RET + SG_RET)*CVRates(1,2))+(HTRET*CVRates(1,3))+(OFF*CVRates(1,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(1,5))+(HH*CVRates(1,6))
  
	P[2]=	(IND*CVRates(2,1))+((RET + SG_RET)*CVRates(2,2))+(HTRET*CVRates(2,3))+(OFF*CVRates(2,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(2,5))+(HH*CVRates(2,6))
	P[3]= (IND*CVRates(3,1))+((RET + SG_RET)*CVRates(3,2))+(HTRET*CVRates(3,3))+(OFF*CVRates(3,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(3,5))+(HH*CVRates(3,6))
  
	A[1]=P[1]
  A[2]=P[2]
  A[3]=P[3]
  
ENDPHASE

PHASE=ADJUST
  BALANCE NHB=1
ENDPHASE

ENDRUN
