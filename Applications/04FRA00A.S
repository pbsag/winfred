; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Updating the External Trip Tables to Reflect New TMS Traffic Counts at External Stations'

FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\x2x{Year}.mat",
MO=1,
Name=DAILYEE
FILEI ZDATI[1] = "{SCENARIO_DIR}\External{Year}-gf.dbf"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT00C.MAT"


PARAMETERS ZONES={Total Zones}

MAXRMSE=0.01 MAXITERS=10
SETPA PGF[1]=zi.1.GFP, AGF[1]=zi.1.GFA, MW[1]=mi.1.1 CONTROL=PA

ACOMP=1,PCOMP=1
MARGINS=1


; The FRATAR module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  The module implements a FRATAR distribution process by modifying an
; existing matrix based on a set of user supplied production and attraction factors.

ENDRUN
