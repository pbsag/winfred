; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\HBSC_noSchoolTrips.PRN" MSG='HBSC - no sch bus trips'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Dest_HBSC.MAT",
 MO = 1, NAME = HBSC

 MW[1] = MI.1.1 * (1 - 0.83)

ENDRUN
