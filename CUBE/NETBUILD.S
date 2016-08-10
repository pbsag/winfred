; Script for program NETWORK in file "C:\projects\roanoke\CUBE\Extract_Scenario_Network.S"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\Extract_Network.PRN" MSG='Extract Scenario Network'
FILEI LINKI[1] = "{CATALOG_DIR}\MasterNetwork\Master_highway.net"
FILEO NETO = "{SCENARIO_DIR}\Input\highway.net",
INCLUDE = A, B, LENGTH, DISTANCE, FACTYPE, LANES, POST_SPD, RTE_NAME, AAWDT, TMS_ID, SCREENLN, TUNNEL, BRIDGE, TRK_PHB, PED_PHB, TRAFF_PHB

PROCESS  PHASE=LINKMERGE  
; Add common links
IF(DIST_C > 0)
  DISTANCE = DIST_C
  FACTYPE = FT_C
  LANES = LANES_C
  POST_SPD = SPD_C
ENDIF


; Add new or year/scenario specific links
IF(F{year}_EXCL = 1)
  DISTANCE = DIST_{year}
  FACTYPE = FT_{year}
  LANES = LANES_{year}
  POST_SPD = SPD_{year}
ENDIF

IF (DISTANCE =0) DELETE

ENDPROCESS

ENDRUN


; Script for program NETWORK in file "C:\projects\roanoke\Cube\AT_1.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_1.PRN" MSG='OUTPUT LINK AND ZONE DATA'
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\highway.net"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\XY.dat"
FILEO NODEO = "{SCENARIO_DIR}\Output\NODE.DAT"
FILEO LINKO = "{SCENARIO_DIR}\Output\LINK.DAT"

ARRAY _CNT={Total zones},_CENTX={Total zones},_CENTY={Total zones},_CENT={Total zones},
      _NO=99999,_MIDX=99999,_MIDY=99999,_MID_POINT=99999,_NO=99999,XMILES=999999,
      YMILES=999999,DIST=99999

PHASE=NODEMERGE


IF(n<={Total zones})

PRINT LIST=N,X(20.5),Y(20.5), PRINTO=1
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

;calculate the link distance in straight-line coordinates

dist_xy =(sqrt((a.x-b.x)^2+(a.y-b.y)^2)) / 5280  ; convert feet to miles

;# determine the average directionality of the link.
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X<B.X) ROADDIR='EB' ;east bound
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X>B.X) ROADDIR='WB' ; west bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y<B.Y) ROADDIR='NB' ; north bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y>B.Y) ROADDIR='SB' ; south bound

ENDPHASE

ENDRUN


; Script for program MATRIX in file "C:\projects\roanoke\Cube\AT_2.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_2.PRN" MSG='FIND THE CLOSEST ZONE TO EACH LINK'
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\XY.dat",
 z = #1, x = #2, y = #3
FILEO RECO[1] = "{SCENARIO_DIR}\Output\CLOSEST.DBF",
FIELDS=A,B,ZN,DIST_XY
FILEI RECI = "{SCENARIO_DIR}\Output\LINK.DAT"

ZONES={Total ZONES}

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
      if (zi.1.x[iz] <> 0)
        d = sqrt((zi.1.x[iz] - xmid)^2 + (zi.1.y[iz] - ymid)^2)
          
        if (d < dmin)
          dmin = d
          zn   = iz
          dist_xy = ri.dist_xy
        endif
      endif
    endloop

  endif

 A=RI.A
 B=RI.B
 WRITE RECO=1
 ; print list = ri.a,ri.b,zn, PRINTO=1


ENDRUN


; Script for program NETWORK in file "C:\projects\roanoke\Cube\AT_3.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_3.PRN" MSG='INSERT LINK DATA TO NETWORK'
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\highway.net"
FILEI LINKI[2] = "{SCENARIO_DIR}\Output\CLOSEST.DBF"
FILEO NETO = "{SCENARIO_DIR}\Output\ZONE.NET"

MERGE RECORD=TRUE, LAST=ZN
PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.

   ;# The distance for centroid connectors is the straight-line distance rather 
   ;# than the distance on the file.
   IF(FACTYPE >= 11)   ;# cc are 11 and 12
     DISTANCE = DIST_XY
   ENDIF

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program NETWORK in file "C:\projects\roanoke\Cube\AT_4.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_4.PRN" MSG='ADD LAND USE DATA TO ZONES'
FILEI NODEI[2] = "{SCENARIO_DIR}\Input\se.dbf"
FILEO NETO = "{SCENARIO_DIR}\Output\merge zone.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\ZONE.NET"

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
; already done earlier

ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program NETWORK in file "C:\projects\roanoke\Cube\AT_5.s"
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


; Script for program NETWORK in file "C:\projects\roanoke\Cube\AT_6.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_6.PRN" MSG='INSERT LINK AREA TYPE ON THE NETWORK'
FILEO LINKO = "{SCENARIO_DIR}\Output\link_atype{Year}{Alternative}.DBF",
 FORMAT = DBF, 
  INCLUDE = A, B, DISTANCE, FACTYPE, LANES, POST_SPD, ATYPE
FILEO NETO = "{SCENARIO_DIR}\Output\ATYPE NETWORK{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\Output\AREA TYPE.PRN"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\PROCESSED.NET"


PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE
; Use this phase to make computations and selections of any data on the LINKI files.
LOOKUP NAME=ATYPE1,
 LOOKUP[1]=1, RESULT=2,
 INTERPOLATE=N, LOOKUPI=1

ATYPE=ATYPE1(1,LI.1.ZN)


ENDPROCESS


PROCESS  PHASE=SUMMARY
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


; Script for program MATRIX in file "C:\projects\roanoke\Cube\AT_7.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_7.PRN" MSG='OUTPUT AREA TYPE AS DBF FOR LATER USE'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\ZONAL AT{Year}{Alternative}.DBF",
 fields=N,ATYPE
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\AREA TYPE.PRN",
 z=#1,at=2

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

zones={Total zones}
N = Z
ATYPE=zi.1.at

;consolodate area types into 3 categories because trip adjustment rates are based on 3 area types
if(ATYPE>0)write reco=1

ENDRUN


; PILOT Script
;FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\LINK_CAPACITY.PRN"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

; **NOTE THAT PILOT PROGRAMS TAKE NO INPUTS OR OUTPUTS IN THE APPLICATION MANAGER**
; set location of R executable
Rexe = '{CATALOG_DIR}\R\R-3.2.2\bin\Rscript.exe'

; set location of R script that runs the classification step
Rscript = '{CATALOG_DIR}\R\calculate_capacities.R'

; Collect arguments for R script.
link_file = '{SCENARIO_DIR}\Output\link_atype{Year}{Alternative}.DBF'
output_file = '{SCENARIO_DIR}\Output\link_capacities{Year}{Alternative}.DBF'

; Write batch file to run R model
PRINT LIST= Rexe ' ' Rscript ' ' link_file ' ' output_file, 
 FILE = "{CATALOG_DIR}\CUBE\LINK_CALC.BAT"
  
; Duplicate command in print file
;PRINT LIST= Rexe ' ' Rscript ' ' input_se_file ' ' output_file, 
; PRINTO = 1

; Run batch file from command line
*{CATALOG_DIR}\CUBE\LINK_CALC.BAT

; End of PILOT Script

; Script for program NETWORK in file "C:\projects\roanoke\Cube\FreeFlowSpeeds.s"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Attach capacity and FFS to network'
FILEO NETO = "{SCENARIO_DIR}\Output\RVTPOBase{Year}{Alternative}.NET"
FILEI LINKI[2] = "{SCENARIO_DIR}\Output\link_capacities{Year}{Alternative}.DBF"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\ATYPE NETWORK{Year}{Alternative}.NET"

PROCESS  PHASE=INPUT
;Use this phase to modify data as it is read, such as recoding node numbers.


ENDPROCESS


PROCESS  PHASE=NODEMERGE  
; Use this phase to make computations and selections of any data on the NODEI files.


ENDPROCESS


PROCESS  PHASE=LINKMERGE  
; Use this phase to make computations and selections of any data on the LINKI files.
CAPE_AM = LI.2.CAPE * 2.79 ; 2.5  ; AM Capacity
CAPE_MD = LI.2.CAPE * 4.40 ; 5.5  ; MD Capacity
CAPE_PM = LI.2.CAPE * 3.18 ; 2.5  ; PM Capacity
CAPE_NT = LI.2.CAPE * 5.63 ; 4.5  ; NT Capacity
POST_SPEED = LI.1.POST_SPD  

/*
Recode FFS based on +/- 5 MPH rule (ignore HCM-R FFS)
1	Interstate/Principal Freeway
2	Minor Freeway
3	Principal Arterial
4	Major Arterial
5	Minor Arterial
6	Major Collector
7	Minor Collector
8	Local
9	High-speed Ramp
10	Low-speed Ramp
11	Centroid Connector
12	External Station Connector

Higher level highways	Where Facility Type = "Freeway" or ((Facility Type = "Multi-lane Highway" or Facility Type = "Two-lane Highway") and Divided = "Divided")	Initial Travel Time = Length/(Posted Speed + 5.0)*60

Lower level highways and arterials	((Where Facility Type = "Multi-lane Highway" or Facility Type = "Two-lane Highway") and Divided = "Undivided" or Divided = “CLTL”) or Facility Type contains "Urban Arterial"	Initial Travel Time = Length/(Posted Speed - 5.0)*60

Local Roads, collectors, ramps and other links	Where Facility Type= "Centroid Connector" or Facility Type=  "Collector" or Facility Type= "Diamond Ramp"  or Facility Type= "Loop Ramp"  or Facility Type= "Local Road"   or Facility Type=  "Freeway to Freeway Ramp"	Initial Travel Time = Length/Posted Speed*60

*/

; Arterials
IF(LI.1.FACTYPE > 2 & LI.1.FACTYPE < 5 & LI.1.POST_SPD > 25 ) 
     FFSPEED = LI.1.POST_SPD - 5
ENDIF

; Local and collector
IF(LI.1.FACTYPE > 6 & LI.1.FACTYPE < 9 & LI.1.POST_SPD <> 0) 
     FFSPEED = LI.1.POST_SPD + 3
ENDIF



ENDPROCESS


PROCESS  PHASE=SUMMARY   
; Use this phase for combining and reporting of working variables.


ENDPROCESS

ENDRUN


