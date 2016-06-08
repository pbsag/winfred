; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\reports\SCREENLINES.PRN" MSG='Screenline Analysis-Text File Output'
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\reports\SCREENLINE.PRN"
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO NETO = "{CATALOG_DIR}\output\{Scenario_FullName}\screenline.net"
LOOKUP LOOKUPI=1,
       NAME=SCREEN,
         LOOKUP[1]=ID, RESULT=SCLIN,
         LOOKUP[2]=ID, RESULT=LINKID,
         FAIL[1]=-1,FAIL[2]=-1,FAIL[3]=-1,list=Y

;ID is a sequential unique ID for the records
;SCLIN is the screenline number
;LINKID is the ID to find on the link

FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\screen.dbf"


array SLN=10000,LKID=10000

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.

ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.

if (dir=0)
       VOL=ROUND(VT_6/2)
;TOTAL_VOL=ROUND(V_6)
else
      VOL=ROUND(VT_6)
endif
CNT=COUNT
CAP=CAPACITY*{CAPCONFAC}
_kk=_kk+1
if(_kk<2)
  _NREC=0
  loop _k=1,1000
    _S  = SCREEN(1,_k)
;SCLIN=_S
    _L  = SCREEN(2,_k)
    if(_S>0) _NREC=_k
    SLN[_k]  = _S
    LKID[_k] = _L
     ; print list=_k,_S,_L
  endloop
;IF (_s=0) delete
;IF (COUNT=0) delete

  print list='\n\n',_NREC(6.0),' RECORDS in the LOOKUP table to be searched:'
 print list=' ANOD'(5),' BNOD'(5),'  _j  '(6),'Sline'(5), '   CNT'(5), '  VOL'(7), '   CAP'(9),'  ','        ROUTE_NAME'(36)
endif
;SL_ID is the screenline ID (not screenline number) coded on the links
if(SL_ID>0)
  loop _j=1,_NREC
    _tSL=SLN[_j]
    _tID=LKID[_j]
    if(SL_ID=_tID)
 ;...... here you can assume the link is on screenline _tSL .....................
      print list=a(5.0),b(5.0),_j(5.0),_tSL(5.0), CNT(6.0), VOL(7.0),CAP(9.0),'   ' ROUTE_NAME(36.0), printo=1; test to check whether it worked right
    

endif

  endloop

endif


ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS
ENDRUN
