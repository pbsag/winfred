;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\HBUTripAttractions.PRN" MSG='HBU Attractions'
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\se_classified_{year}{Alternative}.dbf"
FILEO RECO[1] = "{SCENARIO_DIR}\Output\HBU_ATTR.dbf",
fields = TAZ, UNVA

zones={Internal Zones}
RO.TAZ=I

MW[1]= zi.1.UNV
MW[2][144]= 3000
RO.UNVA=MW[2][I]

WRITE RECO=1

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

ENDRUN
