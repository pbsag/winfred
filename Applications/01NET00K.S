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
