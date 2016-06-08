; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\logs\08NET00A.PRN" MSG='Links with Counts and Screenlines'
FILEI RECI = "{CATALOG_DIR}\Output\{Scenario_FullName}\reports\SCREENLINE.PRN",
a=1-6,b=7-11,j=12-16,SCRN=17-21,count=22-27,vol=28-34,Cap=35-43,RT(C)=44-80
FILEO RECO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\screenline.dbf",
fields=anode,bnode,Screenline,count,volume,capacity,RT_Name
; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.


ro.anode=ri.a
ro.bnode=ri.b
ro.screenline=ri.scrn
ro.volume=ri.vol
ro.count=ri.count
ro.capacity=ri.cap
ro.rt_name=ri.rt



if (ri.count>0) 
write reco=1
endif

;anode=zi.1.a,bnode=zi.1.b,_j=zi.1.j,Screenline=zi.1.scrn,volume=zi.1.vol,count=zi.1.count,capacity=zi.1.cap,RT_Name=zi.1.rt
ENDRUN
