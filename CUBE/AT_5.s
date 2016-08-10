; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT-5.PRN" MSG='DETERMINE AREA TYPE FROM LAND USE DENSITY AND PROXIMITY'
FILEO PRINTO[3] = "{SCENARIO_DIR}\Output\STAT.PRN"
FILEO PRINTO[2] = "{SCENARIO_DIR}\Output\DENSITY.PRN"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\AT.dbf"
FILEO NETO = "{SCENARIO_DIR}\Output\PROCESSED.NET"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\AREA TYPE.PRN"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\merge zone.NET"

zones={Total Zones}

;# Lookup Area Type using Floating Zone Data and Link TAZ
LOOKUP LOOKUPI=1,
   NAME=_AT,
     LOOKUP[1]=index, RESULT=at,
   SETUPPER=T
;# example of use: at = _AT(1, 5.2)
;# look for 5.2 in the index field and returns the at value

;#  merge record=true, last=POP,HH,TOTEMP,RETAIL,SCHOOL,ACRES

array _centn={Total Zones},_centx={Total Zones},_centy={Total Zones},
      _hh={Total Zones},_totemp={Total Zones},_acres={Total Zones},
      _flthh={Total Zones},_fltemp={Total Zones},_fltacres={Total Zones},
      _areaindex={Total Zones}, _fltcnt={Total Zones}, AType={Total Zones}

;# put centroid number and coordinates into arrays
  phase=nodemerge
    if (n<={Total Zones})
      _cnt = _cnt+1
      _centn[_cnt] = n
      _centx[_cnt] = x
      _centy[_cnt] = y
      _hh[_cnt] = hh
      _totemp[_cnt] = emp
      _acres[_cnt] = acres
      ;# initialize floating zone arrays
      _flthh[_cnt]=0
      _fltemp[_cnt]=0
      _fltacres[_cnt]=0
    endif
  endphase

  phase = linkmerge
    _linkcnt=_linkcnt+1
    
    ;# loop thru centroids to accumulate floating zone data
    if (_linkcnt=1) ;# do this only on the first pass
      loop _taz=1,{Total Zones}
        loop _taz2=1,{Total Zones}
          if (_taz<={Total Zones})
           ;# calculate the distance between the subject TAZ and other TAZs
            _xmiles=(_centx[_taz]-_centx[_taz2]) * 100 ;# units in 0.01 miles
            _ymiles=(_centy[_taz]-_centy[_taz2]) * 100 ;# units in 0.01 miles
            _dist=sqrt(_xmiles^2 + _ymiles^2)
          ;# save info if closer than previous nodes
            if (_dist <= {Radius})
              _flthh[_taz]  = _flthh[_taz]  + _hh[_taz2]
              _fltemp[_taz] = _fltemp[_taz] + _totemp[_taz2]
              _fltacres[_taz] = _fltacres[_taz] + _acres[_taz2]
              _fltcnt[_taz] = _fltcnt[_taz] + 1
              ;# print form=8.2, list=_taz,_taz2,_hh[_taz2],_flthh[_taz], printo=3
            endif
          endif
        endloop
        
        ;# calculate  areatype index
        if (_fltacres[_taz] = 0)  ;# dont calculate for placeholder Zones with no acres
          _areaindex[_taz] = 0
        else
          _areaindex[_taz] = (_flthh[_taz] + _fltemp[_taz]) / _fltacres[_taz]
        endif
        
        ATYPE[_taz] = _AT(1, _areaindex[_taz])
         
        ;# printout for debug
        ;# print form=8.0, list=_taz, _flthh[_taz], _fltemp[_taz], _acres[_taz], _areaindex[_taz], ATYPE[_taz], printo=3
      endloop
    endif

  endphase

  phase = summary

    loop _k=1,_cnt
      IF(_K<={Total zones})
        AType[_K]=_AT(1,_areaindex[_K])
        ;# WRITE RECO=1
        PRINT form=4.0 LIST=_centn[_k], ATYPE[_K], PRINTO=1
        print form=10.2 list=_centn[_k], _areaindex[_k], ATYPE[_K], printo=2
      ENDIF
    endloop

  endphase
  

ENDRUN
