; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*IF NOT EXIST "{CATALOG_DIR}\Output" MKDIR "{CATALOG_DIR}\Output"
*IF NOT EXIST "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}" MKDIR "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}"
*IF NOT EXIST "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\LOGS" MKDIR "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\LOGS"
*IF NOT EXIST "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\REPORTS" MKDIR "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\REPORTS"
;*IF NOT EXIST "{CATALOG_DIR}\Shape\{SCENARIO_FULLNAME}" MKDIR "{CATALOG_DIR}\Shape\{SCENARIO_FULLNAME}" 

; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*IF NOT EXIST "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\GDB_MAPS" MKDIR "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\GDB_MAPS"
*copy "{CATALOG_DIR}\Geodatabase\Empty.mdb" "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\GDB_MAPS\Results.mdb"
*IF NOT EXIST "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\GDB_MAPS\Results.vpr" copy "{CATALOG_DIR}\Geodatabase\Harrisonburg_GDB.vpr" "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\GDB_MAPS\Results.vpr"
*copy "{CATALOG_DIR}\Maps\*.MXD" "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\GDB_MAPS\"
*copy "{CATALOG_DIR}\Reports\*.BMP" "{CATALOG_DIR}\OUTPUT\{SCENARIO_FULLNAME}\GDB_MAPS\"
; End of PILOT Script

; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01NET00C.PRN" MSG='OUTPUT LINK AND ZONE DATA'
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\XY.DAT"
FILEO NODEO = "{CATALOG_DIR}\Output\{Scenario_FullName}\NODE.DAT"
FILEO LINKO = "{CATALOG_DIR}\Output\{Scenario_FullName}\LINK.DAT"
FILEI LINKI[1] = "{SCENARIO_DIR}\WF_{Year}{ALT}.NET"

ARRAY _CNT={Total zones},_CENTX={Total zones},_CENTY={Total zones},_CENT={Total zones},
      _NO=99999,_MIDX=99999,_MIDY=99999,_MID_POINT=99999,_NO=99999,XMILES=999999,
      YMILES=999999

PHASE=NODEMERGE

IF(n<={Total zones})

PRINT form=20.3 LIST=N,X,Y, PRINTO=1
;  _CNT=_CNT+1
;  _CENT[_CNT]=N
;  _CENTX[_CNT]=X
;  _CENTY[_CNT]=Y
;  _BB=_BB+1
;  Z=_BB
;PRINT LIST=_CNT,_CENT[_CNT],_CENTX[_CNT],_CENTY[_CNT],N,X,Y
ENDIF

ENDPHASE

PHASE=LINKMERGE

AX=A.X
BX=B.X
AY=A.Y
BY=B.Y

;calculate distance between the links

;distance=(sqrt((a.x-b.x)^2+(a.y-b.y)^2))*0.000621371192237334

IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X<B.X) ROADDIR='EB' ;east bound
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X>B.X) ROADDIR='WB' ; west bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y<B.Y) ROADDIR='NB' ; north bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y>B.Y) ROADDIR='SB' ; south bound

ENDPHASE

ENDRUN


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01MAT00S.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01MAT00S.PRN" MSG='FIND THE CLOSEST ZONE TO EACH LINK'
FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\CLOSEST.DBF",
FIELDS=A,B,ZN
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\XY.DAT",
Z=#1,X=#2,Y=#3
FILEI RECI = "{CATALOG_DIR}\Output\{Scenario_FullName}\LINK.DAT"

ZONES={Total zones}

; Zone number for centroid connectors is defined as the zone that
;  the connector connects to.
  if (ri.a <= zones || ri.b <= zones)
    zn = min(ri.a,ri.b)
  else

; Otherwise, calculate link midpoint.
    xmid = (ri.ax + ri.bx)/2
    ymid = (ri.ay + ri.by)/2

; Loop through the centroids to find the centroid nearest this midpoint.
    dmin = 999999
    zn   = 0

    loop iz = 1, {Total zones}
      if (zi.1.x[iz] > 0)
        d = sqrt((zi.1.x[iz] - xmid)^2 + (zi.1.y[iz] - ymid)^2)
        if (d < dmin)
          dmin = d
          zn   = iz
        endif
      endif
    endloop

  endif

 A=RI.A
 B=RI.B
 WRITE RECO=1
 ; print list = ri.a,ri.b,zn, PRINTO=1


ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00L.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01NET00L.PRN" MSG='INSERT LINK DATA TO NETWORK'
FILEI LINKI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\CLOSEST.DBF"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\ZONE.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\WF_{Year}{ALT}.NET"

MERGE RECORD=TRUE, LAST=ZN
PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00J.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01NET00J.PRN" MSG='ADD LAND USE DATA TO ZONES'
FILEI NODEI[2] = "{SCENARIO_DIR}\Land Use_{Year}.dbf"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\merge zone.NET"
FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\ZONE.NET"

merge record=true
PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
_AX=A.X
_BX=B.X
_AY=A.Y
_BY=B.Y
;Find the mid point of each link

;add directionl notations to each link
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X<B.X) ROADDIR='EB' ;east bound
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X>B.X) ROADDIR='WB' ; west bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y<B.Y) ROADDIR='NB' ; north bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y>B.Y) ROADDIR='SB' ; south bound


ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00K.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01NET00K.PRN" MSG='DETERMINE AREA TYPE NEW METHOD'
FILEO PRINTO[3] = "{CATALOG_DIR}\Output\{Scenario_FullName}\STAT.PRN"
FILEO PRINTO[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\DENSITY.PRN"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\AT.dbf"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\PROCESSED.NET"
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\AREA TYPE.PRN"
FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\merge zone.NET"

  zones={Total Zones}

;  merge record=true, last=POP,HH,TOTEMP,RETAIL,SCHOOL,ACRES

  array _centn={Total Zones},_centx={Total Zones},_centy={Total Zones},
        _pop={Total Zones},_totemp={Total Zones},_acres={Total Zones},
        _fltpop={Total Zones},_fltemp={Total Zones},_fltacres={Total Zones},
        _poplu={Total Zones},_emplu={Total Zones}, atype={total zones},_fltpden={Total zones},
        _flteden={Total zones},_difpop={Total zones},_difemp={Total zones},_meanpop={Total zones},_meanemp={Total zones}

; put centroid number and coordinates into arrays
  phase=nodemerge
    if (n<={Total Zones})
      _cnt=_cnt+1
      _centn[_cnt]=n
      _centx[_cnt]=x
      _centy[_cnt]=y
      _pop[_cnt]=pop
      _totemp[_cnt]=tot
      _acres[_cnt]=area
; initialize floating zone arrays
      _fltpop[_cnt]=0
      _fltemp[_cnt]=0
      _fltacres[_cnt]=0
    endif
  endphase

  phase=linkmerge
    _linkcnt=_linkcnt+1


; loop thru centroids to accumulate floating zone data
    if (_linkcnt=1)
      loop _taz=1,{Total Zones}
        loop _taz2=1,{Total Zones}
          if (_taz<={Total Zones})
      ; calculate the distance between the subject TAZ and other TAZs
              _xmiles=(_centx[_taz]-_centx[_taz2])/1609.334
              _ymiles=(_centy[_taz]-_centy[_taz2])/1609.334
              _dist=sqrt(_xmiles^2 + _ymiles^2)
     if(_dist<5.0)   
            ; print form=8.2, list=_taz,_taz2,_dist printo=3
     endif
     ; save info if less than previous nodes
            if (_dist <= {Radius})
              _tmppop=_fltpop[_taz]+_pop[_taz2]
              _fltpop[_taz]=_tmppop
              _tmpemp=_fltemp[_taz]+_totemp[_taz2]
              _fltemp[_taz]=_tmpemp
              _tmpacres=_fltacres[_taz]+_acres[_taz2]
              _fltacres[_taz]=_tmpacres
            endif
          endif
        endloop
; write out the accumulated SE data and acreage for each TAZ
        ;print form=8.0, list=_taz,_fltpop[_taz],_fltemp[_taz],_fltacres[_taz]
        _tmppop=0
        _tmpemp=0
        _tmpacres=0
      endloop
    endif

; Lookup Area Type using Floating Zone Data and Link TAZ

LOOKUP LOOKUPI=1,
       NAME=_AT,
         LOOKUP[1]=PDEN, RESULT=EDI, ; Area Type for Employment Density Group 1
         LOOKUP[2]=PDEN, RESULT=ED2, ; Area Type for Employment Density Group 2
         LOOKUP[3]=PDEN, RESULT=ED3, ; Area Type for Employment Density Group 3
         LOOKUP[4]=PDEN, RESULT=ED4, ; Area Type for Employment Density Group 4
         LOOKUP[5]=PDEN, RESULT=ED5, ; Area Type for Employment Density Group 5
         LOOKUP[6]=PDEN, RESULT=ED6, ; Area Type for Employment Density Group 6
         LOOKUP[7]=PDEN, RESULT=ED7, ; Area Type for Employment Density Group 7
       FAIL[3]=0, INTERPOLATE=N
; example of use: v=AT(7,25)
; look for 25 in the PDEN field and returns the ED7 value


    loop _t=1,{Total Zones}
      _pop=_fltpop[_t]
      _totemp=_fltemp[_t]
      _acres=_fltacres[_t]
      if (_fltacres[_t]=0)   ; this is a check for TAZ's that have no socieconomic data and are just
        _popdensity=0         ;  placeholders or "dummy zones" to be used in future model updates  
        _empdensity=0
      else   
        _popdensity=round((_fltpop[_t]/_fltacres[_t])*100)/100
        _empdensity=round((_fltemp[_t]/_fltacres[_t])*100)/100
        _fltpden[_t]=_popdensity
        _flteden[_t]=_empdensity
      endif
      
      ;if(_t=5)print list=_t,_popdensity,_empdensity
endloop

;Calculate statictal values for population density and employment density data

 if(_linkcnt=1)
    loop _x=1,_cnt
      _tpop=_tpop+_fltpden[_x]    ; total popilation density
      _temp=_temp+_flteden[_x]    ; total employment density
      _obs=_x                     ; total number of observations
      _meanpop=_tpop/_obs         ; mean population density
      _meanemp=_temp/_obs         ; mean employment density
     endloop
  endif

 loop _d=1,{Total zones}
      _difpop[_d]=(_fltpden[_d]-_meanpop)^2       ; square each of the deviations 
      _difemp[_d]=(_flteden[_d]-_meanemp)^2       ; square each of the deviations
 endloop

 if(_linkcnt=1)
    loop _x=1,_cnt
       _totpopdif=_totpopdif+_difpop[_x]          ; sum of population deviation
       _totempdif=_totempdif+_difemp[_x]          ; sum of employment deviation
       _stdevpop=sqrt(_totpopdif/_x)              ; Standard Deviation for population data
       _stdevemp=sqrt(_totempdif/_x)              ; Standard Deviation for employment data 
    endloop
 endif

; Determine Stratification Values for Population Density
   
    _p1=_meanpop-(_meanpop/_stdevpop)*0.5
    _p2=_meanpop+(_meanpop/_stdevpop)*0
    _p3=_meanpop+(_meanpop/_stdevpop)*1
    _p4=_meanpop+(_meanpop/_stdevpop)*2
    _p5=_meanpop+(_meanpop/_stdevpop)*3
    _p6=_meanpop+(_meanpop/_stdevpop)*4
    _p7=_meanpop+(_meanpop/_stdevpop)*5

; Determine Stratification Values for Employment Density
    _e1=_meanemp-(_meanemp/_stdevemp)*0.5
    _e2=_meanemp+(_meanemp/_stdevemp)*0
    _e3=_meanemp+(_meanemp/_stdevemp)*1
    _e4=_meanemp+(_meanemp/_stdevemp)*2
    _e5=_meanemp+(_meanemp/_stdevemp)*3
    _e6=_meanemp+(_meanemp/_stdevemp)*4
    _e7=_meanemp+(_meanemp/_stdevemp)*5

; set population density lookup value

loop _t=1,{Total zones}

      if (_fltpden[_t]<=_p1)
        _poplu[_t]=1
      elseif (_fltpden[_t]>_p1 && _fltpden[_t]<=_p2)
        _poplu[_t]=2
      elseif (_fltpden[_t]>_p2 && _fltpden[_t]<=_p3)
        _poplu[_t]=3
      elseif (_fltpden[_t]>_p3 && _fltpden[_t]<=_p4)
        _poplu[_t]=4
      elseif (_fltpden[_t]>_p4 && _fltpden[_t]<=_p5)
        _poplu[_t]=5
      elseif (_fltpden[_t]>_p5 && _fltpden[_t]<=_p6)
        _poplu[_t]=6
      elseif (_fltpden[_t]>_p6)
        _poplu[_t]=7
      endif

; set empdensity lookup value
      if (_flteden[_t]<=_e1)
        _emplu[_t]=1
      elseif (_flteden[_t]>_e1 && _flteden[_t]<=_e2)
        _emplu[_t]=2
      elseif (_flteden[_t]>_e2 && _flteden[_t]<=_e3)
        _emplu[_t]=3
      elseif (_flteden[_t]>_e3 && _flteden[_t]<=_e4)
        _emplu[_t]=4 
      elseif (_flteden[_t]>_e4 && _flteden[_t]<=_e5)
        _emplu[_t]=5 
      elseif (_flteden[_t]>_e5 && _flteden[_t]<=_e6)
        _emplu[_t]=6
     elseif (_flteden[_t]>_e6)
        _emplu[_t]=7
      endif
endloop

endphase

phase = summary

;  _K=_K+1

 loop _k=1,_cnt
    IF(_K<={Total zones})
    AType[_K]=_AT(_emplu[_K],_poplu[_K])
        ;WRITE RECO=1
    PRINT form=4.0 LIST=_centn[_k],ATYPE[_K] PRINTO=1
    print form=10.2 list=_centn[_k],_fltpden[_k],_flteden[_k], printo=2
    ENDIF
 endloop

print list="\n","\n","****************** STATISTICAL SUMMARY*********************", printo=3
print list="            ", "Total","     Mean", "     Standard Deviation", printo=3
print list="Popluation  ", _tpop(5.0c),_meanpop(9.3c),_stdevpop(23.3c), printo=3
print list="Employment  ", _temp(5.0c),_meanemp(9.3c),_stdevemp(23.3c), printo=3
print list="\n","\n","*****************STRATIFICATION VALUES********************", printo=3
print list="                     Employment","  Less than ",_e1(5.3),_e1(9.3)," to ",_e2(5.3),_e2(9.3)," to ",_e3(5.3),
_e3(9.3)," to ",_e4(5.3),_e4(9.3)," to ",_e5(5.3),_e5(9.3)," to ",_e6(5.3),"   More than ",_e6(5.3),printo=3
print list="Population",printo=3
print list="Less than",_p1(5.3), printo=3
print list=_p1(5.3), " to ", _p2(5.3), printo=3
print list=_p2(5.3), " to ", _p3(5.3), printo=3
print list=_p3(5.3), " to ", _p4(5.3), printo=3
print list=_p4(5.3), " to ", _p5(5.3), printo=3
print list=_p5(5.3), " to ", _p6(5.3), printo=3
print list="More than ", _p6(5.3), printo=3
endphase


ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00N.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01NET00N.PRN" MSG='INSERT LINK AREA TYPE ON THE NETWORK'
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\ATYPE NETOWRK{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\AREA TYPE.PRN"
FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\PROCESSED.NET"


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
LOOKUP NAME=ATYPE,
 LOOKUP[1]=1, RESULT=2,
 INTERPOLATE=N, LOOKUPI=1, list=y


AT1=ATYPE(1,ZN)


if(CBD=1)
 AT1=1
endif

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01MAT00U.S"
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


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00T.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00B.PRN" MSG='Consolidate into 3 Area Types'
FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\ATYPE NETOWRK{Year}{Alternative}.NET"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\Final_AT_{Year}{Alternative}.NET"


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
; Use this phase for combining and reporting of working variables.
If (AT1=1)
    LUD=3
Elseif (AT1=2,3,4)
    LUD=2
Else
    LUD=1
Endif

ENDPROCESS

ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\01NET00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Compute SpeedCap Class'


; example of use: v=NEWSPDCAPTABLE(1,25)
; look for 25 in the SPDCAPCLS field and returns the CAPACITY value


FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Final_AT_{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\SPDCAPCLASS.dbf"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}A.NET"


;Use this phase to modify data as it is read, such as recoding node numbers.
      ; MO=1,2,3,4,                                     ; write MW to table 1
       ;NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"





PROCESS  PHASE=LINKMERGE  

;Distance Checks
;DISTANCE=LENGTH
DISTANCE =(1/1609)*SQRT((a.X-b.X)^2+(a.Y-b.Y)^2)
IF (FACTYPE=12) DISTANCE=0.01

;SPDCAPCLS COMPUTATION

IF (FACTYPE=1&LUD=1) SPDCAPCLS=11

IF (FACTYPE=1&LUD=2) SPDCAPCLS=12

IF (FACTYPE=1&LUD=3) SPDCAPCLS=13

IF (FACTYPE=1&LUD=2) SPDCAPCLS=12

IF (FACTYPE=2&LUD=1) SPDCAPCLS=21

IF (FACTYPE=2&LUD=2) SPDCAPCLS=22

IF (FACTYPE=2&LUD=3) SPDCAPCLS=23

IF (FACTYPE=3&LUD=1) SPDCAPCLS=31

IF (FACTYPE=3&LUD=2) SPDCAPCLS=32

IF (FACTYPE=3&LUD=3) SPDCAPCLS=33

IF (FACTYPE=4&LUD=1) SPDCAPCLS=41

IF (FACTYPE=4&LUD=2) SPDCAPCLS=42

IF (FACTYPE=4&LUD=3) SPDCAPCLS=43

IF (FACTYPE=5&LUD=1) SPDCAPCLS=51

IF (FACTYPE=5&LUD=2) SPDCAPCLS=52

IF (FACTYPE=5&LUD=3) SPDCAPCLS=53

IF (FACTYPE=6&LUD=1) SPDCAPCLS=61

IF (FACTYPE=6&LUD=2) SPDCAPCLS=62
IF (FACTYPE=6&LUD=3) SPDCAPCLS=63

IF (FACTYPE=7&LUD=1) SPDCAPCLS=71

IF (FACTYPE=7&LUD=2) SPDCAPCLS=72

IF (FACTYPE=7&LUD=3) SPDCAPCLS=73

IF (FACTYPE=8&LUD=1) SPDCAPCLS=81

IF (FACTYPE=8&LUD=2) SPDCAPCLS=82

IF (FACTYPE=8&LUD=3) SPDCAPCLS=83

IF (FACTYPE=9&LUD=1) SPDCAPCLS=91

IF (FACTYPE=9&LUD=2) SPDCAPCLS=92

IF (FACTYPE=9&LUD=3) SPDCAPCLS=93

IF (FACTYPE=10&LUD=1) SPDCAPCLS=101

IF (FACTYPE=10&LUD=2) SPDCAPCLS=102

IF (FACTYPE=10&LUD=3) SPDCAPCLS=103

IF (FACTYPE=10&LUD=1) SPDCAPCLS=101

IF (FACTYPE=10&LUD=2) SPDCAPCLS=102

IF (FACTYPE=10&LUD=3) SPDCAPCLS=103

IF (FACTYPE=11&LUD=1) SPDCAPCLS=111

IF (FACTYPE=11&LUD=2) SPDCAPCLS=112

IF (FACTYPE=11&LUD=3) SPDCAPCLS=113

IF (FACTYPE=12&LUD=1) SPDCAPCLS=121

IF (FACTYPE=12&LUD=2) SPDCAPCLS=122

IF (FACTYPE=12&LUD=3) SPDCAPCLS=123

ENDPROCESS





ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\01NET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Capacity and Speed Estimation'

LOOKUP LOOKUPI=1,
       NAME=NEWSPDCAPTABLE,
         LOOKUP[1]=SPDCAPCLS, RESULT=CAPACITY,
         LOOKUP[2]=SPDCAPCLS, RESULT=speed,
       FAIL[3]=0
; example of use: v=NEWSPDCAPTABLE(1,25)
; look for 25 in the SPDCAPCLS field and returns the CAPACITY value


FILEI LINKI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}A.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\NEWSPD-CAP-TABLE.dbf"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"


;Use this phase to modify data as it is read, such as recoding node numbers.
      ; MO=1,2,3,4,                                     ; write MW to table 1
       ;NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"





PROCESS  PHASE=LINKMERGE  
speed_old=post_spd

if (spdcapcls =11-23, 91-110) linkclass=1
if (spdcapcls =31-43) linkclass=2
if (spdcapcls =51-83,111-123) linkclass=3
; Use this phase to make computations and selections of any data on the LINKI files.

  ; If (LI.YEAROPEN=2030) ADDTOGROUP=9 
    ; LW.TIME=(LI.LENGTH/LI.POSTEDSPD)*60
   ;  LW.DISTANCE=LI.LENGTH
    ; C=LI.TOTAL_CAPA
CAPACITY=NEWSPDCAPTABLE(1,SPDCAPCLS)*LANES
post_spd=NEWSPDCAPTABLE(2,SPDCAPCLS)

ENDPROCESS




ENDRUN


; Script for program HIGHWAY in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\01HWY00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\01HWY00A.PRN" MSG='Highway Skims'
FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN"
FILEI ZDATI[1] = "{SCENARIO_DIR}\TERMTIME.DBF"
FILEI NETI = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"

FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\01HWY{Year}A.MAT",
MO=1,2,3,4,                                     ; write MW to table 1
NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"

PHASE=LINKREAD
; Use this phase to obtain initial values from the input network (LI.varname) and compute 
; link values (LW.varname) that can be used in other phases.

     ;If (LI.YEAROPEN=2030) ADDTOGROUP=9 
     LW.TIME=(LI.DISTANCE/LI.POST_SPD)*60
     ;LW.DISTANCE=LI.LENGTH
     C=LI.CAPACITY

ENDPHASE


PHASE=ILOOP
; This phase performs a zonal loop (I=1,Zones).  This phase is required and must contain
; at least 1 PATHLOAD statement.  Almost all MATRIX operation are available in this phase
; and the PATHLOAD statement can be used to build and load paths for assignment
                                  ; loop through all production zones
     PATHLOAD PATH = LW.TIME,  PENI=1,;, EXCLUDEGROUP=9,                       ; develop path based on TIME
              MW[1] = PATHTRACE(LW.TIME), NOACCESS=10000,          ; trace/skim the TIME variable
              MW[2]= PATHTRACE(LI.DISTANCE), NOACCESS=0
     MW[1][i]=(0.5*((ZI.1.AREA[i])^0.5)*60)/20     
     IF (ZI.1.AREA[i]<=3.0) 
        MW[1][i]=(0.5*(ZI.1.Area[i]^0.5)*60)/20 ;intra zonal
     ENDIF     
     IF (ZI.1.Area[i]<=0.11) ;intra zonal
        MW[1][i]=100000000
     ENDIF
     
     MW[3]=ZI.1.TERMTIME[i]+ZI.1.TERMTIME[j]
     IF (i>{IZONES})
      JLOOP
        IF (j>{IZONES})
        MW[1]=100000000
        ENDIF
      ENDJLOOP
     ENDIF
     MW[4]=MW[1]+MW[3]
ENDPHASE


ENDRUN


; Script for program GENERATION in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\02GEN00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\02GEN00A.PRN" MSG='Production-Attraction Estimation'
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Balfac"
FILEI LOOKUPI[4] = "{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf"
FILEI LOOKUPI[3] = "{CATALOG_DIR}\Calibration Constants\PerPurpose.dbf"
FILEI LOOKUPI[2] = "{CATALOG_DIR}\Calibration Constants\TripAttrRates.dbf"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\trip-prod-lookup.dbf"
FILEI ZDATI[1] = "{SCENARIO_DIR}\EXTERNAL{Year}.DBF"
FILEI ZDATI[2] = "{SCENARIO_DIR}\EMPDATA{Year}.DBF"
FILEI ZDATI[3] = "{SCENARIO_DIR}\STRATIFY{Year}.DBF"
FILEI ZDATI[4] = "{SCENARIO_DIR}\POPHHLD{Year}.DBF"
FILEO PAO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN00A.DAT",
FORM=8.0, LIST=Z, P[1], P[2], P[3], A[1], A[2], A[3]

Zones={Total Zones}

; Land Use File NEWTAZ8BLKGRP2.DBF
;    Zone  TAZ number 1-167
;    Population - Total Population
;    Households - Total number of Households
;    Average Size - Average Household Size
;    H1PER - Number of 1 Person Households
;    H2PER - Number of 2 Person Households
;    H3PER - Number of 3 Person Households
;    H4PER - Number of 4 Person Households
;    LOWINC - Number of Low Income Households
;    MEDINC - Number of Medium Income Households
;    HIGHINC - Number of High Income Households

;  Statewide Model Stratification (Number of Households by Income Level)
;    2000Stratify2.dbf
;   ZONE 1-167
;   F1LOW  1 Person Household with low income
;   F2LOW  2 person household with low income
;   F3LOW  3 person household with low income
;   F4LOW  4 person household with low income
;   F1MEDIUM  1 person household with medium income
;   F2MEDIUM  2 person household with medium income
;   F3MEDIUM  3 person household with medium income
;   F4MEDIUM  4 person household with medium income
;   F1HIGH  1 person household with high income
;   F2HIGH  2 person household with high income
;   F3HIGH  3 person household with high income
;   F4HIGH  4 person household with high income

;  Read Employment Data
;  ZONE - Zones 1 through 167
;  Area - Area  
;  Areaa - 2 for Frederick and 1 for Winchester
;  Retail - Retail Employment
;  Service - Service Employment
;  Other - Other Employment
;  Total - Total Employment

;  Read External Data
;  

;  Calculate 2000 Model Stratification


h1low=F1LOW
h2low=F2LOW
h3low=F3LOW
h4low=F4LOW
h1med=F1MEDIUM
h2med=F2MEDIUM
h3med=F3MEDIUM
h4med=F4MEDIUM
h1high=F1HIGH
h2high=F2HIGH
h3high=F3HIGH
h4high=F4HIGH



n=0
loop iter=1,100

; sum column totals (income)

tcollow=h1low+h2low+h3low+h4low
tcolmed=h1med+h2med+h3med+h4med
tcolhigh=h1high+h2high+h3high+h4high

; calculate column factors

if (tcollow>0)
adjcoll=LOWINC/tcollow
else 
adjcoll=1
endif

if (tcolmed>0)
adjcolm=MEDINC/tcolmed
else 
adjcolm=1
endif

if (tcolhigh>0)
adjcolh=HIGHINC/tcolhigh
else 
adjcolh=1
endif

; factor the columns - match total income

h1low=h1low*adjcoll
h2low=h2low*adjcoll
h3low=h3low*adjcoll
h4low=h4low*adjcoll

h1med=h1med*adjcolm
h2med=h2med*adjcolm
h3med=h3med*adjcolm
h4med=h4med*adjcolm

h1high=h1high*adjcolh
h2high=h2high*adjcolh
h3high=h3high*adjcolh
h4high=h4high*adjcolh

; sum rows - households by size

totrow1=h1low+h1med+h1high
totrow2=h2low+h2med+h2high
totrow3=h3low+h3med+h3high
totrow4=h4low+h4med+h4high

; Calculate factors to adjust rows

if (totrow1>0)
adjrow1=H1PER/totrow1
else
adjrow1=1
endif

if (totrow2>0)
adjrow2=H2PER/totrow2
else
adjrow2=1
endif

if (totrow3>0)
adjrow3=H3PER/totrow3
else
adjrow3=1
endif

if (totrow4>0)
adjrow4=H4PER/totrow4
else
adjrow4=1
endif

; Adjust to match row totals - households
h1low=h1low*adjrow1
h2low=h2low*adjrow2
h3low=h3low*adjrow3
h4low=h4low*adjrow4

h1med=h1med*adjrow1
h2med=h2med*adjrow2
h3med=h3med*adjrow3
h4med=h4med*adjrow4

h1high=h1high*adjrow1
h2high=h2high*adjrow2
h3high=h3high*adjrow3
h4high=h4high*adjrow4

n=n+1
EndLoop

PRINT, FORM=8.2, LIST=N, Z, h1low, h1med, h1high, h2low, h2med, h2high, h3low, h3med, h3high,
    h4low, h4med, h4high 


; Define Trip Production Lookup Table
; Trip Rates based on NCHRP 365
;Commented Out by TCG for use of external lookup table.

;-----------------------------------------------------------
;lookup name=prodrate,
      ;lookup[1]=1, result=2,       ; Home Based Work
      ;lookup[2]=1, result=3,       ; Home based Other
      ;lookup[3]=1, result=4,       ; Non-Home Based
      ;list=y,
 ;            HBW      HBO      NHB
 ;    r='1     0.82     2.56     1.68',          ; Area 1 - 1 person low income household
  ;   r='2     1.40     3.86     3.49',          ; Area 1 - 2 person low income household         
   ;  r='3     1.62     4.65     2.87',          ; Area 1 - 3 person low income household
    ; r='4     1.50     8.34     4.63',          ; Area 1 - 4 person low income household
   ;  r='5     1.07     2.24     1.30',          ; Area 1 - 1 person medium income household
   ;  r='6     1.56     3.39     2.87',          ; Area 1 - 2 person medium income household
    ; r='7     2.49     4.77     3.85',          ; Area 1 - 3 person medium income household
    ; r='8     2.90     8.63     5.30',          ; Area 1 - 4 person medium income household
     ;r='9     1.38     1.94     2.89',          ; Area 1 - 1 person high income household
    ; r='10    2.73     3.38     4.00',          ; Area 1 - 2 person high income household
    ; r='11    3.35     5.44     3.22',          ; Area 1 - 3 person high income household
    ; r='12    3.36     9.86     4.47',          ; Area 1 - 4 person high income household
    ; r='13    0.82     2.56     1.68',          ; Area 2 - 1 person low income household
    ; r='14    1.40     3.86     3.49',          ; Area 2 - 2 person low income household         
    ; r='15    1.62     4.65     2.87',          ; Area 2 - 3 person low income household
     ;r='16    1.50     8.34     4.63',          ; Area 2 - 4 person low income household
    ; r='17    1.07     2.24     1.30',          ; Area 2 - 1 person medium income household
    ; r='18    1.56     3.39     2.87',          ; Area 2 - 2 person medium income household
    ; r='19    2.49     4.77     3.85',          ; Area 2 - 3 person medium income household
    ; r='20    2.90     8.63     5.30',          ; Area 2 - 4 person medium income household
   ;  r='21    1.38     1.94     2.89',          ; Area 2 - 1 person high income household
    ; r='22    2.73     3.38     4.00',          ; Area 2 - 2 person high income household
    ; r='23    3.35     5.44     3.22',          ; Area 2 - 3 person high income household
   ;  r='24    3.36     9.86     4.47'         ; Area 2 - 4 person high income household

;------------------------------------------------------------

lookup, lookupi=1, name=prodrate,
       lookup[1]=ROW, result=HBW,
       lookup[2]=ROW, result=HBO,
       lookup[3]=ROW, result=NHB,
INTERPOLATE=N
       



; Define index for production trip rates

; Areap=1

prodi =(Areap-1)*12

; Apply Trip Productions to cross classification of Households (1 to 4+ people/0 to 4+ vehicle)

; Calculate Home Based Work Productions

DInterHBWP = h1low*prodrate(1,prodi+1)+h2low*prodrate(1,prodi+2)+h3low*prodrate(1,prodi+3)+h4low*prodrate(1,prodi+4)+
       h1med*prodrate(1,prodi+5)+h2med*prodrate(1,prodi+6)+h3med*prodrate(1,prodi+7)+h4med*prodrate(1,prodi+8)+
       h1high*prodrate(1,prodi+9)+h2high*prodrate(1,prodi+10)+h3high*prodrate(1,prodi+11)+h4high*prodrate(1,prodi+12)

; Calculate Home Based Other Productions

DInterHBOP = h1low*prodrate(2,prodi+1)+h2low*prodrate(2,prodi+2)+h3low*prodrate(2,prodi+3)+h4low*prodrate(2,prodi+4)+
       h1med*prodrate(2,prodi+5)+h2med*prodrate(2,prodi+6)+h3med*prodrate(2,prodi+7)+h4med*prodrate(2,prodi+8)+
       h1high*prodrate(2,prodi+9)+h2high*prodrate(2,prodi+10)+h3high*prodrate(2,prodi+11)+h4high*prodrate(2,prodi+12)

; Calculate NonHome Based Productions

DInterNHBP = h1low*prodrate(3,prodi+1)+h2low*prodrate(3,prodi+2)+h3low*prodrate(3,prodi+3)+h4low*prodrate(3,prodi+4)+
       h1med*prodrate(3,prodi+5)+h2med*prodrate(3,prodi+6)+h3med*prodrate(3,prodi+7)+h4med*prodrate(3,prodi+8)+
       h1high*prodrate(3,prodi+9)+h2high*prodrate(3,prodi+10)+h3high*prodrate(3,prodi+11)+h4high*prodrate(3,prodi+12)

; Define Trip Attraction Lookup Table
; Trip Rates based on NCHRP 365

/* Commented Out by TCG for the use of DBF lookup table */
;---------------------------------------------------------------------------------------------------
;lookup name=attrate,
       ;lookup[1]=1, result=2,       ; Home Based Work
       ;lookup[2]=1, result=3,       ; Home based Other
       ;lookup[3]=1, result=4,       ; Non-Home Based
       ;list=y,

;              HBW      HBO      NHB
;    r='1     0.00     2.00     1.40',          ; Retail Employment in CBD - Area 1 (Winchester)
 ;   r='2     0.00     1.70     1.20',          ; Service Employment - Area 1
 ;   r='3     0.00     4.00     4.00',          ; Other Employment - Area 1
 ;   r='4     0.00     0.40     0.30',          ; Households - Area 1
 ;   r='5     1.45     0.00     0.00',          ; Total Employment - Area 1
 ;   r='6     0.00     9.00     4.10',          ; Retail Employment in Non-CBD - Area 2 (Frederick)
 ;   r='7     0.00     1.70     1.20',          ; Service Employment - Area 2
 ;   r='8     0.00     4.00     4.00',          ; Other Employment - Area 2
 ;   r='9     0.00     0.40     0.20',          ; Households - Area 2
 ;   r='10    1.45     0.00     0.00'            ; Total Employment - Area 2
;----------------------------------------------------------------------------------------------------
 ;    r='11    0.00    11.40     9.44',          ; Retail Employment in CBD - Area 3 (Route 1 Corridor)
 ;    r='12    0.00     2.35     2.76',          ; Service Employment - Area 3
 ;    r='13    0.00     0.76     1.26',          ; Other Employment - Area 3
 ;    r='14    0.00     0.24     0.20',          ; Households - Area 3
 ;    r='15    2.74     0.00     0.00'          ; Total Employment - Area 3

lookup, lookupi=2, name=attrate,
       lookup[1]=ROW, result=HBW,       ; Home Based Work
       lookup[2]=ROW, result=HBO,       ; Home based Other
       lookup[3]=ROW, result=NHB,       ; Non-Home Based
INTERPOLATE=N


; Define index for attaction trip rates

atti =(Areaa-1)*5

; Apply Trip Attraction Rates to Employment Data

; Calculate Home Based Work Attractions

DInterHBWA = Total*attrate(1,atti+5)

; Calculate Home Based Other Attractions

DInterHBOA = Retail*attrate(2,atti+1)+Servi*attrate(2,atti+2)+Other*attrate(2,atti+3)+Households*attrate(2,atti+4)

; Calculate NonHome Based Attractions

DInterNHBA = Retail*attrate(3,atti+1)+Servi*attrate(3,atti+2)+Other*attrate(3,atti+3)+Households*attrate(3,atti+4)

;If (i=124) 
; DInterHBWA=DInterHBWA+3612
;DInterHBOA=DInterHBOA+2451
;DInterNHBA=DInterNHBA+2452
;Endif

DailyHBWP=DailyHBWP+DInterHBWP

DailyHBOP=DailyHBOP+DInterHBOP

DailyNHBP=DailyNHBP+DInterNHBP

DailyHBWA=DailyHBWA+DInterHBWA

DailyHBOA=DailyHBOA+DInterHBOA
 
DailyNHBA=DailyNHBA+DInterNHBA


;following commented out as a test
;If (i=167)
;DailyProd=DailyHBWP+DailyHBOP+DailyNHBP
;DailyAttr=DailyHBWA+DailyHBOA+DailyNHBA
;PRINT LIST='Daily Trips',
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='HBWP= ',DailyHBWP(8.0),
; FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='HBOP= ',DailyHBOP(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='NHBP= ',DailyNHBP(8.0),
; FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='Productions= ',DailyProd(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='HBWA= ',DailyHBWA(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='HBOA= ',DailyHBOA(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='NHBA= ',DailyNHBA(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='Attractions= ',DailyAttr(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;Endif


; P[1]=DInterHBWP
; p[2]=DInterHBOP
; P[3]=DInterNHBP
; A[1]=DInterHBWA
; A[2]=DInterHBOA
; A[3]=DInterNHBA


;  Calculate Externals Person Trips

/* Commented out by TCG for the use of external lookup table*/
;-------------------------------------------------------------------
;lookup name=perpurp,
       ;lookup[1]=1, result=2,       ; Daily
       ;list=y,
;              Daily      
     ;r='1     0.26',          ; Percent HBW
     ;r='2     0.52',          ; Percent HBO
     ;r='3     0.22'          ; Percent NHB
;-----------------------------------------------------------------------

lookup, lookupi=3, name=perpurp,
lookup[1]=ROW, result=PERCENT,       ; Daily
INTERPOLATE=N


/* Commented out by TCG for the use of external lookup table*/
;-------------------------------------------------------------
;lookup name=autoocc,
       ;lookup[1]=1, result=2,       ; Daily
       ;list=y,
;              Daily      
    ; r='1     1.11',           ; HBW Auto Occupancy
    ; r='2     1.56',             ; HBO Auto Occupancy
    ; r='3     1.56'              ; NHB Auto Occupancy
;------------------------------------------------------------

lookup, lookupi=4, name=autoocc,
lookup[1]=ROW, result=AUTOOCC,       ; Daily
INTERPOLATE=N

DExtHBWP=(TOTAL_IEEI*perpurp(1,1)*autoocc(1,1)*.41); modified by TCG by reviewing Census JTW
DExtHBWA=(TOTAL_IEEI*perpurp(1,1)*autoocc(1,1)*.59)
DExtHBOP=(TOTAL_IEEI*perpurp(1,2)*autoocc(1,2)*.5)
DExtHBOA=(TOTAL_IEEI*perpurp(1,2)*autoocc(1,2)*.5)
DExtNHBP=(TOTAL_IEEI*perpurp(1,3)*autoocc(1,3)*.5)
DExtNHBA=(TOTAL_IEEI*perpurp(1,3)*autoocc(1,3)*.5)

TDExtHBWP=TDExtHBWP+DExtHBWP
TDExtHBOP=TDExtHBOP+DExtHBOP
TDExtNHBP=TDExtNHBP+DExtNHBP
TDExtHBWA=TDExtHBWA+DExtHBWA
TDExtHBOA=TDExtHBOA+DExtHBOA
TDExtNHBA=TDExtNHBA+DExtNHBA


; MORNING AND EVENING UNBALANCED PRODUCTIONS AND ATTRACTIONS

UBHBWP=UBHBWP+DInterHBWP+DExtHBWP
UBHBOP=UBHBOP+DInterHBOP+DExtHBOP
UBNHBP=UBNHBP+DInterNHBP+DExtNHBP
UBHBWA=UBHBWA+DInterHBWA+DExtHBWA
UBHBOA=UBHBOA+DInterHBOA+DExtHBOA
UBNHBA=UBNHBA+DInterNHBA+DExtNHBA

;If (i=199)
;PRINT LIST='     ',
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='Daily Unbalanced Trips (With Externals)',
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='DHBWPUB= ',UBHBWP(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='DHBOPUB= ',UBHBOP(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"

;PRINT LIST='DNHBPUB= ',UBNHBP(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='DHBWAUB= ',UBHBWA(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='DHBOAUB= ',UBHBOA(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;PRINT LIST='DNHBAUB= ',UBNHBA(8.0),
 ;FILE = "C:\Models\VDOT\Winchester\Winchester Model Files\2003\SUMDAILY.TXT"
;Endif

;  Assign Productions and Attractions

 P[1] = DInterHBWP+DExtHBWP
 P[2] = DInterHBOP+DExtHBOP
 P[3] = DInterNHBP+DExtNHBP
 A[1] = DInterHBWA+DExtHBWA
 A[2] = DInterHBOA+DExtHBOA
 A[3] = DInterNHBA+DExtNHBA

; Calculate Balance Factors

BalHBW=(DailyHBWP+TDExtHBWP-TDExtHBWA)/DailyHBWA
BalHBO=(DailyHBOP+TDExtHBOP-TDExtHBOA)/DailyHBOA
BalNHB=(DailyNHBP+TDExtNHBP-TDExtNHBA)/DailyNHBA



;BalHBW=(DailyHBWP+TDExtHBWP)/(DailyHBWA+DExtHBWA)

;BalHBO=(DailyHBOP+TDExtHBOP)/(DailyHBOA+DExtHBOA)

;BalNHB=(DailyNHBP+TDExtNHBP)/(DailyNHBA+TDExtNHBA)

If (i={Total Zones})

PRINT LIST='1     ',BalHBW(12.10),printo=1
              ; BalHBWA - Balance HBW Attractions to match productions',
; FILE = "C:\MODELS\VDOT\WINCHESTER\WINCHESTER MODEL FILES\2003\DAILYBALFAC.TXT"
print LIST='2     ',BalHBO(12.10),printo=1
 ;            ; BalHBOA - Balance HBO Attractions to match productions',
; FILE = "C:\MODELS\VDOT\WINCHESTER\WINCHESTER MODEL FILES\2003\DAILYBALFAC.TXT"
print LIST='3     ',BalNHB(12.10), printo=1
             ; BalNHBP - Balance NHB attractions to match productions',
 ;FILE = "C:\MODELS\VDOT\WINCHESTER\WINCHESTER MODEL FILES\2003\DAILYBALFAC.TXT"
Endif


; Balance productions and attractions

;Phase=Adjust

;BALANCE A2P=1,2,3,4,5,6



ENDRUN


; Script for program GENERATION in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\02GEN00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\02GEN00B.PRN" MSG='Balancing Productions and Attractions'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Balfac"

FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN00A.DAT",
Z=#1, UBHBWP=#2, UBHBOP=#3, UBNHBP=#4, UBHBWA=#5, UBHBOA=#6, UBNHBA=#7
FILEO PAO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT",
FORM=10.O, LIST=Z, P[1], P[2], P[3],  
                  A[1], A[2], A[3]


Zones={Total Zones}

lookup,lookupi=1,
NAME=Balance,    ; Balance factor lookup table
       lookup[1]=1, result=2       ; Factors
;LOOKUP,
; FILE = "{SCENARIO_DIR}\DAILYBALFAC.TXT",
       ;NAME=Balance,    ; Balance factor lookup table
       ;lookup[1]=1, result=2       ; Factors
     
; Balance Internal Trips
If (i<={IZONES})

BalHBWP=UBHBWP
BalHBWA=UBHBWA*Balance(1,1)
BalHBOP=UBHBOP
BalHBOA=UBHBOA*Balance(1,2)
BalNHBP=UBNHBP
BalNHBA=UBNHBA*Balance(1,3)

BalNHBP=BalNHBA     ; set productions equal to attractions for each internal zone
hh=hh
Else

BalHBWP=UBHBWP
BalHBWA=UBHBWA
BalHBOP=UBHBOP
BalHBOA=UBHBOA
BalNHBP=UBNHBP
BalNHBA=UBNHBA

Endif

p[1]=BalHBWP
p[2]=BalHBOP
P[3]=BalNHBP
A[1]=BalHBWA
A[2]=BalHBOA
A[3]=BalNHBA



Phase=Adjust

BALANCE A2P=1,2,3,4,5,6

;p[1]=BalHBWP+SPHBWP

;p[2]=BalHBOP+SPHBOP
;P[3]=BalNHBP+SPNHBP
;A[1]=BalHBWA+SPHBWA
;A[2]=BalHBOA+SPHBOA
;A[3]=BalNHBA+SPHBWA

ENDRUN


; Script for program DISTRIBUTION in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\03DST00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\03DST00A.PRN" MSG='Vehicle Trip Table Estimation'
FILEI LOOKUPI[2] = "{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\01HWY{Year}A.MAT"
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT",
Z=#1, P1=#2, P2=#3, P3=#4, A1=#5, A2=#6, A3=#7 
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\ffacfin.dbf"
FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT",
MO=1-3,7,17 NAME=HBW,HBO,NHB,TotPerPA,TotVehPA  

MAXITERS={AITERS},MAXRMSE=1              ; set max iterations and
                                                     ; closure criteria
/*Commented out by TCG for the use of DBF file*/
;-----------------------------------------------------------
   ;LOOKUP,
 ;FILE = "{SCENARIO_DIR}\FFACFIN.PRN",
 ;INTERPOLATE=Y, NAME=FF,    ; friction factor lookup
        ;LOOKUP[1]=1,RESULT=2,
        ;LOOKUP[2]=1,RESULT=3,
        ;LOOKUP[3]=1,RESULT=4
;--------------------------------------------------------------

   LOOKUP,lookupi=1,name=FF,           ; friction factor lookup                 
   LOOKUP[1]=ROW,RESULT=HBW,
   LOOKUP[2]=ROW,RESULT=HBO,
   LOOKUP[3]=ROW,RESULT=NHB,
 INTERPOLATE=Y

    SETPA P[1]=P1  A[1]=A1                           ; setup the P & A arrays
    SETPA P[2]=P2  A[2]=A2
    SETPA P[3]=P3  A[3]=A3


    MW[10] = MI.1.TOTTIME                               ; put time into matrix 10

    GRAVITY   PURPOSE=1, LOS=MW[10], FFACTORS=FF;, KFACTORS=MI.3.KFACTOR     ; run 3 gravity models
    FREQUENCY VALUEMW=1  BASEMW=10,  RANGE=1-100     ; frequency distribution
    GRAVITY   PURPOSE=2, LOS=MW[10], FFACTORS=FF;, KFACTORS=MI.3.KFACTOR 
    FREQUENCY VALUEMW=2  BASEMW=10,  RANGE=1-100
    GRAVITY   PURPOSE=3, LOS=MW[10], FFACTORS=FF;, KFACTORS=MI.3.KFACTOR
    FREQUENCY VALUEMW=3  BASEMW=10,  RANGE=1-100

; MW[20]=mi.2.DailyEE

;---------------------------------------------
;lookup name=autoocc,
       ;lookup[1]=1, result=2,       ; Morning Peak
       ;list=y,
;              AM      PM
     ;r='1     1.11',          ; HBW Auto Occupancy
     ;r='2     1.56',          ; HBO Auto Occupancy
    ; r='3     1.56'          ; NHB Auto Occupancy
;------------------------------------------------     

   lookup, lookupi=2, name=autoocc,
   lookup[1]=ROW, result=AUTOOCC,       ; Morning peak
   INTERPOLATE=N

   MW[11]=MW[1]/autoocc(1,1)
   MW[12]=MW[2]/autoocc(1,2)
   MW[13]=MW[3]/autoocc(1,3)

   MW[7]=MW[1]+MW[2]+MW[3]

   MW[17]=MW[11]+MW[12]+MW[13]


ENDRUN


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\04MAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\04MAT00A.PRN" MSG='Build External Trip Tables Using Old TP+ Model (2003) Data'

FILEO MATO[3] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT00C.MAT",
              MO=3,
              Name=DailyEE

FILEO MATO[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}B.MAT",
              MO=2,
              Name=PMEE

FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}A.MAT",
              MO=1,
              Name=AMEE


FILEI MATI[3] = "{SCENARIO_DIR}\DAILYEE{Year}.PRN",
         pattern=IJ:V fields=#1,2,3
      Zones={Total Zones}
      mw[3]=mi.3.1

FILEI MATI[2] = "{SCENARIO_DIR}\PMEE{Year}.PRN",
              pattern=IJ:V fields=#1,2,3
      Zones={Total Zones}
      MW[2]=mi.2.1


FILEI MATI[1] = "{SCENARIO_DIR}\AMEE{Year}.PRN",
                   pattern=IJ:V fields=#1,2,3
      Zones={Total Zones}
      mw[1]=mi.1.1

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

ENDRUN


; Script for program FRATAR in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\04FRA00A.S"
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


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\04MAT00D.S"
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


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\05MAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00A.PRN" MSG='Prepare Matrix for Peak Hour Conversion'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00A.MAT",
MO=1-3,11-13, Name=HBWPer, HBOPer, NHBPer, HBWVeh, HBOVeh, NHBVeh


PAR ZONEMSG=10
JLOOP
fizone=1
lizone={IZONES}
fezone=lizone+1
lezone=_zones
  ; Balance IE
IF (I=fizone-lizone&J=fezone-lezone)
    MW[1]= ((MI.1.HBW+MI.1.HBW.T) * .5)
    MW[2]= ((MI.1.HBO+MI.1.HBO.T) * .5)
    MW[3]= ((MI.1.NHB+MI.1.NHB.T) * .5)
endif
  ; Balance EI
IF (I=fezone-lezone&J=fizone-lizone)
    MW[1]= ((MI.1.HBW+MI.1.HBW.T) * .5)
    MW[2]= ((MI.1.HBO+MI.1.HBO.T) * .5)
    MW[3]= ((MI.1.NHB+MI.1.NHB.T) * .5)
endif
  ; II equals PA original
IF (I=fizone-lizone&J=fizone-lizone)
    MW[1]= MI.1.HBW
    MW[2]= MI.1.HBO
    MW[3]= MI.1.NHB
endif

ENDJLOOP

/*Commented out by TCG for the use of external lookup tables*/
;-------------------------------------------------

;lookup name=autoocc,
       ;lookup[1]=1, result=2,       ; Morning Peak
       ;list=y,
;              AM      PM
     ;r='1     1.11',          ; HBW Auto Occupancy
     ;r='2     1.56',          ; HBO Auto Occupancy
     ;r='3     1.56'          ; NHB Auto Occupancy
;-------------------------------------------------

   lookup, lookupi=1, name=autoocc,
   lookup[1]=ROW, result=AUTOOCC,       ; Morning peak
   INTERPOLATE=N
     
MW[11]=MW[1]/autoocc(1,1)
MW[12]=MW[2]/autoocc(1,2)
MW[13]=MW[3]/autoocc(1,3)


ENDRUN


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\05MAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00B.PRN" MSG='AM AND PM Peak Hour Trip Tables'
FILEI MATI[3] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}B.MAT"
FILEI MATI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}A.MAT"
FILEI MATI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00A.MAT"
FILEO MATO[2] = "{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00C.MAT",
MO=5-8 NAME=PMHBWVeh, PMHBOVeh, PMNHBVeh, TotPMVeh

FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00B.MAT",
MO=1-4 NAME=AMHBWVeh, AMHBOVeh, AMNHBVeh, TotAMVeh

FILEI ZDATI[1] = "{SCENARIO_DIR}\EXTERNAL{Year}.DBF"

PAR ZONEMSG=10
JLOOP
fizone=1
lizone={IZONES}
fezone=lizone+1
lezone=_zones
  ; APPLY IE FACTORS
IF (I=fizone-lizone&J=fezone-lezone)
    MW[1]=(MI.1.HBWVeh)*ZI.1.AMPerIE[J]
    MW[2]=(MI.1.HBOVeh)*ZI.1.AMPerIE[J]
    MW[3]=(MI.1.NHBVeh)*ZI.1.AMPerIE[J]
    MW[4]=MW[1]+MW[2]+MW[3]
    MW[5]=(MI.1.HBWVeh)*ZI.1.PMPerIE[J]
    MW[6]=(MI.1.HBOVeh)*ZI.1.PMPerIE[J]
    MW[7]=(MI.1.NHBVeh)*ZI.1.PMPerIE[J]
    MW[8]=MW[5]+MW[6]+MW[7]
endif
  ; APPLY EI FACTORS
IF (I=fezone-lezone&J=fizone-lizone)
    MW[1]=MI.1.HBWVeh*ZI.1.AMPerEI[I]
    MW[2]=MI.1.HBOVeh*ZI.1.AMPerEI[I]
    MW[3]=MI.1.NHBVeh*ZI.1.AMPerEI[I]
    MW[4]=MW[1]+MW[2]+MW[3]
    MW[5]=MI.1.HBWVeh*ZI.1.PMPerEI[I]
    MW[6]=MI.1.HBOVeh*ZI.1.PMPerEI[I]
    MW[7]=MI.1.NHBVeh*ZI.1.PMPerEI[I]
    MW[8]=MW[5]+MW[6]+MW[7]
endif
;    APPLY THE II FACTORS
IF (I=fizone-lizone&J=fizone-lizone)
    MW[1]=(MI.1.HBWVeh)*0.1528+(MI.1.HBWVeh.T)*0.0066
    MW[2]=(MI.1.HBOVeh)*0.0510+(MI.1.HBOVeh.T)*0.0034
    MW[3]=(MI.1.NHBVeh)*0.0104+(MI.1.NHBVeh.T)*0.0104
    MW[4]=MW[1]+MW[2]+MW[3]
    MW[5]=(MI.1.HBWVeh)*0.0077+(MI.1.HBWVeh.T)*0.1188
    MW[6]=(MI.1.HBOVeh)*0.0337+(MI.1.HBOVeh.T)*0.0395
    MW[7]=(MI.1.NHBVeh)*0.0428+(MI.1.NHBVeh.T)*0.0428
    MW[8]=MW[5]+MW[6]+MW[7]
ENDIF
;    APPLY THE EE FACTORS
 IF (I=fezone-lezone&J=fezone-lezone)
    mw[4]=mi.2.AMEE
    mw[8]=mi.3.PMEE
 ENDIF

ENDJLOOP


ENDRUN


; Script for program HIGHWAY in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\06HWY00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\06HWY00A.PRN" MSG='DAILY'
FILEI NETI = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"
FILEI MATI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\04MAT00H.MAT"
FILEO NETO = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\06HWY00A.MAT",
MO=1, Name=Sellnk

FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN",
MISSINGLINK=1


PARAMETERS MAXITERS = {ITERS},                 ; maximum number of iterations
           GAP=0.005,
           RMSE=.005
FUNCTION TC[1]=T0 *(1 + 0.84* (V/C) ^ 5.5) ;Freeways
;FUNCTION TC[1]=T0 *(1 + 0.15* (V/C) ^ 4) ;Freeways
FUNCTION TC[2]=T0 *(1 + 0.56* (V/C) ^ 3.6) ;Arterials
FUNCTION TC[3]=T0 *(1 + 0.8* (V/C) ^ 2.5)    ;Locals and Collectors
FUNCTION TC[4]=T0 ;Centroid Connectros

PHASE=LINKREAD
     ;If (LI.YEAROPEN=2030) ADDTOGROUP=9
     T0 =(LI.DISTANCE/LI.POST_SPD)*60
     ;LW.DISTANCE=LI.LENGTH
  ;  C=((LI.TOTAL_CAPA)*0.75)/0.10
     C=((LI.CAPACITY))*{CAPCONFAC}
FACTYPE=LI.FACTYPE
if(FACTYPE=1-2,9,10)
 linkclass=1
endif
if(FACTYPE=3-5)
linkclass=2
endif
if(FACTYPE=6-8)
linkclass=3
endif
if(FACTYPE=11-12)
linkclass=4
endif
  ENDPHASE

Function V=VOL[1]
PHASE=ILOOP                              ; main loop for module
         PATH=TIME, PENI=1, ;, EXCLUDEGROUP=9,                    ; build path based on time  
         ;VOL[1]=MI.1.TotVehODAdj, mw[1]=MI.1.TotVehODAdj, selectlink = (L=3244-3484),    ; load trips from input matrix
         Vol[1]=mw[1],
         mw[1]=MI.1.TotVehOD   
         
ENDPHASE

PROCESS PHASE=ADJUST
; This phase is automatically run after the ILOOP phase.  The volume-delay functions (TC) are
; automatically recomputed in this phase to update the link congested travel times based 
; on the volumes from the ILOOP phase.  User defined link computations (LW.varname) that 
; need to be updated based on the new congested travel times should be coded in this phase.

  PARAMETERS COMBINE=EQUI, RELATIVEGAP=0.0001

ENDPROCESS

PHASE=CONVERGE
  IF (ITERATION < 6) BREAK; Do not even test for Iterations 2-5
  IF (GAP[ITERATION]<GAPCUTOFF & GAP[ITERATION-1]<GAPCUTOFF & GAP[ITERATION-2]<GAPCUTOFF)
     BALANCE = 1
  ENDIF
ENDPHASE


ENDRUN


; Script for program HIGHWAY in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\06HWY00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\06HWY00B.PRN" MSG='AM ASSIGNMENT'
FILEI NETI = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"
FILEI MATI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00B.MAT"
FILEO NETO = "{CATALOG_DIR}\output\{Scenario_FullName}\AMLOADED_{Year}.NET"
FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN",
MISSINGLINK=1


PARAMETERS MAXITERS = {ITERS},                 ; maximum number of iterations
           GAP=0.01
FUNCTION TC[1]=T0 *(1 + 0.15* (V/C) ^ 4)

PHASE=LINKREAD
     ;IF (LI.YEAROPEN=2030) ADDTOGROUP=9
     T0 =(LI.DISTANCE/LI.POST_SPD)*60
     ;LW.DISTANCE=LI.LENGTH
   ;  C=((LI.TOTAL_CAPA)*0.75)
     C=(LI.CAPACITY)
  ENDPHASE

Function V=VOL[1]
PHASE=ILOOP                              ; main loop for module
         PATH=TIME, PENI=1, ;, EXCLUDEGROUP=9,                   ; build path based on time  
         ;VOL[1]=MI.1.TotAMVeh, mw[1]=MI.1.TotAMVeh, selectlink = (L=192-2059),          ; load trips from input matrix
         Vol[1]=mw[1],
         mw[1]=MI.1.TotAMVeh
ENDPHASE




ENDRUN


; Script for program HIGHWAY in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\Applications\06HWY00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\06HWY00C.PRN" MSG='PM ASSIGNMENT'
FILEI NETI = "{CATALOG_DIR}\Output\{Scenario_FullName}\01NET{Year}B.NET"
FILEI MATI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00C.MAT"
FILEO NETO = "{CATALOG_DIR}\output\{Scenario_FullName}\PMLOADED_{Year}.NET"
FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN",
MISSINGLINK=1


PARAMETERS MAXITERS ={ITERS},                 ; maximum number of iterations
           GAP=0.01
FUNCTION TC[1]=T0 *(1 + 0.15* (V/C) ^ 4)

PHASE=LINKREAD
     ;IF (LI.YEAROPEN=2030) ADDTOGROUP=9
     T0 =(LI.DISTANCE/LI.POST_SPD)*60
     ;LW.DISTANCE=LI.LENGTH
    ; C=(LI.TOTAL_CAPA)*0.75
     C=(LI.CAPACITY)
  ENDPHASE
  
Function V=VOL[1]
PHASE=ILOOP                              ; main loop for module
         PATH=TIME, PENI=1, ;, EXCLUDEGROUP=9,                  ; build path based on time  
        ; VOL[1]=MI.1.TotPMVeh, mw[1]=MI.1.TotPMVeh, selectlink= (L=192-2059),          ; load trips from input matrix
         Vol[1]=mw[1],
         mw[1]=MI.1.TotPMVeh
ENDPHASE


ENDRUN


; Script for program HIGHWAY in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\06HWY00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\06HWY00D.PRN" MSG='Congested Skim'
FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT",
MO=1,2,3,4,                                     ; write MW to table 1
NAME= TIME,DISTANCE,TERM,TOTTIME                               ; name table 1 "TIME"

FILEI ZDATI[1] = "{SCENARIO_DIR}\TERMTIME.DBF"
FILEI TURNPENI = "{SCENARIO_DIR}\TURNPEN{Year}.PEN"
FILEI NETI = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"

PHASE=LINKREAD
; Use this phase to obtain initial values from the input network (LI.varname) and compute 
; link values (LW.varname) that can be used in other phases.

     ;If (LI.YEAROPEN=2030) ADDTOGROUP=9 
     LW.TIME=LI.TIME_6
     ;LW.DISTANCE=LI.LENGTH
     C=LI.CAPACITY

   

ENDPHASE


PHASE=ILOOP
; This phase performs a zonal loop (I=1,Zones).  This phase is required and must contain
; at least 1 PATHLOAD statement.  Almost all MATRIX operation are available in this phase
; and the PATHLOAD statement can be used to build and load paths for assignment
                                  ; loop through all production zones
     PATHLOAD PATH = LW.TIME,  PENI=1,;, EXCLUDEGROUP=9,                       ; develop path based on TIME
              MW[1] = PATHTRACE(LW.TIME), NOACCESS=10000,          ; trace/skim the TIME variable
              MW[2]= PATHTRACE(LI.DISTANCE), NOACCESS=0
     MW[1][i]=(0.5*((ZI.1.AREA[i])^0.5)*60)/20     
     IF (ZI.1.AREA[i]<=3.0) 
        MW[1][i]=(0.5*(ZI.1.Area[i]^0.5)*60)/20 ;intra zonal
     ENDIF     
     IF (ZI.1.Area[i]<=0.11) ;intra zonal
        MW[1][i]=100000000
     ENDIF
     
     MW[3]=ZI.1.TERMTIME[i]+ZI.1.TERMTIME[j]
     IF (i>{IZONES})
      JLOOP
        IF (j>{IZONES})
        MW[1]=100000000
        ENDIF
      ENDJLOOP
     ENDIF
     MW[4]=MW[1]+MW[3]
ENDPHASE
 


ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\07NET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Links with Counts'
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO LINKO = "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\OUTPUT\BASE\ALL_LINKS.DBF",
INCLUDE= V_6,FEDFUNC, COUNT,A,B,dir, FORMAT=DBF

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
;IF (EXT_COUNT>0) DELETE
IF (COUNT=0) DELETE
IF (FEDFUNC=8) DELETE
ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\07NET00B.S"
 ; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\logs\RMSELOG.PRN" MSG='RMSE & Vol/CNT'
FILEO LINKO = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\COUNT_LINKS.dbf"
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\reports\RMSE.PRN"

PARAMETERS  ZONES={Total Zones}

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
_calcheck={Calibration Run}


   ft=FEDFUNC; FTYPE1
   at=LUD; ATYPE1
   LNS=LANES
if (dir=0)
       TOTAL_VOL=ROUND(VT_6/2)
else
      TOTAL_VOL=ROUND(VT_6)
endif
         ;_TOTAL_VOLUME=TOTAL_VOL

   ;DISTANCE=LENGTH
  ; _TOTAL_VOLUME=TOTAL_VOL

  ;if(COUNT>0&EXT_COUNT=0&dir=0) 
     ;count   = ROUND(COUNT)
  ;elseif(COUNT>0&EXT_COUNT=0&dir<>0)
     ;count   = COUNT
  if(COUNT>0&dir=0&FACTYPE<>12) 
     count   = ROUND(COUNT)
  elseif(COUNT>0&dir<>0&FACTYPE<>12)
     count   = COUNT
   ELSEIF(_CALCHECK=0 & FACTYPE<>11)
      COUNT=CAPACITY*{CAPCONFAC}
   ELSE
      COUNT=0
   ENDIF
  
_aK = count
_ak_grp =count*2

  links=1
   lanemiles=LANES*DISTANCE

if(count=0) DELETE

; *****************************
;
; initialize arrays and variables
   ARRAY _err=13, _cns=13, _cnt=13, _RGP=13, _volbyft=100, _cntbyft=100
   ARRAY _volbyat=100, _cntbyat=100, _lnkbyft=100, _lnkbyat=100
   _group=(0.0*ft)
   _RGP[1]=1, _RGP[2]=5000, _RGP[3]=10000, _RGP[4]=20000, _RGP[5]=30000, _RGP[6]=40000, _RGP[7]=50000,
   _RGP[8]=60000, _RGP[9]=70000, _RGP[10]=80000, _RGP[11]=90000, _RGP[12]=100000, _RGP[13]=500000
   IF (A=1)
     LOOP _iter=1,13
           _err[_iter]=0,_cnt[_iter]=0,_cns[_iter]=0
     ENDLOOP
     LOOP _iter=1,99
           _volbyft[_iter]=0, _cntbyft[_iter]=0, _lnkbyft[_iter]=0
           _volbyat[_iter]=0, _cntbyat[_iter]=0, _lnkbyat[_iter]=0
     ENDLOOP
   ENDIF

; establish some English sounding variables for the output network
   _LINKS=links
   _LANEMILES=lanemiles
; calculate and compartmentalize 
   IF(_aK>0) VOLCNT=TOTAL_VOL/_aK, NETDIFF=TOTAL_VOL-_aK, ABSDIFF=ABS(NETDIFF), ERRORSQ=NETDIFF^2, PCTDIFF=100*NETDIFF/_aK _group=1
   
;commented out by Srin for accurate groups creation for Winchester
   IF (_aK_grp>5000) _group=2
   IF (_aK_grp>10000) _group=3
   IF (_aK_grp>20000) _group=4
   IF (_aK_grp>30000) _group=5
   IF (_aK_grp>40000) _group=6
   IF (_aK_grp>50000) _group=7
   IF (_aK_grp>60000) _group=8
   IF (_aK_grp>70000) _group=9
   IF (_aK_grp>80000) _group=10
   IF (_aK_grp>90000) _group=11
   IF (_aK_grp>100000) _group=12

    GRP=_group
    ;IF (_aK>2500) _group=2
    ;IF (_aK>5000) _group=3
    ;IF (_aK>10000) _group=4
    ;IF (_aK>15000) _group=5
    ;IF (_aK>20000) _group=6
    ;IF (_aK>25000) _group=7
    ;IF (_aK>30000) _group=8
    ;IF (_aK>35000) _group=9
    ;IF (_aK>40000) _group=10
    ;IF (_aK>45000) _group=11
    ;IF (_aK>50000) _group=12

   IF (_aK>0) 
   _ERR[_group]=ERRORSQ+_ERR[_group], _CNS[_group]=_aK+_CNS[_group], _CNT[_group]=_CNT[_group]+1
   _ERR[13]=ERRORSQ+_ERR[13], _CNS[13]=_aK+_CNS[13], _CNT[13]=_CNT[13]+1
   ENDIF
IF (_aK>0)  
   _volbyft[ft]=_volbyft[ft]+TOTAL_VOL
   _cntbyft[ft]=_cntbyft[ft]+_aK
   _lnkbyft[ft]=_lnkbyft[ft]+1
   _volbyat[at]=_volbyat[at]+TOTAL_VOL
   _cntbyat[at]=_cntbyat[at]+_aK
   _lnkbyat[at]=_lnkbyat[at]+1
   _volbyft[100]=_volbyft[100]+TOTAL_VOL
   _cntbyft[100]=_cntbyft[100]+_aK
   _lnkbyft[100]=_lnkbyft[100]+1
   _volbyat[100]=_volbyat[100]+TOTAL_VOL
   _cntbyat[100]=_cntbyat[100]+_aK
   _lnkbyat[100]=_lnkbyat[100]+1
endif
CROSSTAB  VAR= _LINKS, VAR= _LANEMILES form=12.0c,
    row=ft, range=0-9-1,0-9,
    col=LNS, range=0-6-1,0-6
IF (_aK>0)
CROSSTAB  VAR= _TOTAL_VOLUME, VAR= _aK form=12.0c,
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4
ENDIF

;====XTABS of Number of Links and Lane-Miles for Links with Traffic Counts and
;====         VOL/VMT/VHT for Count and Volumes and their ratios for links with traffic counts

IF (COUNT>0)
  CONGTIME=TIME_6
  _A_VOL=TOTAL_VOL                    ;Assigned Volume
  _C_VOL=COUNT                        ;Count  
  _A_VMT=DISTANCE*TOTAL_VOL           ;Volume-VMT
  _C_VMT=DISTANCE*COUNT               ;Count-VMT
  _A_VHT=TOTAL_VOL*(CONGTIME/60.)     ;Volume-VHT
  _C_VHT=COUNT*(CONGTIME/60.)         ;Count-VHT
  _C_LINKS=1                          ;Links with Counts on it
  _CLNMLS=lns*distance                ;Lane Miles with traffic count on links


 CROSSTAB VAR=_C_LINKS form=7.0c, VAR=_CLNMLS form=10.2c,
          VAR=_A_VOL form=12.0c, VAR=_C_VOL _A_VMT _C_VMT _A_VHT _C_VHT,  
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4,
    comp=_A_VOL/_C_VOL,form=8.3,
    comp=_A_VMT/_C_VMT,form=8.3,
    comp=_A_VHT/_C_VHT,form=8.3
    

  CROSSTAB VAR=_C_LINKS form=7.0c, VAR=_CLNMLS form=10.2c,
           VAR=_A_VOL form=12.0c, VAR=_C_VOL,_A_VMT,_C_VMT,_A_VHT,_C_VHT, 
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4,
    comp=_A_VOL/_C_VOL,form=8.3,
    comp=_A_VMT/_C_VMT,form=8.3,
    comp=_A_VHT/_C_VHT,form=8.3
 
ENDIF
;ENDIF

ENDPROCESS

; Use this phase to make computations and selections of any data on the LINKI files.




; Use this phase for combining and reporting of working variables.
; =========================================================
; SUMMARY REPORTING
; =========================================================
PHASE=SUMMARY
PRINT LIST="{SCENARIO_FULLNAME}" PRINTO=1
PRINT LIST="{SCENARIO_SHORTNAME}\n" PRINTO=1
; a little loop to write out the Percent Root Mean Square Error
LOOP _iter=1,12  
  if (_iter=1) print list="*********************** ALL COUNT ROOT MEAN SQUARE ERROR SUMMARY ***********************", printo=1
  if (_cnt[_iter]>0) print,        
 list="  Percent RMSE for Volume Group ",_iter(2.0c)," ",_RGP[_iter](7.0c),"-",_RGP[_iter+1](7.0c),": ",sqrt(_err[_iter]/_cnt[_iter])/(_cns[_iter]/_cnt[_iter])*100(5.1),"%,                      N=",_cnt[_iter](5.0CL), PRINTO=1
ENDLOOP
_iter=13
 list="  Percent RMSE for Volume Group ",_iter(2.0c)," ",_RGP[1](7.0c),"-",_RGP[_iter](7.0c),": ",sqrt(_err[_iter]/_cnt[_iter])/(_cns[_iter]/_cnt[_iter])*100(5.1),"%,                      N=",_cnt[_iter](5.0CL), PRINTO=1

; one for Vol/Cnt by FT 
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n ********************** VOLUME AND COUNT SUMMARY BY FEDERAL FUNC **********************", PRINTO=1
if (_cntbyft[_iter]>0) print,
 list="Federal Func Summary for FT=",_iter(3.0c),
 " VOL=",_volbyft[_iter](11.0c),
 " CNT=",_cntbyft[_iter](11.0c),
 " VOL/CNT=",(_volbyft[_iter]/_cntbyft[_iter])(5.2c),
 "   N=",_lnkbyft[_iter](5.0c), PRINTO=1
ENDLOOP

; one for Vol/Cnt by AT/LUD
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n ************************* VOLUME AND COUNT SUMMARY BY LANDUSE ************************", PRINTO=1
if (_cntbyat[_iter]>0) print,
 list="    Landuse Summary for LU=",_iter(3.0c),
 " VOL=",_volbyat[_iter](11.0c),
 " CNT=",_cntbyat[_iter](11.0c),
 " VOL/CNT=",(_volbyat[_iter]/_cntbyat[_iter])(5.2c),
 "   N=",_lnkbyat[_iter](5.0c), PRINTO=1
ENDLOOP

ENDPROCESS

ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\07NET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\logs\07NET00A.PRN" MSG='Detailed RMSE & VOL/CNT'
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO PRINTO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\reports\detRMSE.PRN"

PARAMETERS  ZONES={Total Zones}

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
_calcheck={Calibration Run}


   ft=FEDFUNC; FTYPE1
   at=LUD; ATYPE1
   LNS=LANES
if (dir=0)
       TOTAL_VOL=ROUND(VT_6/2)
;TOTAL_VOL=ROUND(V_6)
else
      TOTAL_VOL=ROUND(VT_6)
endif
         ;_TOTAL_VOLUME=TOTAL_VOL

   ;DISTANCE=LENGTH
  ; _TOTAL_VOLUME=TOTAL_VOL

  ;if(COUNT>0&EXT_COUNT=0&dir=0) 
     ;count   = ROUND(COUNT)
  ;elseif(COUNT>0&EXT_COUNT=0&dir<>0)
     ;count   = COUNT
  if(COUNT>0&dir=0&FACTYPE<>12) 
     count   = ROUND(COUNT)
  elseif(COUNT>0&dir<>0&FACTYPE<>12)
     count   = COUNT
   ;ELSEIF(_CALCHECK=0 & FUNCCLASS<>11)
      ;COUNT=CAPACITY*{CAPCONFAC}
   ELSE
      COUNT=0
   ENDIF
   _aK     = count
  links=1
   lanemiles=LANES*DISTANCE

; *****************************
;
; initialize arrays and variables
   ARRAY _err=13, _cns=13, _cnt=13, _RGP=13, _volbyft=100, _cntbyft=100
   ARRAY _volbyat=100, _cntbyat=100, _lnkbyft=100, _lnkbyat=100
   _group=(0.0*ft)
   _RGP[1]=1, _RGP[2]=500, _RGP[3]=1000, _RGP[4]=2000, _RGP[5]=3000, _RGP[6]=4000, _RGP[7]=5000,
   _RGP[8]=10000, _RGP[9]=20000, _RGP[10]=30000, _RGP[11]=40000, _RGP[12]=60000, _RGP[13]=100000

   IF (A=1)
     LOOP _iter=1,13
           _err[_iter]=0,_cnt[_iter]=0,_cns[_iter]=0
     ENDLOOP
     LOOP _iter=1,99
           _volbyft[_iter]=0, _cntbyft[_iter]=0, _lnkbyft[_iter]=0
           _volbyat[_iter]=0, _cntbyat[_iter]=0, _lnkbyat[_iter]=0
     ENDLOOP
   ENDIF

; establish some English sounding variables for the output network
   _LINKS=links
   _LANEMILES=lanemiles
; calculate and compartmentalize 
   IF(_aK>0) VOLCNT=TOTAL_VOL/_aK, NETDIFF=TOTAL_VOL-_aK, ABSDIFF=ABS(NETDIFF), ERRORSQ=NETDIFF^2, PCTDIFF=100*NETDIFF/_aK _group=1
   
;commented out by Srin for accurate groups creation for Winchester
   ;IF (_aK>5000) _group=2
   ;IF (_aK>10000) _group=3
   ;IF (_aK>20000) _group=4
   ;IF (_aK>30000) _group=5
   ;IF (_aK>40000) _group=6
   ;IF (_aK>50000) _group=7
   ;IF (_aK>60000) _group=8
   ;IF (_aK>70000) _group=9
   ;IF (_aK>80000) _group=10
   ;IF (_aK>90000) _group=11
   ;IF (_aK>100000) _group=12

    IF (_aK>250) _group=2
    IF (_aK>500) _group=3
    IF (_aK>1000) _group=4
    IF (_aK>1500) _group=5
    IF (_aK>2000) _group=6
    IF (_aK>2500) _group=7
    IF (_aK>5000) _group=8
    IF (_aK>10000) _group=9
    IF (_aK>15000) _group=10
    IF (_aK>20000) _group=11
    IF (_aK>30000) _group=12

   IF (_aK>0) 
   _ERR[_group]=ERRORSQ+_ERR[_group], _CNS[_group]=_aK+_CNS[_group], _CNT[_group]=_CNT[_group]+1
   _ERR[13]=ERRORSQ+_ERR[13], _CNS[13]=_aK+_CNS[13], _CNT[13]=_CNT[13]+1
   ENDIF
IF (_aK>0)  
   _volbyft[ft]=_volbyft[ft]+TOTAL_VOL
   _cntbyft[ft]=_cntbyft[ft]+_aK
   _lnkbyft[ft]=_lnkbyft[ft]+1
   _volbyat[at]=_volbyat[at]+TOTAL_VOL
   _cntbyat[at]=_cntbyat[at]+_aK
   _lnkbyat[at]=_lnkbyat[at]+1
   _volbyft[100]=_volbyft[100]+TOTAL_VOL
   _cntbyft[100]=_cntbyft[100]+_aK
   _lnkbyft[100]=_lnkbyft[100]+1
   _volbyat[100]=_volbyat[100]+TOTAL_VOL
   _cntbyat[100]=_cntbyat[100]+_aK
   _lnkbyat[100]=_lnkbyat[100]+1
endif
CROSSTAB  VAR= _LINKS, VAR= _LANEMILES form=12.0c,
    row=ft, range=0-9-1,0-9,
    col=LNS, range=0-6-1,0-6
IF (_aK>0)
CROSSTAB  VAR= _TOTAL_VOLUME, VAR= _aK form=12.0c,
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4
ENDIF

;====XTABS of Number of Links and Lane-Miles for Links with Traffic Counts and
;====         VOL/VMT/VHT for Count and Volumes and their ratios for links with traffic counts

IF (COUNT>0)
  CONGTIME=TIME_6
  _A_VOL=TOTAL_VOL                    ;Assigned Volume
  _C_VOL=COUNT                        ;Count  
  _A_VMT=DISTANCE*TOTAL_VOL           ;Volume-VMT
  _C_VMT=DISTANCE*COUNT               ;Count-VMT
  _A_VHT=TOTAL_VOL*(CONGTIME/60.)     ;Volume-VHT
  _C_VHT=COUNT*(CONGTIME/60.)         ;Count-VHT
  _C_LINKS=1                          ;Links with Counts on it
  _CLNMLS=lns*distance                ;Lane Miles with traffic count on links


 CROSSTAB VAR=_C_LINKS form=7.0c, VAR=_CLNMLS form=10.2c,
          VAR=_A_VOL form=12.0c, VAR=_C_VOL _A_VMT _C_VMT _A_VHT _C_VHT,  
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4,
    comp=_A_VOL/_C_VOL,form=8.3,
    comp=_A_VMT/_C_VMT,form=8.3,
    comp=_A_VHT/_C_VHT,form=8.3
    

  CROSSTAB VAR=_C_LINKS form=7.0c, VAR=_CLNMLS form=10.2c,
           VAR=_A_VOL form=12.0c, VAR=_C_VOL,_A_VMT,_C_VMT,_A_VHT,_C_VHT, 
    row=ft, range=0-9-1,0-9,
    col=at, range=0-4-1,0-4,
    comp=_A_VOL/_C_VOL,form=8.3,
    comp=_A_VMT/_C_VMT,form=8.3,
    comp=_A_VHT/_C_VHT,form=8.3
 
ENDIF
;ENDIF

ENDPROCESS

; Use this phase to make computations and selections of any data on the LINKI files.




; Use this phase for combining and reporting of working variables.
; =========================================================
; SUMMARY REPORTING
; =========================================================
PHASE=SUMMARY
PRINT LIST="{SCENARIO_FULLNAME}" PRINTO=1
PRINT LIST="{SCENARIO_SHORTNAME}\n" PRINTO=1
; a little loop to write out the Percent Root Mean Square Error
LOOP _iter=1,12  
  if (_iter=1) print list="*********************** ALL COUNT ROOT MEAN SQUARE ERROR SUMMARY ***********************", printo=1
  if (_cnt[_iter]>0) print,        
 list="  Percent RMSE for Volume Group ",_iter(2.0c)," ",_RGP[_iter](7.0c),"-",_RGP[_iter+1](7.0c),": ",sqrt(_err[_iter]/_cnt[_iter])/(_cns[_iter]/_cnt[_iter])*100(5.1),"%,                      N=",_cnt[_iter](5.0CL), PRINTO=1
ENDLOOP
_iter=13
 list="  Percent RMSE for Volume Group ",_iter(2.0c)," ",_RGP[1](7.0c),"-",_RGP[_iter](7.0c),": ",sqrt(_err[_iter]/_cnt[_iter])/(_cns[_iter]/_cnt[_iter])*100(5.1),"%,                      N=",_cnt[_iter](5.0CL), PRINTO=1

; one for Vol/Cnt by FT 
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n ********************** VOLUME AND COUNT SUMMARY BY FEDERAL FUNC **********************", PRINTO=1
if (_cntbyft[_iter]>0) print,
 list="Federal Func Summary for FT=",_iter(3.0c),
 " VOL=",_volbyft[_iter](11.0c),
 " CNT=",_cntbyft[_iter](11.0c),
 " VOL/CNT=",(_volbyft[_iter]/_cntbyft[_iter])(5.2c),
 "   N=",_lnkbyft[_iter](5.0c), PRINTO=1
ENDLOOP

; one for Vol/Cnt by AT
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n ************************* VOLUME AND COUNT SUMMARY BY LANDUSE ************************", PRINTO=1
if (_cntbyat[_iter]>0) print,
 list="    Landuse Summary for LU=",_iter(3.0c),
 " VOL=",_volbyat[_iter](11.0c),
 " CNT=",_cntbyat[_iter](11.0c),
 " VOL/CNT=",(_volbyat[_iter]/_cntbyat[_iter])(5.2c),
 "   N=",_lnkbyat[_iter](5.0c), PRINTO=1
ENDLOOP

ENDPROCESS

ENDRUN


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\07NET00D.S"
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


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\07MAT00A.S"
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


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\07MAT00B.S"
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


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\WMMAT00A.S"
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


; Script for program NETWORK in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\WMNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\WMNET00.PRN"
FILEI NODEI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\PandA.dbf"
FILEI LINKI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\DAILYLOADED_{Year}.NET"
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\LU.prn"
FILEO NETO = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\Loaded",
EXCLUDE =ZN, TIME, V1T_6, V_6, VC_6, CSPD_6, VDT_6, VHT_6, V1_6, VT_6,ZONE,COUNT
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\CONGESTION_PARAMETERS.dbf"




LOOKUP LOOKUPI=1,
       NAME=LOS,
         LOOKUP[1]=ID, RESULT=FRESEV,
         LOOKUP[2]=ID, RESULT=FRESOM,
         LOOKUP[3]=ID, RESULT=OTHSEV,
         LOOKUP[4]=ID, RESULT=OTHSOM,
       FAIL[3]=0


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.
if(n=170-217) DELETE
if(n=111-135 || n=137-162 || n=164-167) JURIS='Winchester'
if(n=1-110 || n=136 || n=163 || n=168-169) JURIS='Frederick'
if(n=218-249) JURIS = 'External'


_pop=_pop+pop
_hh=_hh+households

log prefix=node var=_pop,_hh

if(n={Total zones}) print list="1",_pop,_hh, printo=1

ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.



CZONE=li.1.ZN
FFTIME=(LI.1.DISTANCE/LI.1.POST_SPD)*60
Volume = li.1.V_6
C_TIME = li.1.TIME_6
VCAP_RATIO = li.1.VC_6
C_SPEED = li.1.CSPD_6
VMT = ROUND(VT_6)*Distance
VHT = li.1.VHT_6
ONE_WAY_VOL = li.1.V_6
TWO_WAY_VOL = li.1.VT_6

if(a<b) TWO_WAY_CNT=li.1.COUNT
if(TWO_WAY_CNT>0)VC_RATIO=TWO_WAY_VOL/TWO_WAY_CNT


SCREEN=li.1.SCRNLN_CODE



;*****************************************************************************************************
;                 Determine congestion level on each link based on Volume to Capacity ratio 
;*****************************************************************************************************

 IF (FACTYPE=1-2)
  IF(VCAP_RATIO<LOS(2,1)) VOL_CAP='Free'
  IF(VCAP_RATIO>=LOS(2,1) && VCAP_RATIO<LOS(1,1)) VOL_CAP='Moderate'
  IF(VCAP_RATIO>=LOS(1,1)) VOL_CAP='Severe'
 ENDIF

 IF (FACTYPE>2)
  IF(VCAP_RATIO<LOS(4,1)) VOL_CAP='Free'
  IF(VCAP_RATIO>=LOS(4,1) && VCAP_RATIO<LOS(3,1)) VOL_CAP='Moderate'
  IF(VCAP_RATIO>=LOS(3,1)) VOL_CAP='Severe'
 ENDIF

;*********************************************************************************************************
;Determine LOS for screenline locations and locations with high, medium and low Volume to Capacity ratios
;*********************************************************************************************************

IF(SCREEN>0) ;=16-39,78-81,54,354,41,104,372,41-53,351,243,54-64,354,361,17,71,62,102,42,372,60)
 SCRNCHK=1
  IF (FACTYPE=1-2)
    IF(VCAP_RATIO<LOS(2,1)) SCRN_VC='Free'
    IF(VCAP_RATIO>=LOS(2,1) && VCAP_RATIO<LOS(1,1)) SCRN_VC='Moderate'
    IF(VCAP_RATIO>=LOS(1,1)) SCRN_VC='Severe'
  ENDIF

  IF (FACTYPE>2)
   IF(VCAP_RATIO<LOS(4,1)) SCRN_VC='Free'
  IF(VCAP_RATIO>=LOS(4,1) && VCAP_RATIO<LOS(3,1)) SCRN_VC='Moderate'
   IF(VCAP_RATIO>=LOS(3,1)) SCRN_VC='Severe'
  ENDIF

ENDIF

;*******************************************************************************************************
                           ; Give names to Facility Types for reporting purposes
;********************************************************************************************************

if(factype=1) FACILITY='Interstate'
if(factype=2) FACILITY='Minor Freeway'
if(factype=3) FACILITY='Principal Arterial'     
if(factype=4) FACILITY='Major Arterial'
if(factype=5) FACILITY='Minor Arterial'
if(factype=6) FACILITY='Major Collector'
if(factype=7) FACILITY='Minor Collector'
if(factype=8) FACILITY='Local'
if(factype=9) FACILITY='High Speed Ramp'
if(factype=10) FACILITY='Low Speed Ramp'
if(factype=11) FACILITY='Centroid Conn'
if(factype=12) FACILITY='External Stn'


;********************************************************************************************************
                                             ; Give names for Area Type Codes 
;********************************************************************************************************

if(LUD=1) AREA_TYPE='Rural'
if(LUD=2) AREA_TYPE='Urban'
if(LUD=3) AREA_TYPE='CBD'

if(CZONE=1-110 || CZONE=136 || CZONE=163 || CZONE=168-169) JURIS='Frederick Cnty'
if(CZONE=111-135 || CZONE=137-162 || CZONE=164-167) JURIS='Winchester City'


if(CZONE=1-110 || CZONE=136 || CZONE=163 || CZONE>167) JCODE=2   ; County
if(CZONE=111-135 || CZONE=137-162 || CZONE=164-167) JCODE=1    ; City



ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\WMMAT00C.S"
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


; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\WMMAT00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\WMMAT00D.PRN"
FILEI MATI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\Model_Area_Trip_Chracterstics.DBF",
FIELDS=purpose,time,distance,code



; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.


zones={Total Zones}

;For Harrisonburg Region

   mw[1]=mi.1.1                          ;HBW Person Trips
   mw[2]=mi.1.2                          ;HBSch Person Trips
   mw[3]=mi.1.3                          ;HBO Person Trips

   mw[4]=mi.1.4                            ;total
   mw[9]=mi.2.4                          ;Uncongested Times with Terminal Times
   mw[10]=mi.2.2                          ;Uncongested Distances with Terminal Distances

array time=4, dist=4, trips=4
array cnty_time=4, cnty_dist=4, cnty_trips=4
array city_time=4, city_dist=4, city_trips=4


;**************************************************************************************************
;                                          Frederick County w/o City
;**************************************************************************************************
if(z<111 || z=136 || z=163 || z>167)

loop iter=1,4
   mw[13]=mw[iter]*mw[9]                  ;Time calculation
   mw[14]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   city_time[iter]=rowsum(13)+city_time[iter]
   city_dist[iter]=rowsum(14)+city_dist[iter]
   city_trips[iter]=rowsum(iter)+city_trips[iter]
elseif (i=169)
   city_time[4]=city_time[1]+city_time[2]+city_time[3]
   city_dist[4]=city_dist[1]+city_dist[2]+city_dist[3]
   city_trips[4]=city_trips[1]+city_trips[2]+city_trips[3]
endif

if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if(i=169)
    ro.purpose=iters
    ro.time=city_time[iter]/city_trips[iter]
    ro.distance=city_dist[iter]/city_trips[iter]
    code=1
    write reco=1 ; 2
endif

endloop

endif


;**************************************************************************************************
;                                          Winchester City
;**************************************************************************************************

if(z=111-135 || z=137-162 || z=164-167)

loop iter=1,4
   mw[13]=mw[iter]*mw[9]                  ;Time calculation
   mw[14]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   cnty_time[iter]=rowsum(13)+cnty_time[iter]
   cnty_dist[iter]=rowsum(14)+cnty_dist[iter]
   cnty_trips[iter]=rowsum(iter)+cnty_trips[iter]
elseif (i=167)
   cnty_time[4]=cnty_time[1]+cnty_time[2]+cnty_time[3]
   cnty_dist[4]=cnty_dist[1]+cnty_dist[2]+cnty_dist[3]
   cnty_trips[4]=cnty_trips[1]+cnty_trips[2]+cnty_trips[3]
endif

if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if(i=167)
    ro.purpose=iters
    ro.time=cnty_time[iter]/cnty_trips[iter]
    ro.distance=cnty_dist[iter]/cnty_trips[iter]
    code=2
    write reco=1  ;3
endif

endloop

endif



;**************************************************************************************************
;                                          Model Region
;**************************************************************************************************

loop iter=1,4
   mw[11]=mw[iter]*mw[9]                  ;Time calculation
   mw[12]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   time[iter]=rowsum(11)+time[iter]
   dist[iter]=rowsum(12)+dist[iter]
   trips[iter]=rowsum(iter)+trips[iter]
elseif (i=zones)
   time[4]=time[1]+time[2]+time[3]
   dist[4]=dist[1]+dist[2]+dist[3]
   trips[4]=trips[1]+trips[2]+trips[3]
endif


if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if (i=zones)
    ro.purpose=iters
    ro.time=time[iter]/trips[iter]
    ro.distance=dist[iter]/trips[iter]
    code=3
    write reco=1
endif

endloop


;***************************************************************************************
;***************************************************************************************



ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


if({Calibration Run}=1)
; End of PILOT Script

; Script for program MATRIX in file "K:\RAL_TPTO\_Modeling\_CURRENT WORK\WinFred Model\WinFred_Reporting_Model - 2012\APPLICATIONS\WMMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\WMMAT00B.PRN" MSG='Determine RMSE and other Statistics'
FILEI RECI = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\COUNT_LINKS.dbf"
FILEO RECO[3] = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\VCbyAT",
FIELDS=GRPAT,ERRAT,CNTAT,CNSAT,RMSEAT,VOlAT,VCAT,LIMAT

FILEO RECO[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\VC",
FIELDS=GRPFT,ERRFT,CNTFT,CNSFT,RMSEFT,VOlFT,VCFT,LIMFT

FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\GDB_MAPS\Results.mdb\RMSE",
FIELDS=GRP,ERR,CNT,CNS,RMSE,VOl,VC,LIM,
       GRPFT,ERRFT,CNTFT,CNSFT,RMSEFT,VOlFT,VCFT,LIMFT,
       GRPAT,ERRAT,CNTAT,CNSAT,RMSEAT,VOlAT,VCAT,LIMAT

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

array err=10000, cnt=10000, cns=10000, rmse=10000, grp=10000, limit=10000,vol=10000,vc=10000,lim=10000
array errft=10000, cntft=10000, cnsft=10000, rmseft=10000, grpft=10000, limitft=10000,volft=10000,vcft=10000,limft=10000
array errat=10000, cntat=10000, cnsat=10000, rmseat=10000, grpat=10000, limitat=10000,volat=10000,vcat=10000,limat=10000

_err=ri.errorsq

if({Calibration Run}=1)
   _cnt=ri.count
else
   _cnt=ri.capacity
endif

_cns=ri.links
_grp=ri.grp
_vol=ri.total_vol
_ft=ri.factype
_at=ri.LUD


if({Calibration Run}=1)

;**************************************************************************************************************
;                                        RMSE Report only for Base Year
;**************************************************************************************************************

if(ri.grp=1-12)
 ERR[ri.grp]=ERR[ri.grp]+_err
 CNT[ri.grp]=CNT[ri.grp]+_cnt
 CNS[ri.grp]=CNS[ri.grp]+_cns
 RMSE[ri.grp]=(sqrt(ERR[ri.grp]/CNS[ri.grp])/(CNT[ri.grp]/CNS[ri.grp]))*100
 GRP[ri.grp]=ri.grp
 VOL[ri.grp]=VOL[ri.grp]+_vol
 VC[ri.grp]=VOL[ri.grp]/CNT[ri.grp]


endif

 ERR[10000]=ERR[10000]+_err
 CNT[10000]=CNT[10000]+_cnt
 CNS[10000]=CNS[10000]+_cns
 RMSE[10000]=(sqrt(ERR[10000]/CNS[10000])/(CNT[10000]/CNS[10000]))*100
 GRP[10000]=100
 VOL[10000]=VOL[10000]+_vol
 VC[10000]=VOL[10000]/CNT[10000]


if(i=0)
 loop _n=1,10000
  if(RMSE[_n]>0)
    RO.GRP=GRP[_n]
    RO.ERR=ERR[_n]
    RO.CNT=CNT[_n]
    RO.CNS=CNS[_n]
    RO.RMSE=RMSE[_n]
    RO.VOL=VOL[_n]
    RO.VC=VC[_n]

     if(GRP[_n]=1) _lim='1 - 5,000'
     if(GRP[_n]=2) _lim='5,000 - 10,000'
     if(GRP[_n]=3) _lim='10,000 - 20,000'
     if(GRP[_n]=4) _lim='20,000 - 30,000'
     if(GRP[_n]=5) _lim='30,000 - 40,000'
     if(GRP[_n]=6) _lim='40,000 - 50,000'
     if(GRP[_n]=7) _lim='50,000 - 60,000'
     if(GRP[_n]=8) _lim='60,000 - 70,000'
     if(GRP[_n]=9) _lim='70,000 - 80,000'
     if(GRP[_n]=10) _lim='80,000 - 90,000'
     if(GRP[_n]=11) _lim='90,000 - 100,000'
     if(GRP[_n]=12) _lim='More than 100,000'
     if(GRP[_n]=100) _lim='All'

    RO.LIM=_LIM
   Write reco=1
    RO.GRP=0
    RO.ERR=0
    RO.CNT=0
    RO.CNS=0
    RO.RMSE=0
    RO.VOL=0
    RO.VC=0
    RO.LIM=''
  endif
endloop
endif

endif ; base year condition
;*********************************************************************************************************
;                                      Volume to Count Summary by Facility Type
;*********************************************************************************************************

if(ri.factype=1-10)
 CNTFT[ri.factype]=CNTFT[ri.factype]+_cnt
 CNSFT[ri.factype]=CNSFT[ri.factype]+_cns
 ; Only for Base Year
 if({Calibration Run}=1)
   ERRFT[ri.factype]=ERRFT[ri.factype]+_err
   RMSEFT[ri.factype]=(sqrt(ERRFT[ri.factype]/CNSFT[ri.factype])/(CNTFT[ri.factype]/CNSFT[ri.factype]))*100
 endif

 GRPFT[ri.factype]=ri.factype
 VOLFT[ri.factype]=VOLFT[ri.factype]+_vol
 VCFT[ri.factype]=VOLFT[ri.factype]/CNTFT[ri.factype]
endif


 CNTFT[10000]=CNTFT[10000]+_cnt
 CNSFT[10000]=CNSFT[10000]+_cns

  if({Calibration Run}=1)
    RMSEFT[10000]=(sqrt(ERRFT[10000]/CNSFT[10000])/(CNTFT[10000]/CNSFT[10000]))*100
    ERRFT[10000]=ERRFT[10000]+_err
  endif

 GRPFT[10000]=100
 VOLFT[10000]=VOLFT[10000]+_vol
 VCFT[10000]=VOLFT[10000]/CNTFT[10000]


if(i=0)
 loop _n=1,10000
  if(VOLFT[_n]>0)
    RO.GRPFT=GRPFT[_n]
    RO.ERRFT=ERRFT[_n]
    RO.CNTFT=CNTFT[_n]
    RO.CNSFT=CNSFT[_n]
    RO.RMSEFT=RMSEFT[_n]
    RO.VOLFT=VOLFT[_n]
    RO.VCFT=VCFT[_n]

      if(GRPFT[_n]=1) _limft='Interstate'
      if(GRPFT[_n]=2) _limft='Minor Freeway'
      if(GRPFT[_n]=3) _limft='Principal Art'
      if(GRPFT[_n]=4) _limft='Major Art'
      if(GRPFT[_n]=5) _limft='Minor Art'
      if(GRPFT[_n]=6) _limft='Major Collector'
      if(GRPFT[_n]=7) _limft='Minor Collector'
      if(GRPFT[_n]=8) _limft='Local'
      if(GRPFT[_n]=9) _limft='H.S. Ramp'
      if(GRPFT[_n]=10) _limft='L.S. Ramp'
      if(GRPFT[_n]=100) _limft='All'

   RO.LIMFT=_limft
   Write reco=2
   Write reco=1

   RO.GRPFT=0
   RO.GRPFT=0
   RO.ERRFT=0
   RO.CNTFT=0
   RO.CNSFT=0
   RO.RMSEFT=0
   RO.VOLFT=0
   RO.VCFT=0
   RO.LIMFT=''
  endif
endloop
endif

;*********************************************************************************************************
;                      Volume to Count Summary by Area Type
;*********************************************************************************************************

if(ri.AT=1-5)
 ERRAT[ri.AT]=ERRAT[ri.AT]+_err
 CNTAT[ri.AT]=CNTAT[ri.AT]+_cnt
 CNSAT[ri.AT]=CNSAT[ri.AT]+_cns
 RMSEAT[ri.AT]=(sqrt(ERRAT[ri.AT]/CNSAT[ri.AT])/(CNTAT[ri.AT]/CNSAT[ri.AT]))*100
 GRPAT[ri.AT]=ri.AT
 VOLAT[ri.AT]=VOLAT[ri.AT]+_vol
 VCAT[ri.AT]=VOLAT[ri.AT]/CNTAT[ri.AT]
endif

 ERRAT[10000]=ERRAT[10000]+_err
 CNTAT[10000]=CNTAT[10000]+_cnt
 CNSAT[10000]=CNSAT[10000]+_cns
 RMSEAT[10000]=(sqrt(ERRAT[10000]/CNSAT[10000])/(CNTAT[10000]/CNSAT[10000]))*100
 GRPAT[10000]=100
 VOLAT[10000]=VOLAT[10000]+_vol
 VCAT[10000]=VOLAT[10000]/CNTAT[10000]


if(i=0)
 loop _n=1,10000
  if(VOLAT[_n]>0)
    RO.GRPAT=GRPAT[_n]
    RO.ERRAT=ERRAT[_n]
    RO.CNTAT=CNTAT[_n]
    RO.CNSAT=CNSAT[_n]
    RO.RMSEAT=RMSEAT[_n]
    RO.VOLAT=VOLAT[_n]
    RO.VCAT=VCAT[_n]
      
      if(GRPAT[_n]=1) _limat='CBD'
      if(GRPAT[_n]=2) _limat='Urban'
      if(GRPAT[_n]=3) _limat='Rural'
      if(GRPAT[_n]=100) _limat='All'
   RO.LIMAT=_limat
   Write reco=3
   Write reco=1

   RO.GRPAT=0
   RO.GRPAT=0
   RO.ERRAT=0
   RO.CNTAT=0
   RO.CNSAT=0
   RO.RMSEAT=0
   RO.VOLAT=0
   RO.VCAT=0
   RO.LIMAT=''

  endif
endloop

endif

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


endif
; End of PILOT Script

