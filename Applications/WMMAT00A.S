; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\WMMAT00A.PRN" MSG='Give better names to Trip P and A data'
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT",
Z=#1,HBWP=#2,HBOP=#3,NHBP=#4,HBWA=#5,HBOA=#6,NHBA=#7

FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\PandA.dbf",
FIELDS=Z,N,HBW_P,HBO_P,NHB_P,HBW_A,HBO_A,NHB_A

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.


zones={Total Zones}

RO.HBW_P=zi.1.HBWP
RO.HBO_P=zi.1.HBOP
RO.NHB_P=zi.1.NHBP
RO.HBW_A=zi.1.HBWA
RO.HBO_A=zi.1.HBOA
RO.NHB_A=zi.1.NHBA

N=Z

WRITE RECO=1

ENDRUN
