; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01MAT00U.PRN" MSG='OUTPUT AREA TYPE AS DBF FOR LATER USE'
FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\ZONAL AT{Year}{Alternative}.DBF",
 fields=Z,N,ATYPE
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\AREA TYPE.PRN",
 z=#1,at=2

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

zones={Total zones}
N=Z
ATYPE=zi.1.at

if(z={CBD}) ATYPE=1

if(ATYPE>0)write reco=1
ENDRUN
