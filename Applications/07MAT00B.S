; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\logs\09NET00A.PRN" MSG='Screenline Summary'
FILEO RECO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\Screenline_Summary.dbf",
fields= n, volume,count,Volcnt
FILEI RECI = "{CATALOG_DIR}\output\{Scenario_FullName}\screenline.dbf"

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

ARRAY scln=1000, VOL=1000, CNT=1000,VC=1000

;SCLN[_scln]=ri.screenline
;VOL[_SCLN]=ri.volume
;CNT[_scln]=ri.count

_scln=ri.screenline
_vol=ri.volume
_cnt=ri.count


;loop _n=1,1000
if(ri.screenline = 1-1000)
 VOL[ri.screenline]=VOL[ri.screenline]+_VOL  
 CNT[ri.screenline]=CNT[ri.screenline]+_CNT
 VC[ri.screenline]=VOL[ri.screenline]/CNT[ri.screenline]

 print list= VOL[ri.screenline]
endif
;endloop

if(I=0)
 loop _n=1,1000
  if(vol[_n]>0)
    n=_n
    volume=VOL[_n]
    count=CNT[_n]
    volcnt=VC[_n]
   Write reco=1
  endif
endloop
endif

;ro.screenline=_scln
;ro.volume=totvol
;ro.count=totcnt
;ro.volcnt=totvol/totcnt
;Write reco=1


ENDRUN
