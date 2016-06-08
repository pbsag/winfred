; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\WMMAT00C.PRN" MSG='Consolidata distribution data for reports'
FILEI MATI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT"
FILEI MATI[3] = "{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\LU.prn",
z=#1,pop=#2,hh=#3

FILEO RECO[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\TPCP.DBF",
 FIELDS=VEHTRIPS,PERTRIPS

FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\TLD.DBF",
 FIELDS = TIME, WORK, OTHER, NHB, TOTAL 


; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

mw[1]=mi.1.1 ; HBW
mw[2]=mi.1.2 ; HBS
mw[3]=mi.1.3 ; HBO


mw[10]=mi.1.4 ; TOTAL person
mw[20]=mi.3.1  ; Vehicle Trip Table

mw[11]=mi.2.4 ; TIME


_TRIPS=rowsum(10)   ; person
_trips1=rowsum(20)  ;vehicle

trips=trips+_trips  ; person
trips1=trips1+_trips1  ; vehicle

log prefix=per var=trips
log prefix=veh var=trips1

pop=@node._pop@
;pop=zi.1.pop

vehtrips=trips1/pop
pertrips=trips/pop

if(i=lastzone)write reco=2


array tl1=60,tl2=60,tl3=60,tl10=60

jloop

group = min(max(round(mw[11]),1),60)

tl1[group]=tl1[group]+mw[1]
tl2[group]=tl2[group]+mw[2]
tl3[group]=tl3[group]+mw[3]
tl10[group]=tl10[group]+mw[10]


endjloop

if (i=zones)

  loop group=1,60
   
   ro.TIME=group
   ro.WORK=tl1[group]
   ro.OTHER=tl2[group]
   ro.NHB=tl3[group]
   
   ro.TOTAL=tl10[group]

   write reco=1

  endloop

endif

ENDRUN
