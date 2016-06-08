; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\04MAT00D.PRN" MSG='PA TO OD Daily'
FILEI MATI[2] = "{CATALOG_DIR}\output\{Scenario_FullName}\x2x{Year}.mat"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT",
 MO=1,2,3 Name=TotVehOD,zero,intra



MW[20]=mi.2.DailyEE


MW[1]= ((MI.1.TotVehPA+MI.1.TotVehPA.T)*.5)+MW[20]
mw[2]=0
mw[3]=mw[1][intrazonal]
; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

ENDRUN
