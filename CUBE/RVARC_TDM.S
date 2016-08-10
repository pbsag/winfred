; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*del {CATALOG_DIR}\CUBE\*.prn
*del {CATALOG_DIR}\CUBE\*.bak
*del {CATALOG_DIR}\CUBE\*.0??
*del {CATALOG_DIR}\CUBE\trc*.s
*IF NOT EXIST "{SCENARIO_DIR}\Output" MKDIR "{SCENARIO_DIR}\Output"
*IF NOT EXIST "{SCENARIO_DIR}\OUTPUT" MKDIR "{SCENARIO_DIR}\OUTPUT"
*IF NOT EXIST "{SCENARIO_DIR}\OUTPUT\LOGS" MKDIR "{SCENARIO_DIR}\OUTPUT\LOGS"

FILEO PRINTO[1] = "{SCENARIO_DIR}\scenario.properties"
 ; Write out catalog keys as scenario.properties
 print list = 'About the scenario'    printo = 1 
 print list = '-----------------------------------'             printo = 1 
 print list = 'SCENARIO_FULLNAME  = ', '{SCENARIO_FULLNAME}'    printo = 1
 print list = 'SCENARIO_SHORTNAME = ', '{SCENARIO_SHORTNAME}'   printo = 1
 print list = 'SCENARIO_CODE      = ', '{SCENARIO_CODE}'        printo = 1
 print list = 'SCENARIO_DIR       = ', '{SCENARIO_DIR}'         printo = 1
 print list = 'CATALOG_DIR        = ', '{CATALOG_DIR}'          printo = 1
 print list = 'Alternative        = ', '{Alternative}'          printo = 1
 print list = 'Description        = ', '{Description}'          printo = 1
 print list = 'Year               = ', '{Year}'                 printo = 1

 print list = '\n \nModel settings'    printo = 1 
 print list = '-----------------------------------'             printo = 1  
 print list = 'Total-Zones        = ', '{Total-Zones}'          printo = 1
 print list = 'ZONESA             = ', '{ZONESA}'               printo = 1 
 print list = 'Internal-Zones     = ', '{Internal-Zones}'       printo = 1
 print list = 'MAXWLKACCLNKS      = ', '{MAXWLKACCLNKS}'        printo = 1
 print list = 'NODEMIN            = ', '{NODEMIN}'              printo = 1
 print list = 'Radius             = ', '{Radius}'               printo = 1
 print list = 'AVGWLKSPD          = ', '{AVGWLKSPD}'            printo = 1
 print list = 'UNIT               = ', '{UNIT}'                 printo = 1
 print list = 'WALKACC            = ', '{WALKACC}'              printo = 1
 
 print list = '\n \nDebug and select link settings'             printo = 1   
 print list = '-----------------------------------'             printo = 1 
 print list = 'DebugDC            = ', '{DebugDC}'              printo = 1 
 print list = 'FromNode           = ', '{FromNode}'             printo = 1
 print list = 'ToNode             = ', '{ToNode}'               printo = 1
 print list = 'SelOrigin          = ', '{SelOrigin}'            printo = 1
 print list = 'SelDest            = ', '{SelDest}'              printo = 1
 print list = 'SelectLink         = ', '{SelectLink}'           printo = 1

 
 
; End of PILOT Script

; Script for program NETWORK in file "C:\projects\rvtpo\Cube\AT_1.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_1.PRN" MSG='OUTPUT LINK AND ZONE DATA'
FILEI LINKI[1] = "{SCENARIO_DIR}\Input\highway.net"
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


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\AT_2.s"
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


; Script for program NETWORK in file "C:\projects\rvtpo\Cube\AT_3.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_3.PRN" MSG='INSERT LINK DATA TO NETWORK'
FILEI LINKI[1] = "{SCENARIO_DIR}\Input\highway.net"
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


; Script for program NETWORK in file "C:\projects\rvtpo\Cube\AT_4.s"
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


; Script for program NETWORK in file "C:\projects\rvtpo\Cube\AT_5.s"
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


; Script for program NETWORK in file "C:\projects\rvtpo\Cube\AT_6.s"
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


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\AT_7.s"
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

; Script for program NETWORK in file "C:\projects\rvtpo\Cube\FreeFlowSpeeds.s"
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

/* 
Capacities are computed using HCMR package where highway capacity manual formulas are computed for each link and are appended to the network as CAPE. However VDOT insists to have override capability to use a different capacity for a given link. The VDOT link capacity is coded "VDOT_CAP" attribute. If the attribute “VDOT_CAP” carries a non-zero value then it is used in place of hcmr computed capacity

Here three capacities are stored:
HCMR_CAP = original hwy capacity based on HCMR
VDOT_CAP = VDOT capacity to replace HCMR_CAP
CAPE = capacity per hour (from above two).

*/
; Save HCMR capacity as HCMR_CAP
HCMR_CAP = LI.2.CAPE


; Override hcmr capacity with VDOT link specific capacity
IF (LI.1.VDOT_CAP > 0)
    CAPE = LI.1.VDOT_CAP
ENDIF


; Use this phase to make computations and selections of any data on the LINKI files.
CAPE_AM = CAPE * 2.79 ; 2.5  ; AM Capacity
CAPE_MD = CAPE * 4.40 ; 5.5  ; MD Capacity
CAPE_PM = CAPE * 3.18 ; 2.5  ; PM Capacity
CAPE_NT = CAPE * 5.63 ; 4.5  ; NT Capacity
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


; Script for program HIGHWAY in file "C:\projects\rvtpo\Cube\HwySkims_FreeFlow.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\Output\Logs\FreeFlowSpeeds.PRN" MSG='Build Initial Skims'
FILEI TURNPENI = "{SCENARIO_DIR}\Input\TurnPenalties.pen"
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\ZONAL AT{Year}{Alternative}.DBF",
Z = N
FILEI NETI = "{SCENARIO_DIR}\Output\RVTPOBase{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\Term_Time.dbf"

FILEO MATO[1] = "{SCENARIO_DIR}\Output\IMPED11.MAT",
      MO=1-5, NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME,
      DEC=2,2,0,0,2

;# lookup table for terminal times based on area type
LOOKUP LOOKUPI=1, NAME=Term_Time,
         LOOKUP[1]=ATYPE, RESULT=OTIME,
         LOOKUP[2]=ATYPE, RESULT=DTIME,
       FAIL[3]=0
; example of use: v=Term_Time(2,25)
; look for 25 in the ATYPE field and returns the DTIME value


PARAMETERS  ZONES={Total Zones}



PROCESS PHASE=LINKREAD

  ; use FF_SPEED as speed for initial skim
  SPEED = LI.FFSPEED

ENDPROCESS

PROCESS PHASE=ILOOP

  ;# skim network for time and distance
  PATH=COST,MW[1]=PATHTRACE(TIME,1),MW[2]=PATHTRACE(LI.DISTANCE)
  MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time is half of the time to the nearest zone.
  MW[2][I] = 0                ; Set Intrazonal Dist = 0

  IF(i < {Internal Zones})  ;# terminal times only exist for internal Zones
    JLOOP
      MW[3] = Term_Time(1, zi.1.ATYPE[i])       ;origin terminal time
      MW[4] = Term_Time(2, zi.1.ATYPE[j])       ;destination terminal time
    ENDJLOOP
  ELSE ;# external stations
    MW[3] = 0
    MW[4] = 0
  ENDIF

  ;# Total Impedance including terminal times
  MW[5] = MW[1]+MW[3]+MW[4]

ENDPROCESS

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*COPY {SCENARIO_DIR}\Output\IMPED11.MAT {SCENARIO_DIR}\OUTPUT\PK_FreeFlow_Skim.MAT
*COPY {SCENARIO_DIR}\Output\IMPED11.MAT {SCENARIO_DIR}\OUTPUT\OP_FreeFlow_Skim.MAT
; End of PILOT Script

; PILOT Script
;FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\CLASSIFICATION.PRN"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

; **NOTE THAT PILOT PROGRAMS TAKE NO INPUTS OR OUTPUTS IN THE APPLICATION MANAGER**
; set location of R executable
Rexe = '{CATALOG_DIR}\R\R-3.2.2\bin\Rscript.exe'

; set location of R script that runs the classification step
Rscript = '{CATALOG_DIR}\R\classification.R'

; Collect script arguments for R script.
input_se_file = '{SCENARIO_DIR}\Input\se.dbf'
lookup_dir = '{CATALOG_DIR}\Params\classification'
output_file = '{SCENARIO_DIR}\Output\se_classified_{year}{alternative}.dbf'

; Write batch file to run R model
PRINT LIST= Rexe ' ' Rscript ' ' input_se_file ' ' lookup_dir ' ' output_file, 
 FILE = "{CATALOG_DIR}\CUBE\CLASSIFICATION.BAT"
  
; Duplicate command in print file
;PRINT LIST= Rexe ' ' Rscript ' ' input_se_file ' ' lookup_dir ' ' output_file, 
 ; PRINTO = 1

; Run batch file from command line
*{CATALOG_DIR}\CUBE\CLASSIFICATION.BAT
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


; End of PILOT Script

; Script for program GENERATION in file "C:\projects\rvtpo\Cube\TripProduction.S"
;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION MSG='Household Trip Production'
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\hbw.csv"
FILEI LOOKUPI[6] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\NHBO.DBF"
FILEI LOOKUPI[5] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBSHOP.DBF"
FILEI LOOKUPI[4] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBSCHOOL.DBF"
FILEI LOOKUPI[3] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBO.DBF"
FILEI LOOKUPI[2] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\NHBW.DBF"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBW.DBF"
FILEO PAO[1] = "{SCENARIO_DIR}\OUTPUT\HH_PROD.DBF",
  FORM=10.3, LIST = Z, P[1], P[2], P[3], P[4], P[5], P[6], DBF=T, 
  NAMES = TAZ, HBWP, NHBWP, HBOP, HBSCP, HBSHP, NHBOP
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\se_classified_{year}{Alternative}.dbf"

ZONES = {Total Zones}

LOOKUP LOOKUPI=1, NAME=hbw_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
LOOKUP LOOKUPI=2, NAME=nhbw_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0

LOOKUP LOOKUPI=3, NAME=hbo_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
LOOKUP LOOKUPI=4, NAME=hbschool_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
LOOKUP LOOKUPI=5, NAME=hbshop_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0

LOOKUP LOOKUPI=6, NAME=nhbo_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
  
PROCESS PHASE=ILOOP
; This phase performs a zonal loop (I=1,Zones).  This phase is used to compute productions (P[#]=) and
; attractions (A[#]=) by zone.  Up to 20 P's and 20 A's can be computed in a single run.
  /*#
    #Work trip purposes use cross-classification tables of workers vehicles.
    #Other trip purposes use cross-classification tables of size and vehicles.
    #The input zone data contains the number of households in each zone for each
    #class. The production model works by taking this number of housheolds
    #and multiplying it by the average rate in the lookup tables.
  */

  ;# Home-based work productions
  P[1] = 0 +
    zi.1.w0v0 * hbw_lu(1, 1) + zi.1.w0v1 * hbw_lu(2, 1) + zi.1.w0v2 * hbw_lu(3, 1) + zi.1.w0v3 * hbw_lu(4, 1) +
    zi.1.w1v0 * hbw_lu(1, 2) + zi.1.w1v1 * hbw_lu(2, 2) + zi.1.w1v2 * hbw_lu(3, 2) + zi.1.w1v3 * hbw_lu(4, 2) +
    zi.1.w2v0 * hbw_lu(1, 3) + zi.1.w2v1 * hbw_lu(2, 3) + zi.1.w2v2 * hbw_lu(3, 3) + zi.1.w2v3 * hbw_lu(4, 3) +
    zi.1.w3v0 * hbw_lu(1, 4) + zi.1.w3v1 * hbw_lu(2, 4) + zi.1.w3v2 * hbw_lu(3, 4) + zi.1.w3v3 * hbw_lu(4, 4)
    
  ;# Non home-based work productions
  P[2] = 0 +
    zi.1.w0v0 * nhbw_lu(1, 1) + zi.1.w0v1 * nhbw_lu(2, 1) + zi.1.w0v2 * nhbw_lu(3, 1) + zi.1.w0v3 * nhbw_lu(4, 1) +
    zi.1.w1v0 * nhbw_lu(1, 2) + zi.1.w1v1 * nhbw_lu(2, 2) + zi.1.w1v2 * nhbw_lu(3, 2) + zi.1.w1v3 * nhbw_lu(4, 2) +
    zi.1.w2v0 * nhbw_lu(1, 3) + zi.1.w2v1 * nhbw_lu(2, 3) + zi.1.w2v2 * nhbw_lu(3, 3) + zi.1.w2v3 * nhbw_lu(4, 3) +
    zi.1.w3v0 * nhbw_lu(1, 4) + zi.1.w3v1 * nhbw_lu(2, 4) + zi.1.w3v2 * nhbw_lu(3, 4) + zi.1.w3v3 * nhbw_lu(4, 4)

  ;# Home-based other productions
  P[3] =
    zi.1.p1v0 * hbo_lu(1, 1) + zi.1.p1v1 * hbo_lu(2, 1) + zi.1.p1v2 * hbo_lu(3, 1) + zi.1.p1v3 * hbo_lu(4, 1) +
    zi.1.p2v0 * hbo_lu(1, 2) + zi.1.p2v1 * hbo_lu(2, 2) + zi.1.p2v2 * hbo_lu(3, 2) + zi.1.p2v3 * hbo_lu(4, 2) +
    zi.1.p3v0 * hbo_lu(1, 3) + zi.1.p3v1 * hbo_lu(2, 3) + zi.1.p3v2 * hbo_lu(3, 3) + zi.1.p3v3 * hbo_lu(4, 3) +
    zi.1.p4v0 * hbo_lu(1, 4) + zi.1.p4v1 * hbo_lu(2, 4) + zi.1.p4v2 * hbo_lu(3, 4) + zi.1.p4v3 * hbo_lu(4, 4)
    
 
  ;# Home-based school productions
  P[4] = 0 +
    zi.1.p1v0 * hbschool_lu(1, 1) + zi.1.p1v1 * hbschool_lu(2, 1) + zi.1.p1v2 * hbschool_lu(3, 1) + zi.1.p1v3 * hbschool_lu(4, 1) +
    zi.1.p2v0 * hbschool_lu(1, 2) + zi.1.p2v1 * hbschool_lu(2, 2) + zi.1.p2v2 * hbschool_lu(3, 2) + zi.1.p2v3 * hbschool_lu(4, 2) +
    zi.1.p3v0 * hbschool_lu(1, 3) + zi.1.p3v1 * hbschool_lu(2, 3) + zi.1.p3v2 * hbschool_lu(3, 3) + zi.1.p3v3 * hbschool_lu(4, 3) +
    zi.1.p4v0 * hbschool_lu(1, 4) + zi.1.p4v1 * hbschool_lu(2, 4) + zi.1.p4v2 * hbschool_lu(3, 4) + zi.1.p4v3 * hbschool_lu(4, 4)
    
  
  ;# Home-based shop productions
  P[5] = 0 +
    zi.1.p1v0 * hbshop_lu(1, 1) + zi.1.p1v1 * hbshop_lu(2, 1) + zi.1.p1v2 * hbshop_lu(3, 1) + zi.1.p1v3 * hbshop_lu(4, 1) +
    zi.1.p2v0 * hbshop_lu(1, 2) + zi.1.p2v1 * hbshop_lu(2, 2) + zi.1.p2v2 * hbshop_lu(3, 2) + zi.1.p2v3 * hbshop_lu(4, 2) +
    zi.1.p3v0 * hbshop_lu(1, 3) + zi.1.p3v1 * hbshop_lu(2, 3) + zi.1.p3v2 * hbshop_lu(3, 3) + zi.1.p3v3 * hbshop_lu(4, 3) +
    zi.1.p4v0 * hbshop_lu(1, 4) + zi.1.p4v1 * hbshop_lu(2, 4) + zi.1.p4v2 * hbshop_lu(3, 4) + zi.1.p4v3 * hbshop_lu(4, 4)
    
  ;# non-Home-based other productions
  P[6] = 0 +
    zi.1.p1v0 * nhbo_lu(1, 1) + zi.1.p1v1 * nhbo_lu(2, 1) + zi.1.p1v2 * nhbo_lu(3, 1) + zi.1.p1v3 * nhbo_lu(4, 1) +
    zi.1.p2v0 * nhbo_lu(1, 2) + zi.1.p2v1 * nhbo_lu(2, 2) + zi.1.p2v2 * nhbo_lu(3, 2) + zi.1.p2v3 * nhbo_lu(4, 2) +
    zi.1.p3v0 * nhbo_lu(1, 3) + zi.1.p3v1 * nhbo_lu(2, 3) + zi.1.p3v2 * nhbo_lu(3, 3) + zi.1.p3v3 * nhbo_lu(4, 3) +
    zi.1.p4v0 * nhbo_lu(1, 4) + zi.1.p4v1 * nhbo_lu(2, 4) + zi.1.p4v2 * nhbo_lu(3, 4) + zi.1.p4v3 * nhbo_lu(4, 4)
    
  p1v0 = zi.1.p1v0 * nhbo_lu(1, 1)
  p1v1 = zi.1.p1v1 * nhbo_lu(2, 1)
  p1v2 = zi.1.p1v2 * nhbo_lu(3, 1)
  p1v3 = zi.1.p1v3 * nhbo_lu(4, 1)
  p2v0 = zi.1.p2v0 * nhbo_lu(1, 2)
  p2v1 = zi.1.p2v1 * nhbo_lu(2, 2)
  p2v2 = zi.1.p2v2 * nhbo_lu(3, 2)
  p2v3 = zi.1.p2v3 * nhbo_lu(4, 2)
  p3v0 = zi.1.p3v0 * nhbo_lu(1, 3)
  p3v1 = zi.1.p3v1 * nhbo_lu(2, 3)
  p3v2 = zi.1.p3v2 * nhbo_lu(3, 3)
  p3v3 = zi.1.p3v3 * nhbo_lu(4, 3)
  p4v0 = zi.1.p4v0 * nhbo_lu(1, 4)
  p4v1 = zi.1.p4v1 * nhbo_lu(2, 4)
  p4v2 = zi.1.p4v2 * nhbo_lu(3, 4)
  p4v3 = zi.1.p4v3 * nhbo_lu(4, 4)
  all =
    p1v0 + p1v1 + p1v2 + p1v3 +
    p2v0 + p2v1 + p2v2 + p2v3 +
    p3v0 + p3v1 + p3v2 + p3v3 +
    p4v0 + p4v1 + p4v2 + p4v3
  

PRINT FORM = 10.10, CSV = T, LIST = Z, P[6], p1v0, p1v1, p1v2, p1v3, p2v0,
  p2v1, p2v2, p2v3, p3v0, p3v1, p3v2, p3v3, p4v0, p4v1, p4v2, p4v3, all,
  PRINTO = 1
    
    
ENDPROCESS


PROCESS PHASE=ADJUST
  /*
  # Implementation of a discrete choice model obviates the need to forecast
  # attractions, and therefore the need to balance
  */

  
ENDPROCESS

ENDRUN


; Script for program NETWORK in file "C:\projects\rvtpo\Cube\TransitSpeeds.S"

; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\TransitSpeeds.PRN" MSG='Transit Speeds'
FILEO NETO = "{SCENARIO_DIR}\Output\HWYTSPD.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\RVTPOBase{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\transit\TRANSPD.dbf"


PROCESS PHASE=LINKMERGE

  ;If auto travel time is not present or is zero, a default value of 15 mph is used.
  IF (FFSPEED>0)
    _AUTOSPEED=FFSPEED
  ELSE
    _AUTOSPEED=15
  ENDIF

   ; COMPUTE FREE FLOW TIME ON NETWORK
  FF_TIME=ROUND(100*(DISTANCE)/FFSPEED*60)/100

  ; COMPUTE WALKTIME ON NETWORK
  WALKTIME=ROUND(100*(DISTANCE)/{AVGWLKSPD}*60)/100


  ;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

;************************************************************************************************
;* DEFAULT TRANSIT SPEEDS SET EQUAL TO AUTO SPEEDS. APPLY APPROPRIATE TRANSIT SPEED CURVES HERE.*
;************************************************************************************************

lookup name=curve,
     lookup[1]=CURVE_NO, result=LOW_MODE,
     lookup[2]=CURVE_NO, result=HIGH_MODE,
     lookup[3]=CURVE_NO, result=LOW_FT,
     lookup[4]=CURVE_NO, result=HIGH_FT,
     lookup[5]=CURVE_NO, result=LOW_AT,
     lookup[6]=CURVE_NO, result=HIGH_AT,
     lookup[7]=CURVE_NO, result=SPEEDRATIO,
     interpolate=n,fail=0,0,0,list=y,lookupi=1
array lm=500,hm=500,lf=500,hf=500,la=500,ha=500,sr=500

loop _nn=1,500
   LM[_nn]=CURVE(1,_nn)
   HM[_nn]=CURVE(2,_nn)
   LF[_nn]=CURVE(3,_nn)
   HF[_nn]=CURVE(4,_nn)
   LA[_nn]=CURVE(5,_nn)
   HA[_nn]=CURVE(6,_nn)
   SR[_nn]=CURVE(7,_nn)
if (lm[_nn]>0) _numberofcurves=_nn ; obtain the total number of curves fromt he curve file
if (lm[_nn]<=0) break
endloop

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

  LOOP _nn=1,_numberofcurves
    if ((FACTYPE >= LF[_nn]) & (FACTYPE <= HF[_nn]) & (ATYPE >= LA[_nn]) & (ATYPE <= HA[_nn]))
    if ((LM[_nn] >= 21) & (HM[_nn] <= 21)) spdratioM21 = SR[_nn]
    if ((LM[_nn] >= 22) & (HM[_nn] <= 22)) spdratioM22 = SR[_nn]
    if ((LM[_nn] >= 26) & (HM[_nn] <= 26)) spdratioM26 = SR[_nn]  
    
    endif
  ENDLOOP
     ; APPLY DEFAULT CURVES
     IF (_AUTOSPEED>0)
       _TSPD21=spdratioM21*_AUTOSPEED  ; Bus Speeds
       _TSPD22=spdratioM22*_AUTOSPEED  ; Circulator Speeds (assumed same as buses)
       _TSPD26=spdratioM26*_AUTOSPEED  ; Project mode
       
       M21TIMEPK=60*(DISTANCE)/_TSPD21
       M22TIMEPK=60*(DISTANCE)/_TSPD22
       M26TIMEPK=60*(DISTANCE)/_TSPD26
       
 
 
     ENDIF
    
      ; WALK CONTROLS
      WALKTIME=60*DISTANCE/{AVGWLKSPD}
 IF (FACTYPE=1-2,9-10)
      WALKTIME=999.99
 ENDIF
 

 IF((A={FromNode}) && (B={ToNode}))

      list="\n\n"
      list="     An     Bn   Dist   ASpd   TSpd   Ttim    Crv"
      list=A(7.0),B(7.0),DISTANCE(7.2),_AUTOSPEED(7.2),_TSPD21(7.2),M21TIMEPK(7.2),_CURVEMODE21(7.0)," MODE21"
      list=A(7.0),B(7.0),DISTANCE(7.2),_AUTOSPEED(7.2),_TSPD22(7.2),M22TIMEPK(7.2),_CURVEMODE22(7.0)," MODE22"
      list=A(7.0),B(7.0),DISTANCE(7.2),_AUTOSPEED(7.2),_TSPD26(7.2),M26TIMEPK(7.2),_CURVEMODE26(7.0)," MODE26"
      list="\n\n"
 ENDIF

 ENDPROCESS

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\projects\rvtpo\Cube\Build_WalkAccess_Connectors.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\BuildWalkAccessConenctors.PRN" MSG='Build Walk Access Connectors'
FILEO REPORTO = "{SCENARIO_DIR}\Output\LOGS\TNPTR00B.PRN"
FILEO NTLEGO = "{SCENARIO_DIR}\Output\NTLEG.TEM"
FILEO NETO = "{SCENARIO_DIR}\Output\NTLEG.NET"
FILEI FACTORI[1] = "{CATALOG_DIR}\Params\transit\WalkPrem.FAC"
FILEI FAREI = "{CATALOG_DIR}\Params\transit\TFARES.FAR"
FILEI SYSTEMI = "{CATALOG_DIR}\Params\transit\TSYSD.PTS"
FILEI LINEI[1] = "{SCENARIO_DIR}\Input\TROUTE.LIN"
FILEI NETI = "{SCENARIO_DIR}\Output\HWYTSPD.NET"

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

; OVERALL PARAMETERS OF RUN
PARAMETERS USERCLASSES=1,FARE=N, MAPSCALE={UNIT.n,RadioBtn-CHARACTER,"","0.01 Miles", ,"0.1 Miles","0.01 Miles"}, HDWAYPERIOD=1,
           NOROUTEERRS=999999, NOROUTEMSGS=999999,
           TRANTIME=LW.TRANTIME,
           TRANTIME[21]=LI.M21TIMEPK,
           TRANTIME[22]=LI.M22TIMEPK,
           TRANTIME[26]=LI.M26TIMEPK

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

REPORT LINES=T
PROCESS PHASE=LINKREAD
           LW.TRANTIME=LI.M21TIMEPK
           LW.WALKTIME=LI.WALKTIME
           LW.WALKDISTANCE=LI.DISTANCE
           LW.DISTANCE=LI.DISTANCE
ENDPROCESS

PROCESS PHASE=DATAPREP

  ; 1 - Generate Walk Access Connectors
 
 GENERATE, COST=(LW.WALKDISTANCE),EXTRACTCOST=(LW.WALKTIME),MAXCOST=200*{WALKACC,EditBox-REAL,"Average Walk Distance (miles)","0.6"},LIST=T,EXCLUDELINK=(LI.FACTYPE=1-2,9-10),
            NTLEGMODE=1,MAXNTLEGS=200*{MAXWLKACCLNKS},DIRECTION=3,ONEWAY=F,FROMNODE=1-{ZONESA,EditBox-INTEGER,"Total number of zones including externals","266"},TONODE={NODEMIN,EditBox-INTEGER,"First non-zone node number","1000"}-99999

 ; 4 - Generate All-Walk Connectors
  GENERATE, COST=(LW.WALKDISTANCE),EXTRACTCOST=(LW.WALKTIME),MAXCOST=200*7,LIST=T,EXCLUDELINK=(LI.FACTYPE=1-2,9-10),
            NTLEGMODE=4,MAXNTLEGS=200*{MAXWLKACCLNKS},DIRECTION=3,ONEWAY=F,FROMNODE=1-{ZONESA},TONODE=1-{ZONESA}

ENDPROCESS


ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\WalkAccess_Connectors_by_Mode.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\WalkAccess_ByMode.PRN" MSG='Subdivide Connectors into Separate Files by Mode'
FILEO PRINTO[2] = "{SCENARIO_DIR}\Output\NTLEG4.NTL"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\NTLEG1_TEM.NTL"
FILEI RECI = "{SCENARIO_DIR}\Output\NTLEG.TEM"

s1=strpos('NT',reci)
s2=strpos('LEG',reci)
s3=strpos('MODE',reci)
s4=strpos('COST',reci)
s5=strpos('DIST',reci)
s6=strpos('ONEWAY',reci)
s7=strpos('XN',reci)

; get the origin and destination zone
s8=(s3-s2)
leg1=substr(reci,s2,s8)
s9=strpos('=',leg1)
s10=strpos('-',leg1)
s11=(s9+1)
s12=(s10-1)
s13=(s10+1)
zonei=val(substr(leg1,s11,s12))
zonej=val(substr(leg1,s13,strlen(leg1)))

; get the mode number
s14=(s4-s3)
mode1=substr(reci,s3,s14)
s15=strpos('=',mode1)
s16=(s15+1)
mode=val(substr(mode1,s16,strlen(mode1)))

; get the time on the connector (cost field in the NT leg file)
s17=(s5-s4)
time1=substr(reci,s4,s17)
s18=strpos('=',time1)
s19=(s18+1)
time=val(substr(time1,s19,strlen(time1)))

; get the distance
s20=(s6-s5)
dist1=substr(reci,s5,s20)
s21=strpos('=',dist1)
s22=(s21+1)
dist=val(substr(dist1,s22,strlen(dist1)))

; get the rest of the string
s23=substr(reci,s6,strlen(reci))

if (i==1 && _ctr==0)
  PRINT LIST=";;<<PT>>;;", PRINTO=1
  PRINT LIST=";;<<PT>>;;", PRINTO=1
  _ctr = _ctr + 1
endif
;modes - walk, pnr, knr, all-walk, platcform connectors, sidewalk
if (mode=1) PRINT LIST="NT LEG=",zonei(5.0),"-",zonej(5.0)," MODE=",mode(2.0)," COST=",time(6.2)," DIST=",dist(5.2)," ",s23,PRINTO=1
if (mode=4) PRINT LIST="NT LEG=",zonei(5.0),"-",zonej(5.0)," MODE=",mode(2.0)," COST=",time(6.2)," DIST=",dist(5.2)," ",s23,PRINTO=2

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\projects\rvtpo\Cube\Trn_Skims_PK.S"
;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\Trn_PK_Skims.PRN" MSG='PK-Walk Access Paths / Skims'
FILEI NTLEGI[1] = "{SCENARIO_DIR}\Output\NTLEG1_TEM.NTL"
FILEO MATO[2] = "{SCENARIO_DIR}\Output\PK_TSKIMPrem.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO MATO[1] = "{SCENARIO_DIR}\Output\PK_TSKIMBus.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO ROUTEO[2] = "{SCENARIO_DIR}\Output\PK_TPATHPrem.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO ROUTEO[1] = "{SCENARIO_DIR}\Output\PK_TPATHBus.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO REPORTO = "{SCENARIO_DIR}\Output\PK_TransitWalk.rpt"
FILEO NETO = "{SCENARIO_DIR}\Output\PK_TransitWalk.NET"
FILEI FACTORI[2] = "{CATALOG_DIR}\Params\transit\WalkPrem.FAC"
FILEI FACTORI[1] = "{CATALOG_DIR}\Params\transit\WalkBus.FAC"
FILEI FAREI = "{CATALOG_DIR}\Params\transit\TFARES.FAR"
FILEI SYSTEMI = "{CATALOG_DIR}\Params\transit\TSYSD.PTS"
FILEI LINEI[1] = "{SCENARIO_DIR}\Input\TROUTE.LIN"
FILEI NETI = "{SCENARIO_DIR}\Output\HWYTSPD.NET"

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

   ; OVERALL PARAMETERS
   PARAMETERS USERCLASSES=1-2,FARE=N, MAPSCALE={UNIT}, HDWAYPERIOD=1,
         NOROUTEERRS=999999, NOROUTEMSGS=999999,
         TRANTIME=LW.TRANTIME,
         TRANTIME[21]=LI.M21TIMEPK,
         TRANTIME[22]=LI.M22TIMEPK,
         TRANTIME[26]=LI.M26TIMEPK

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    
   PROCESS PHASE=LINKREAD
         LW.TRANTIME=LI.M21TIMEPK
         LW.WALKTIME=LI.WALKTIME
         LW.WALKDISTANCE=LI.DISTANCE
         LW.DISTANCE=LI.DISTANCE
   ENDPROCESS

   PROCESS PHASE=DATAPREP

         ;Generate walk-access links
         GENERATE READNTLEGI=1
    ENDPROCESS

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

    PROCESS PHASE=SKIMIJ
         MW[1]=TIMEA(0,1)                                                              ; Walk time
         MW[2]=TIMEA(0,21)                                                             ; All bus time
         MW[3]=TIMEA(0,22)                                                              ; Trolley time
         MW[4]=TIMEA(0,26)                                                             ; Project mode time

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    IF(BRDINGS(0,TMODES) > 0)
         MW[5]=BRDINGS(0,TMODES)-1                                                   ; Number of transfers
    ELSE
         MW[5]=0
    ENDIF
         MW[6]=IWAITA(0)                                                              ; Initial wait time
         MW[7]=XWAITA(0)                                                              ; Transfer wait time
         MW[8]=FAREA(0)                                                               ; Fare matrix
         MW[9]=TIMEA(0,ALLMODES)                                                      ; Time on all modes
    ENDPROCESS

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\projects\rvtpo\Cube\Trn_Skims_OP.S"
;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\Output\LOGS\Trn_OP_Skims.PRN" MSG='OP-Walk Access Paths / Skims'
FILEI NTLEGI[1] = "{SCENARIO_DIR}\OUTPUT\NTLEG1_TEM.NTL"
FILEI NETI = "{SCENARIO_DIR}\OUTPUT\HWYTSPD.NET"
FILEO MATO[2] = "{SCENARIO_DIR}\Output\OP_TSKIMPrem.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO MATO[1] = "{SCENARIO_DIR}\Output\OP_TSKIMBus.MAT",
MO=1-9, NAME=WALKTIME,BUSTIME,TRTIME,PRJTIME,NXFER,IWAIT,XWAIT,FARE,TOTTIME
FILEO ROUTEO[2] = "{SCENARIO_DIR}\Output\OP_TPATHPrem.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO ROUTEO[1] = "{SCENARIO_DIR}\Output\OP_TPATHBus.RTE",
REPORTI={FromNode}, REPORTJ={ToNode}, TRACEI={FromNode}, TRACEJ={ToNode}    
FILEO REPORTO = "{SCENARIO_DIR}\Output\OP_TransitWalk.rpt"
FILEO NETO = "{SCENARIO_DIR}\Output\OP_TransitWalk.NET"
FILEI FACTORI[2] = "{CATALOG_DIR}\Params\transit\WalkPrem.FAC"
FILEI FACTORI[1] = "{CATALOG_DIR}\Params\transit\WalkBus.FAC"
FILEI FAREI = "{CATALOG_DIR}\Params\transit\TFARES.FAR"
FILEI SYSTEMI = "{CATALOG_DIR}\Params\transit\TSYSD.PTS"
FILEI LINEI[1] = "{SCENARIO_DIR}\Input\TROUTE.LIN"

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

   ; OVERALL PARAMETERS
   PARAMETERS USERCLASSES=1-2,FARE=N, MAPSCALE={UNIT}, HDWAYPERIOD=2,
         NOROUTEERRS=999999, NOROUTEMSGS=999999,
         TRANTIME=LW.TRANTIME,
         TRANTIME[21]=LI.M21TIMEPK,
         TRANTIME[22]=LI.M22TIMEPK,
         TRANTIME[26]=LI.M26TIMEPK

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    
   PROCESS PHASE=LINKREAD
         LW.TRANTIME=LI.M21TIMEPK
         LW.WALKTIME=LI.WALKTIME
         LW.WALKDISTANCE=LI.DISTANCE
         LW.DISTANCE=LI.DISTANCE
   ENDPROCESS

   PROCESS PHASE=DATAPREP

         ;Generate walk-access links
         GENERATE READNTLEGI=1
    ENDPROCESS

;**************************************************************
;BEGIN POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************

    PROCESS PHASE=SKIMIJ
         MW[1]=TIMEA(0,1)                                                              ; Walk time
         MW[2]=TIMEA(0,21)                                                             ; All bus time
         MW[3]=TIMEA(0,22)                                                              ; Trolley time
         MW[4]=TIMEA(0,26)                                                             ; Project mode time

;**************************************************************
;END POTENTIAL SCRIPT ADJUSTMENT
;**************************************************************
    IF(BRDINGS(0,TMODES) > 0)
         MW[5]=BRDINGS(0,TMODES)-1                                                   ; Number of transfers
    ELSE
         MW[5]=0
    ENDIF
         MW[6]=IWAITA(0)                                                              ; Initial wait time
         MW[7]=XWAITA(0)                                                              ; Transfer wait time
         MW[8]=FAREA(0)                                                               ; Fare matrix
         MW[9]=TIMEA(0,ALLMODES)                                                      ; Time on all modes
    ENDPROCESS

ENDRUN


; Script for program FRATAR in file "C:\projects\rvtpo\CUBE\EEFRA00A.S"

; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Future year EE Table'
FILEI MATI[1] = "{SCENARIO_DIR}\INPUT\EE_seed.MAT"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\INPUT\EXTERNALTRIPS.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT",
 MO=1,NAME = EE_TRIPS, DEC=1*D

PARAMETERS MAXRMSE=0.0001 MAXITERS=25
; USE A LOOKUP FILE TO find appropriate factors (1.0 is assumed unless expressly provided)
LOOKUP LOOKUPI=1, LIST=Y,
  NAME=GROWTHF,
  LOOKUP[1]=ZONE,RESULT=AADT_FAC,
  LOOKUP[2]=ZONE,RESULT=AADT_FAC,
  FAIL[1]=1,FAIL[2]=1,FAIL[3]=1

SETPA PGF[1]=GROWTHF(1,I) AGF[1]=GROWTHF(2,I) MW[1]=MI.1.1 

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\CUBE\EEMAT00A.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\EXTERNALTRIPS.DBF",
fields=ZONE,AADT,EE_Total,IEEI
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\EXTERNALTRIPS.DBF"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"

MW[1]=mi.1.1
MW[2]=mi.1.1.t 

IF( I >= 250)
  RO.PROD1=ROWSUM(1)
  RO.ATTR1=ROWSUM(2)
  RO.ZONE=I
  RO.EE_Total = RO.PROD1 + RO.ATTR1
  RO.AADT = ZI.1.EXTTOTAL * ZI.1.AADT_FAC
  RO.IEEI = RO.AADT - RO.EE_Total
  
WRITE RECO=1
ENDIF

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\EE_HwySkims.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Process Highway Skims'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT",
 MO=11-15,DEC=5*D,NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME
FILEI MATI[1] = "{SCENARIO_DIR}\Output\IMPED11.MAT"

FILLMW MW[1]=MI.1.1(5)                ; highway skims

; Reset invalid values to zero
  JLOOP
      IF (MW[1] > 1000)
          MW[11] = 0
      ELSE
          MW[11] = MW[1]
      ENDIF

      IF (MW[2] > 1000)
          MW[12] = 0
      ELSE
          MW[12] = MW[2]
      ENDIF

      IF (MW[3] > 1000)
          MW[13] = 0
      ELSE
          MW[13] = MW[3]
      ENDIF

      IF (MW[4] > 1000)
          MW[14] = 0
      ELSE
          MW[14] = MW[4]
      ENDIF

      IF (MW[5] > 1000)
          MW[15] = 0
      ELSE
          MW[15] = MW[5]
      ENDIF

      ENDJLOOP

ENDRUN


; Script for program GENERATION in file "C:\projects\rvtpo\Cube\EE_TripGen.S"
;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION MSG='IEEI_TripGen'
FILEI ZDATI[2] = "{SCENARIO_DIR}\OUTPUT\EXTERNALTRIPS.DBF"
FILEO PAO[1] = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF",
FORM=10.3, DBF=T, LIST=Z, P[1], A[1]
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\se.dbf"

ZONES={Total Zones}

PHASE=ILOOP
  CoeffHH     = 0.423546369 * 2
  CoeffIND    = 0.235065256 * 2
  CoeffSER    = 0.158333776 * 2
  CoeffOFFHTR = 0.148286574 * 2
  CoeffRET    = 0.208675310 * 2
  CoeffSG     = 0.225389103 * 2
				  	; adjustent factor reflects change required to make estimated trip generation rates match observed trips

GrwthRate=1.0								; for future year models, replace this 1.0 with the assumed growth rate       

  IF (I<=206)
    TOTALSG = ZI.1.SG_RET + ZI.1.SG_HOS + ZI.1.SG_AIR + ZI.1.SG_COL
    OFFHTRET = ZI.1.OFF + ZI.1.HTRET
    A[1]=(ZI.1.HH * CoeffHH) + (ZI.1.IND * CoeffIND) + (ZI.1.RET * CoeffRET) +
       (OFFHTRET * CoeffOFFHTR) + (ZI.1.SER * CoeffSER) + (TOTALSG * CoeffSG)
    P[1]= 0
  ELSE
    A[1]=0
    P[1]= ZI.2.IEEI 
  ENDIF
  ENDPHASE

PHASE=ADJUST
  BALANCE A2P=1
  
REPORT A=Y P=Y
ENDPHASE
 

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\EE_nonResident_NHB.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='NR-NHB Model'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\NHBNR_PA_{year}.DBF",
 FIELDS=Z, NHBNR_P, NHBNR_A
FILEI RECI = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF"


ZONES = {Total Zones}
NHB_PCT = .30 ; 30% of External trips make NHB trips inside the region

RO.Z=RI.Z
RO.NHBNR_P = RI.P1 * NHB_PCT
RO.NHBNR_A = RI.A1 * NHB_PCT
WRITE RECO=1

ENDRUN


; Script for program DISTRIBUTION in file "C:\projects\rvtpo\Cube\EE_TripDistribution.S"
;;<<Default Template>><<DISTRIBUTION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION MSG='IEEI_TripDist'
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\IEEI_{year}.MAT",
 MO=1, NAME=TRIPS, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT"

PAR maxiters=20 maxrmse=10
setpa p[1]=zi.1.p1, a[1]=zi.1.a1  ;Set P and A Fields

; Gamma Function parameters
alpha   =  1.3544
beta    = -4.0016
epsilon =  .14

MW[2]=mi.1.1      ; total travel time

; First replace any 0 times with a very small travel time to avoid
;  failure of the exponentiation calculation.
JLOOP
  IF (MW[2]=0)
    MW[2]=.1
    ENDIF
  ENDJLOOP

;calculate friction factor using the gamma function
mw[3]  = (alpha * (MW[2]^beta) * EXP(epsilon*MW[2]))

;apply the results of gamma formulation
PAF=0
MW[1] = A[1] * MW[3]
ATTRSUM=ROWSUM(1)
IF (ATTRSUM>0) PAF=P[1]/ATTRSUM
MW[1]=PAF * MW[1]


; ========GENERATE FREQUENCY REPORTS BASED ON TIME============
FREQUENCY VALUEMW=1 BASEMW=2, RANGE=0-42,
TITLE='** IEEI Travel Time Frequency **'
ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\IEEI_TOD.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX
FILEO MATO[4] = "{SCENARIO_DIR}\Output\IEEI_{year}_NT.MAT",
 MO=34, NAME=IEEI_NT, DEC=D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\IEEI_{year}_PM.MAT",
 MO=33, NAME=IEEI_PM, DEC=D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\IEEI_{year}_MD.MAT",
 MO=32, NAME=IEEI_MD, DEC=D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\IEEI_{year}_AM.MAT",
 MO=31, NAME=IEEI_AM, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\Output\IEEI_{year}.MAT"
ZONES={Total Zones}

;Define arrays of time of day factors
ARRAY IEFct=4
IEFct[1] = 0.03 	;AM IE Factor
IEFct[2] = 0.28   ;MD IE Factor 
IEFct[3] = 0.08   ;PM IE Factor 
IEFct[4] = 0.11   ;NT IE Factor 

ARRAY EIFct=4
EIFct[1] = 0.16 	;AM EI Factor
EIFct[2] = 0.20   ;MD EI Factor 
EIFct[3] = 0.03   ;PM EI Factor 
EIFct[4] = 0.11   ;NT EI Factor 

MW[1]=mi.1.1      ;IEEI Daily Trips
MW[2]=mi.1.1.T    ;IEEI Daily Trips

;  MW[11] through MW[14] are the working tables (four time periods) for IE trips
;  MW[21] through MW[24] are the working tables (four time periods) for EI trips
;  MW[31] through MW[34] are the final output tables (four time periods) for total IEEI trips.

LOOP TOD=1,4                          
  IETable = (10) + TOD
  MW[IETable] = MW[2] * IEFct[TOD]
  
  EITable = (20) + TOD
  MW[EITable] = MW[1] * EIFct[TOD]
  
  TODTable = (30) + TOD
  MW[TODTable] = MW[IETable] + MW[EITable]
ENDLOOP

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\EE_TOD.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='EE TOD'
FILEO MATO[4] = "{SCENARIO_DIR}\Output\EE_{year}_NT.MAT",
MO=14, NAME=EE_NT, DEC=1*D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\EE_{year}_PM.MAT",
MO=13, NAME=EE_PM, DEC=1*D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\EE_{year}_MD.MAT",
MO=12, NAME=EE_MD, DEC=1*D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\EE_{year}_AM.MAT",
 MO=11, NAME=EE_AM, DEC=1*D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\EE_{Year}.MAT"


MW[1]=mi.1.1     ;EE Daily Trips

ZONES={Total Zones}

;Define arrays of time of day factors
ARRAY EEFct=4
EEFct[1] = 0.141	;AM IE Factor
EEFct[2] = 0.458	;MD IE Factor
EEFct[3] = 0.154	;PM IE Factor
EEFct[4] = 0.247  ;NT IE Factor




;  MW[11] through MW[14] are the working tables (four time periods) for EE trips

LOOP TOD=1,4                          
  EETable = (10) + TOD
  MW[EETable] = MW[1] * EEFct[TOD]
ENDLOOP
ENDRUN


; Script for program GENERATION in file "C:\projects\rvtpo\Cube\CV_TripGen.S"
;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION MSG='CV_TripGen'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\CVRATES.CSV"
FILEO PAO[1] = "{SCENARIO_DIR}\Output\CV_PA_{year}.DBF",
FORM=10.3, DBF=T, LIST=Z, P[1], P[2], P[3], A[1], A[2], A[3]
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\se.dbf"

ZONES={Internal Zones}

LOOKUP, LOOKUPI=1, 
	NAME=CVRates,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
	INTERPOLATE=N, FAIL[1]=0, FAIL[2]=0, FAIL[3]=0, LIST=Y

PHASE=ILOOP

	P[1]=	(IND*CVRates(1,1))+((RET + SG_RET)*CVRates(1,2))+(HTRET*CVRates(1,3))+(OFF*CVRates(1,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(1,5))+(HH*CVRates(1,6))
  
	P[2]=	(IND*CVRates(2,1))+((RET + SG_RET)*CVRates(2,2))+(HTRET*CVRates(2,3))+(OFF*CVRates(2,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(2,5))+(HH*CVRates(2,6))
	P[3]= (IND*CVRates(3,1))+((RET + SG_RET)*CVRates(3,2))+(HTRET*CVRates(3,3))+(OFF*CVRates(3,4))+((SER+SG_AIR+SG_COL+SG_HOS)*CVRates(3,5))+(HH*CVRates(3,6))
  
	A[1]=P[1]
  A[2]=P[2]
  A[3]=P[3]
  
ENDPHASE

PHASE=ADJUST
  BALANCE NHB=1
ENDPHASE

ENDRUN


; Script for program DISTRIBUTION in file "C:\projects\rvtpo\Cube\CV_TripDistribution.S"
;;<<Default Template>><<DISTRIBUTION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION
FILEO MATO[1] = "{SCENARIO_DIR}\Output\CV_{Year}.MAT",
  MO=1-3, NAME=FourTire, SixTire, Combo, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT"
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\CV_PA_{year}.DBF"


PAR maxiters=20 maxrmse=10

setpa  P[1]=ZI.1.P1, P[2]=ZI.1.P2, P[3]=ZI.1.P3,		; Set P and A Fields 1-3 = 4-tire, 6-tire, and combo
			A[1]=ZI.1.A1, A[2]=ZI.1.A2, A[3]=ZI.1.A3

; Estmated Gamma Function parameters,  Define array of coefficients and poplate.
	ARRAY alpha=3
	ARRAY beta=3
	ARRAY epsilon=3

; Coefficients are set the the default NCDOT Small Area Travel Demand Model Procedures Manual
;     for all three CV types.  Further testing and calibration may be needed.
  alpha[1] = 4.6750
	beta[1] = 0.2916
	epsilon[1] = 0.1390

	alpha[2] = 4.6750
	beta[2] = 0.2916
	epsilon[2] = 0.1390

	alpha[3] = 4.6750
	beta[3] = 0.2916
	epsilon[3] = 2.4000

MW[10]=mi.1.1      ; total travel time

; First replace any 0 times with a very small travel time to avoid
;  failure of the exponentiation calculation.
JLOOP
  IF (MW[10]=0)
    MW[10]=0.0000001
    ENDIF
  ENDJLOOP

;calculate friction factor using the gamma function
LOOP CVType=1,3
  CVIDX=10+CVType
	MW[CVIDX] = alpha[CVType] * (MW[10]^beta[CVType]) * EXP(epsilon[CVType]*MW[10])
	ENDLOOP  

;apply the results of gamma formulation
LOOP PURP= 1, 3
  CVIDX=10+PURP
	PAF=0
	MW[PURP] = A[PURP] * MW[CVIDX]
	ATTRSUM=ROWSUM(PURP)
	IF (ATTRSUM>0) PAF=P[PURP]/ATTRSUM
	MW[PURP]=PAF * MW[PURP]
ENDLOOP

; ========GENERATE FREQUENCY REPORTS BASED ON TIME============
FREQUENCY VALUEMW=1 BASEMW=10, RANGE=0-42,
TITLE='** CV 4-Tire Travel Time Frequency **'

FREQUENCY VALUEMW=2 BASEMW=10, RANGE=0-42,
TITLE='** SUT 6-Tire Travel Time Frequency **'

FREQUENCY VALUEMW=3 BASEMW=10, RANGE=0-42,
TITLE='** MUT Combo Travel Time Frequency **'

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\CV_TimeOfDay.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX
FILEO MATO[4] = "{SCENARIO_DIR}\Output\CV_{year}_NT.MAT",
 MO=41-43, NAME=CV_NT, SUT_NT, MUT_NT, DEC=D
FILEO MATO[3] = "{SCENARIO_DIR}\Output\CV_{year}_PM.MAT",
 MO=31-33, NAME=CV_PM, SUT_PM, MUT_PM, DEC=D
FILEO MATO[2] = "{SCENARIO_DIR}\Output\CV_{year}_MD.MAT",
 MO=21-23, NAME=CV_MD, SUT_MD, MUT_MD, DEC=D
FILEO MATO[1] = "{SCENARIO_DIR}\Output\CV_{Year}_AM.MAT",
 MO=11-13, NAME=CV_AM, SUT_AM, MUT_AM, DEC=D
FILEI MATI[1] = "{SCENARIO_DIR}\Output\CV_{Year}.MAT"

ZONES={Total Zones}

;Define array of time of day factors
;Note that time of day factors for CV trips are the same for PA as AP trips.
;  So rather than apply a PA TOD and an AP TOD and then recombining the table
;  by time period we can simply apply double the PA (or AP)TOD rate.

ARRAY TODFct=4
TODFct[1] = 0.0458 * 2 	;AM Factor
TODFct[2] = 0.1652 * 2  ;MD Factor 
TODFct[3] = 0.1634 * 2  ;PM Factor 
TODFct[4] = 0.1256 * 2  ;NT Factor 

MW[1]=mi.1.1      ;CV  Daily Trips
MW[2]=mi.1.2      ;SUT Daily Trips
MW[3]=mi.1.3      ;MUT Daily Trips

LOOP TOD=1,4                              
  LOOP CVType=1,3 
     TODTable = (10*TOD)+ CVType
    MW[TODTable] = MW[CVType] * TODFct[TOD]
  ENDLOOP
ENDLOOP
ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\CV_TLFD.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\CV_TLFD.PRN" MSG='Trip Length Frequency'
FILEO RECO[3] = "{SCENARIO_DIR}\OUTPUT\TLFD_MUT.DBF",
FIELDS= HIGH,MID,MLOW,MUT_TRIPS(16.8)
FILEO RECO[2] = "{SCENARIO_DIR}\OUTPUT\TLFD_SUT.DBF",
FIELDS= HIGH,MID,LOW,SUT_TRIPS(16.8)
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\TLFD_CV.DBF",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\CV_{Year}.MAT"
FILEO PRINTO[1] = "C:\projects\rvtpo\CUBE\CVMAT00B.PRN"

             MW[1]=MI.1.1
             MW[2]=MI.1.2
             MW[3]=MI.1.3
             MW[4]=MI.2.Time
             gps=40-1
             Array trips=40, sut_trips = 40, mut_trips =40           

             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=1 RANGE=0-100-1 

             ; SUT
              JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             SUT_trips[group]=SUT_trips[group]+mw[2]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.SUT_TRIPS=SUT_trips[group]
                write reco=2
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.SUT_TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=2 RANGE=0-100-1 
             
              ; MUT
              JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[4]/1),gps) + 1
             MUT_trips[group]=MUT_trips[group]+mw[3]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,40
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.MUT_TRIPS=MUT_trips[group]
                write reco=3
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.MUT_TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=4 VALUEMW=3 RANGE=0-100-1             
            
ENDRUN


LOOP FeedBack_ITER = 1, 5, 1

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (FeedBack_ITER=1) 
FB_ITER = 1
pk_hwy_skim = 'PK_FreeFlow_Skim.MAT'
OP_hwy_skim = 'OP_FreeFlow_Skim.MAT'

ELSE 
pk_hwy_skim = 'PK_CNG_HwySkim.MAT'
OP_hwy_skim = 'OP_CNG_HwySkim.MAT'
ENDIF



; End of PILOT Script

; Script for program MATRIX in file "C:\projects\rvtpo\Cube\Process_HwySkim_PK.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Process Highway Skims'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\pk_Hwyskim.MAT",
 MO=11-15,DEC=5*D,NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\@pk_hwy_skim@"

FILLMW MW[1]=MI.1.1(5)                ; highway skims

; Reset invalid values to zero
  JLOOP
      IF (MW[1] > 1000)
          MW[11] = 0
      ELSE
          MW[11] = MW[1]
      ENDIF

      IF (MW[2] > 1000)
          MW[12] = 0
      ELSE
          MW[12] = MW[2]
      ENDIF

      IF (MW[3] > 1000)
          MW[13] = 0
      ELSE
          MW[13] = MW[3]
      ENDIF

      IF (MW[4] > 1000)
          MW[14] = 0
      ELSE
          MW[14] = MW[4]
      ENDIF

      IF (MW[5] > 1000)
          MW[15] = 0
      ELSE
          MW[15] = MW[5]
      ENDIF

      ENDJLOOP

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\Process_HwySkim_OP.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Process Highway Skims'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\OP_Hwyskim.MAT",
 MO=11-15,DEC=5*D,NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\@op_hwy_skim@"

FILLMW MW[1]=MI.1.1(5)                ; highway skims

; Reset invalid values to zero
  JLOOP
      IF (MW[1] > 1000)
          MW[11] = 0
      ELSE
          MW[11] = MW[1]
      ENDIF

      IF (MW[2] > 1000)
          MW[12] = 0
      ELSE
          MW[12] = MW[2]
      ENDIF

      IF (MW[3] > 1000)
          MW[13] = 0
      ELSE
          MW[13] = MW[3]
      ENDIF

      IF (MW[4] > 1000)
          MW[14] = 0
      ELSE
          MW[14] = MW[4]
      ENDIF

      IF (MW[5] > 1000)
          MW[15] = 0
      ELSE
          MW[15] = MW[5]
      ENDIF

      ENDJLOOP

ENDRUN


  LOOP PURPOSE = 1, 4, 1

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (PURPOSE=1) ; HBW Purpose
PURP='HBW'
PURPNO=3
PRK='LONGPARK'
hwySkim = 'pk_Hwyskim.MAT'
busSkim = 'pk_TSKIMBus.MAT'
premSkim = 'PK_TSKIMPrem.MAT'

ELSEIF (PURPOSE=2) ; HBO Purpose
PURP='HBO'
PURPNO=4
PRK='LONGPARK'
hwySkim = 'op_Hwyskim.MAT'
busSkim = 'op_TSKIMBus.MAT'
premSkim = 'op_TSKIMPrem.MAT'

ELSEIF (PURPOSE=3) ; NHB Purpose
PURP='NHB'
PURPNO=5
PRK='LONGPARK'
hwySkim = 'op_Hwyskim.MAT'
busSkim = 'op_TSKIMBus.MAT'
premSkim = 'op_TSKIMPrem.MAT'

ELSEIF (PURPOSE=4) ; HBSC Purpose
PURP='HBSC'
PURPNO=5
PRK='LONGPARK'
hwySkim = 'op_Hwyskim.MAT'
busSkim = 'op_TSKIMBus.MAT'
premSkim = 'op_TSKIMPrem.MAT'
ENDIF

; End of PILOT Script

; Script for program MATRIX in file "C:\projects\rvtpo\Cube\ModeChoice_Logsum.s"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\@PURP@_logsum.PRN" MSG='Mode Choice Logsums and Probabilities'
FILEI MATI[3] = "{SCENARIO_DIR}\Output\@premSkim@"
FILEI MATI[2] = "{SCENARIO_DIR}\Output\@busSkim@"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\@hwySkim@"
FILEO MATO[3] = "{SCENARIO_DIR}\output\@PURP@_MCPROB.MAT",
MO=351-355,361-365,DEC=10*D,NAME=cw_da_prob,cw_sr_prob,cw_wlkbus_prob,cw_wlkprem_prob,cw_nmot_prob,
nt_da_prob,nt_sr_prob,nt_wlkbus_prob,nt_wlkprem_prob,nt_nmot_prob
FILEO MATO[2] = "{SCENARIO_DIR}\output\@PURP@_MCUTIL.MAT",
MO=301-306,311-316,DEC=12*D,NAME=cw_da_util,cw_sr_util,cw_wlkbus_util,cw_wlkprem_util,cw_nmot_util,Logsum,
nt_da_util,nt_sr_util,nt_wlkbus_util,nt_wlkprem_util,nt_nmot_util,Logsum

; Logsums averaged across access markets
FILEO MATO[1] = "{SCENARIO_DIR}\output\@PURP@_MCLS.MAT",
  MO=621,DEC=1*D, NAME=LSUM

FILEI LOOKUPI[2] = "{CATALOG_DIR}\Params\mc\MC_Coefficients.csv"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\mc\MC_Constants.csv"
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\TrnWalkPercent.dbf"

; Progress Bar update for evey 100 zones
zonemsg=50
    
; Declare arrays to hold alternative specific constants
;        ARRAY PARK=2578
 ;ARRAY TYPE=F K_AUT=1, K_SR=1, K_TRN=1, K_NMOT=1 
 ;ARRAY TYPE=C30 MARKET_NAME=1
    
; Read alternative specific Constants
LOOKUP, NAME=CONSTANTS, LOOKUP[1]=1, RESULT=@PURPNO@, INTERPOLATE=N, , LIST=Y, LOOKUPI=1
    
; Read mode choice coefficients
LOOKUP, NAME=COEFF, LOOKUP[1]=1, RESULT=@PURPNO@, INTERPOLATE=N, LIST=Y, LOOKUPI=2


IF (i=FirstZone)

  ; constants
   ;K_AUT  = CONSTANTS(1,1)            ; auto 
   K_SR  = CONSTANTS(1,1)            ; shared-ride 2 & 3+
   K_TRN  = CONSTANTS(1,2)            ; transit
   K_NMOT = CONSTANTS(1,3)            ; non-motorized (walk & bike)
     
; Mode-specific constants 
   K_PREM = CONSTANTS(1,4)                        ; premium transit
                                        
; Nesting coefficients
   NC_1        = COEFF(1,14)                          ; Level 1 - auto, trn, non-mot
   NC_2        = COEFF(1,15)                          ; Level 2 - transit sub mode choice
   NC_3        = COEFF(1,16)                          ; Level 3 - not used
   ;NCP = NC_1 * NC_2

   ; Level of Service Coefficients
  COEFF_IVTT   = COEFF(1,1)                ; In-vehicle travel time coefficient
  COEFF_SWAIT  = COEFF(1,2)                ; Short wait(<5 minutes)
  COEFF_LWAIT  = COEFF(1,3)                ; Long wait (>5 minutes)
  COEFF_XWAIT  = COEFF(1,4)                ; Xfer wait
  COEFF_DRIVE  = COEFF(1,6)                ; Drive access
  COEFF_TERML  = COEFF(1,7)                ; Terminal time
  COEFF_WALK   = COEFF(1,8)                ; Walk access
  COEFF_WALK1  = COEFF(1,9)                ; Walk time < 1
  COEFF_WALK2  = COEFF(1,10)               ; Walk time > 1
  COEFF_BIKE1  = COEFF(1,11)               ; Bike time < 1
  COEFF_BIKE2  = COEFF(1,12)               ; Bike time > 1
  DWalkBIKE    = COEFF(1,13)               ; Walk and Bike threshold
  AUTOCOST     = COEFF(1,19)               ; Auto Operating Costs in Cents
  OCC          = COEFF(1,20)               ; Cost Sharing Factor for Shared Ride

; Cost coefficients
  COEFF_COST  = COEFF(1,5)                ; Cost 
  
; Calibration specific
COEFF_CBD     = COEFF(1,17)              ; CBD 
COEFF_NXFER   = COEFF(1,18)              ; number of xfers 

ENDIF

MW[1]=1                                 ; assign a value of 1 for probabilities
FILLMW MW[11]=MI.1.1(5)                ; highway skims
FILLMW MW[21]=MI.2.1(9)              ; tskimbus -- walk to bus
FILLMW MW[31]=MI.3.1(9)              ; tskimprem -- walk to premium transit

; Non motorized
; distance portion that is 1 mile or less
MW[18] = MIN(MW[12],1)
  
; Distance portion that is longer than 1 mile
  JLOOP
      IF (MW[12][J] > 1)
          MW[19] = MW[12][J] - 1
      ELSE
          MW[19] = 0
      ENDIF

  ENDJLOOP

; *******************************************  WALK ACCESS MARKETS  ************************************************
; ******************************************************************************************************************

; Loop by walk access markets
LOOP ACC=1,2

; ************************** UTILITY CALCULATIONS ************************************
; Computes utility that is common across all household market segments
     
     ; Drive alone
     MW[101] = (COEFF_TERML  * (MW[13] + MW[14]) +                          ; Terminal time
                COEFF_IVTT   * MW[11]           +                          ; IVTT
                COEFF_CBD    * ZI.1.CBD[J]     +                          ; CBD dummy
                COEFF_COST   * ZI.1.@PRK@[J]   +                          ; Auto parking cost
                COEFF_COST   * MW[12] * AUTOCOST)                          ; Auto operating cost
     MW[201] = MW[101] / NC_1 / NC_2                                      ; Scaled Utility
    
     ; Shared Ride or HOV
     MW[102] = (K_SR       +                                              ; Constant(s)
                COEFF_TERML * (MW[13] + MW[14]) +                           ; Terminal time
                COEFF_IVTT  * MW[11]             -                         ; IVTT
                COEFF_CBD   * ZI.1.CBD[J] +                               ; CBD dummy               
                COEFF_COST   * (ZI.1.@PRK@[J] / OCC)   +                  ; Auto parking cost
                COEFF_COST  * MW[12] * AUTOCOST)                           ; Auto operating cost (not shared among occupants)
     MW[202] =  MW[102] / NC_1 / NC_2                                     ; Scaled Utility
     
     ; Walk to Bus
     MW[103] = (K_TRN                                       +                      ; Transit Constant
                COEFF_WALK     *  MW[21]                    +                      ; Walk Access Time
                COEFF_SWAIT    *  MIN(MW[26],5)             +                      ; Short wait (< 5 mins)
                COEFF_LWAIT    * (MW[26] - MIN(MW[26],5))   +                      ; Long wait (> 5 mins)
                COEFF_XWAIT    *  MW[27]                    +                      ; Xfer Wait
                COEFF_IVTT     * (MW[22] + MW[23])          +                      ; IVTT (local bus + trolley time)
                COEFF_COST     *  MW[28] * 100              +                      ; Transit Fare Converted to Cents
                COEFF_NXFER    *  MW[25]                    +                      ; Num Xfers Dummy
                COEFF_CBD      *  ZI.1.CBD[J])                                     ; CBD dummy
     MW[203] = MW[103] /NC_1 /NC_2                                                 ; Scaled Utility

     ; Walk to Premium Transit
     MW[104] = (K_TRN + K_PREM                              +                      ; Transit Constant(s)
                COEFF_WALK     *  MW[31]                    +                      ; Walk Access Time
                COEFF_SWAIT    *  MIN(MW[36],5)             +                      ; Short wait (< 5 mins)
                COEFF_LWAIT    * (MW[36] - MIN(MW[36],5))   +                      ; Long wait (> 5 mins)
                COEFF_XWAIT    *  MW[37]                    +                      ; Xfer Wait
                COEFF_IVTT     * (MW[32] + MW[33] + MW[34]) +                      ; IVTT (local bus + trolley + premium time)
                COEFF_COST     *  MW[38] * 100              +                      ; Transit Fare Converted to Cents
                COEFF_NXFER    *  MW[35]                    +                      ; Num Xfers Dummy
                COEFF_CBD      *  ZI.1.CBD[J])                                     ; CBD dummy
     MW[204] = MW[104] /NC_1 /NC_2                                                 ; Scaled Utility

     ; Non Motorized
     MW[105] = (K_NMOT                                     +                       ; Constant(s)
                COEFF_WALK1  * (60/3) * MW[18]                      +                       ; Walk time if less than 1 mile
                COEFF_WALK2  * (60/3) * MW[19])                                             ; Walk time if more than 1 mile
     MW[205] = MW[105] / NC_1                                                      ; Scaled Utility
            
    
  ;************************** END UTILITY CALCULATIONS ************************************

  ;***************************    MODE AVAILABILITY CHECKS    ************************************
;  LOOP _m=1,@MARKETS@
    JLOOP
       ; Transit not available if no line-haul in-vehicle time on the transit path
       ; Walk to bus or trolley
       IF ((MW[22]+MW[23]) <= 0) 
       MW[203]=-9999.99
       ELSE
       MW[203]=MW[203]
       ENDIF

       ; Walk to express bus
       IF (MW[34] == 0) 
         MW[204]=-9999.99
       ENDIF

                        
       ; Transit not available for NT access markets;
       IF(ACC==2)
         MW[203]=-9999.99
         MW[204]=-9999.99
       ENDIF
       
    ENDJLOOP

   ; ############################# XCHOICE SETUP ###################################
   ; Use DEMAND=1 to generate probabilities.
   ; for all purposes
         _DMD=1
         XCHOICE ALTERNATIVES=da,sr,wlkbus,wlkprem,nmot,
         UTILITIESMW=201,202,203,204,205,
         DEMANDMW=_DMD,
         ODEMANDMW=401,402,403,404,405,
         STARTMW=900,
   ;     Model Structure
   ;     Top level nest
         SPLIT = Total NC_1 auto NC_1 transit NC_1 nmot,
         SPLITCOMP=503,
   ;     Auto nest
         SPLIT = auto NC_2 da NC_2 sr,
         SPLITCOMP=501,
   ;     Transit nest
         SPLIT = transit NC_2 wlkbus NC_2 wlkprem,
         SPLITCOMP=502

   ; Store logsums for each access market 
     IF (ACC==1) 
       MW[301] = MW[201]    ; da util            
       MW[302] = MW[202]    ; sr util     
       MW[303] = MW[203]    ; walk bus util                        
       MW[304] = MW[204]    ; walk prem util                        
       MW[305] = MW[205]    ; non motorized util                        
       MW[306] = MW[503]    ; Logsum 
       MW[351] = MW[401]    ; da prob            
       MW[352] = MW[402]    ; sr prob     
       MW[353] = MW[403]    ; walk bus prob                        
       MW[354] = MW[404]    ; walk prem prob                        
       MW[355] = MW[405]    ; non motorized prob                        
     ELSEIF (ACC==2)
       MW[311] = MW[201]    ; da util            
       MW[312] = MW[202]    ; sr util     
       MW[313] = MW[203]    ; walk bus util                        
       MW[314] = MW[204]    ; walk prem util                        
       MW[315] = MW[205]    ; non motorized util                        
       MW[316] = MW[503]    ; Logsum 
       MW[361] = MW[401]    ; da prob            
       MW[362] = MW[402]    ; sr prob     
       MW[363] = MW[403]    ; walk bus prob                        
       MW[364] = MW[404]    ; walk prem prob                        
       MW[365] = MW[405]    ; non motorized prob                        
    ENDIF
 
    
        ; Calculate access market shares
    ARRAY TYPE=F ACCShare=ZONES,ZONES,2
    JLOOP
      IF (ACC==1)
          ACCShare[I][J][ACC] = (ZI.1.PCWPROD[I] * 0.01) * (ZI.1.PCWATTR[J] * 0.01)         ; Can Walk
      ELSEIF (ACC==2)
          ACCShare[I][J][ACC] = 1 - ACCShare[I][J][1]                                 ; No Transit
      ENDIF
    ENDJLOOP

    ; Calculate logit average of the mode choice logsums (composite utilities) across access markets
   JLOOP
     MW[621] = MW[621] + EXP(MW[503]) * ACCShare[I][J][ACC]
     IF(ACC==2)
      if (MW[621]> 0) 
        MW[621] = LN(MW[621])
      else 
        MW[621] = 0
      endif
     ENDIF
   ENDJLOOP

  
ENDLOOP ; end access loop

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


; End of PILOT Script

  ENDLOOP

; Script for program MATRIX in file "C:\projects\rvtpo\CUBE\TDMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\TDMAT00C.PRN" MSG='HBSC FF'
    zones = 1
    alpha = 1000000
    Beta = 0.36
    gamma = -0.65

FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\HBSC_FFFile.CSV",
 APPEND=F
    PRINT CSV=T, LIST=';Friction Factors', PRINTO=1, rewind=T
    
    LOOP CT= 1,100,1     ; Creating FFs for use in distribution
      FF=alpha*(CT^Beta)*exp(gamma*CT)
      PRINT CSV=T, FORM=10.5, LIST=CT,FF, PRINTO=1
    ENDLOOP
ENDRUN


; Script for program DISTRIBUTION in file "C:\projects\rvtpo\Cube\TripDistribution_GravityModel_HBSC.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\Output\Logs\HBSC_distribution.PRN" MSG='Gravity Model - HBSC'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\OP_Hwyskim.mat"
FILEI ZDATI[2] = "{SCENARIO_DIR}\OUTPUT\se_classified_{year}{Alternative}.dbf"
FILEI ZDATI[1] = "{SCENARIO_DIR}\OUTPUT\HH_PROD.DBF"
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\Output\HBSC_FFFile.CSV"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT",
 MO=1,NAME=HBSC

  LOOKUP,
   LOOKUPI=1,
   INTERPOLATE=Y, NAME=FF,
    LOOKUP[1]=1,RESULT=2

  ;   output distributed trips by purpose
  PARAMETERS
    ZONES={TOTAL ZONES},MAXITERS=25
    
  ;    setup the working p's and a's
  SETPA P[1]=Zi.1.HBSCP  A[1]=Zi.2.SCHOOL 

  ;  get the los matrix into work matrix 11
  MW[11] = MI.1.Total_Time
  MW[12] = MI.1.Distance


  ;  do gravity models, each followed by a frequency summation
  GRAVITY   PURPOSE=1, LOS=MW[11], FFACTORS=FF
  ;
  FREQUENCY VALUEMW=1,  BASEMW=12,  RANGE=1-11, TITLE='HBSC TRIP LENGTH FREQUENCY'
  FREQUENCY VALUEMW=1,  BASEMW=11,  RANGE=1-24, TITLE='HBSC TRIP TIME LENGTH FREQUENCY'
  ;
  FREQUENCY VALUEMW=1,  BASEMW=11,  RANGE=1-15, TITLE='HBSC TRIP LENGTH FREQUENCY'

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\TripDistribution_D2DFlowsl_HBSC.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\HBSC_D2D_Flwos.PRN" MSG='HBSC District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_HBSC.MAT",
 MO = 1, NAME = HBSC

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 12, MISSINGZI=M, MISSINGZO=M
ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\TripDistribution_remove_SchoolBus.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\HBSC_noSchoolTrips.PRN" MSG='HBSC - no sch bus trips'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Dest_HBSC.MAT",
 MO = 1, NAME = HBSC

 MW[1] = MI.1.1 * (1 - 0.83)

ENDRUN


; PILOT Script
*COPY {CATALOG_DIR}\PARAMS\HBW_shadowPrice.dbf {SCENARIO_DIR}\OUTPUT\HBW_shadowPrice.dbf
; End of PILOT Script

  LOOP Iteration = 1, 10, 1

; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_HBW.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS0\DC_HBW.PRN" MSG='HBW Apply Destination Choice Model'
FILEI ZDATI[3] = "{SCENARIO_DIR}\OUTPUT\HBW_ShadowPrice.DBF"
FILEI ZDATI[2] = "{SCENARIO_DIR}\OUTPUT\HH_PROD.DBF"
FILEI ZDATI[1] = "{SCENARIO_DIR}\OUTPUT\se_classified_{year}{Alternative}.dbf"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\DESTCHOICE_PARAMETERS.DBF"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\HBW_MCLS.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\PK_Hwyskim.MAT"

FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT",
  MO=200,112, DEC=1*D, NAME=HBW, SizeTerm
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\DESTCHOICE_DEBUG.RPT"
FILEO PRINTO[2] = "{SCENARIO_DIR}\OUTPUT\DESTCHOICE_SUMMARY.TXT"
FILEO PRINTO[3] = "{SCENARIO_DIR}\OUTPUT\HBW_Zonal_Trips.csv"

		ZONES = {Total Zones}
		ARRAY personTrips = ZONES

		; READ IN MODEL PARAMETERS
		LOOKUP, NAME=COEFF, LOOKUP[1]=NVAR, RESULT=HBW, INTERPOLATE=N, LIST=Y, LOOKUPI=1
		Coeff_HH = COEFF(1,1)              ; SizeTerm = household coefficient
		Coeff_OTH_OFF_EMP = COEFF(1,2)     ; SizeTerm = Other + Office Emp coefficient
		Coeff_OFF_EMP = COEFF(1,3)         ; SizeTerm = Office Emp coefficient
		Coeff_OTH_EMP = COEFF(1,4)         ; SizeTerm = Other Emp coefficient
		Coeff_RET_EMP = COEFF(1,5)         ; SizeTerm = Retail Emp coefficient
		DISTCAP       = COEFF(1,6)         ; Capped distance (this is a value, not coefficient) ?
		CLSUM         = COEFF(1,7)         ; Logsum coefficient
		CDIST         = COEFF(1,8)         ; distance coefficient 
		CDISTSQ       = COEFF(1,9)         ; distance square coeffficient
		CDISTCUB      = COEFF(1,10)        ; distance cube coefficient
		CDISTLN       = COEFF(1,11)        ; distance log coefficient		
		KINTRAZ       = COEFF(1,12)        ; Intrazonal constant
		KDIST01       = COEFF(1,13)        ; distance calibration constant (0-1 Mile)
		KDIST12       = COEFF(1,14)        ; distance calibration constant (1-2 Mile)
		KDIST23       = COEFF(1,15)        ; distance calibration constant (2-3 Mile)
		KDIST34       = COEFF(1,16)        ; distance calibration constant (3-4 Mile)
		KDIST45       = COEFF(1,17)        ; distance calibration constant (4-5 Mile)
		KDIST56       = COEFF(1,18)        ; distance calibration constant (5-6 Mile)
		KDIST67       = COEFF(1,19)        ; distance calibration constant (6-7 Mile)

		; Mode choice logsums
		MW[1] = MI.1.1 
		
		; Hwy distance skim
		MW[2] = DISTCAP
    
    ; Distance calibration
    MW[113] = 0
		JLOOP
		
		  ; Read productions
		  personTrips[I] = ZI.2.HBWP
		  
		  ; Compute size term
		  MW[112] = Coeff_HH * ZI.1.HH[J] + Coeff_OFF_EMP * ZI.1.OFF[J] + Coeff_RET_EMP * (ZI.1.RET[J] + ZI.1.HTRET[J]) + Coeff_OTH_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.OFF[J]  - ZI.1.RET[J] - ZI.1.HTRET[J]) + Coeff_OTH_OFF_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.RET[J] - ZI.1.HTRET[J])
      
       ; ShadowPrice
      MW[116] = ZI.3.SHADOW_PRIC[J]     
      
		  ; Log (sizeTerm)
		  IF(MW[112] > 0)   MW[113] = Ln(MW[112])  
		
		  ; Intrazonal boolean
		  IF(J == I) MW[111] = 1
		
		  ; Hwy distance
		  IF (MI.2.Distance < DISTCAP)  MW[2] = MI.2.Distance  
		  IF (MI.2.Distance > 0)  MW[114] = Ln(MI.2.Distance) 
		  		
		  ; Distance calibration constants          
		  IF(MW[2] > 0 && MW[2] <=1) MW[115] = KDIST01    ; Calibration constant for distance 0-1 bin
		  IF(MW[2] > 1 && MW[2] <=2) MW[115] = KDIST12    ; Calibration constant for distance 1-2 bin
		  IF(MW[2] > 2 && MW[2] <=3) MW[115] = KDIST23    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 3 && MW[2] <=4) MW[115] = KDIST34    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 4 && MW[2] <=5) MW[115] = KDIST45    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 5 && MW[2] <=6) MW[115] = KDIST56    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 6 && MW[2] <=7) MW[115] = KDIST67    ; Calibration constant for distance 2-5 bin
		  

      
		  ; Utility expression
		  MW[100] =  CLSUM * MW[1] +                ; modechoice logsum
		             CDIST * MW[2] +                ; distance
		             CDISTSQ * (POW(MW[2],2)) +     ; distance sq
		             CDISTCUB * (POW(MW[2],3)) +    ; distance cube
		             CDISTLN * MW[114] + 						; log(distance)  
		             MW[113] + 											; log(sizeterm)  
		             KINTRAZ * MW[111] +            ; intrazonal        
		             MW[115] +                      ; calibration distance  
		             MW[116]                        ; Shadow Price 
		ENDJLOOP

  	; Destination choice model 
  	XCHOICE,  
  	ALTERNATIVES = All, 
  	DEMAND = personTrips[I],
  	UTILITIESMW = 100,
  	ODEMANDMW = 200,
  	DESTSPLIT= TOTAL All, INCLUDE=1-{Internal Zones},
  	STARTMW = 800 
    
; Report coefficient values to summary file and debug file;
    JLOOP
		; Debug destination choice
	  IF({DebugDC} = 1 && I = {SelOrigin} && J = {SelDest}) 
	  	PRINT PRINTO=1 CSV=F LIST ='DESTINTION CHOICE TRACE @PURP@','\n\n'
	  	PRINT PRINTO=1 CSV=F LIST =' Destination Choice Model Trace \n\nSelected Interchange for Tracing:    ',{SelOrigin}(4.0),'-',{SelDest}(4.0),'\n'
	  	PRINT PRINTO=1 CSV=F LIST ='\n PURPOSE -                   @PURP@  '
	  	PRINT PRINTO=1 CSV=F LIST ='\n Size Term is computed on the Destination '	  	      
	  	PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = household coefficient                    ', Coeff_HH          , ' * ' , ZI.1.HH[J]  
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Other + Office Emp coefficient           ', Coeff_OTH_OFF_EMP , ' * ' , ZI.1.EMP[J], ZI.1.RET[J] ,ZI.1.HTRET[J]   
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Office Emp coefficient                   ', Coeff_OFF_EMP     , ' * ' , ZI.1.OFF[J] 
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Other Emp coefficient                    ', Coeff_OTH_EMP     , ' * ' , ZI.1.EMP[J],  ZI.1.OFF[J], ZI.1.RET[J], ZI.1.HTRET[J] 
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Retail Emp coefficient                   ', Coeff_RET_EMP     , ' * ' , ZI.1.RET[J] , ZI.1.HTRET[J]
		  PRINT PRINTO=1 CSV=F LIST ='\n Capped distance (this is a value)  								 ', DISTCAP             
		  PRINT PRINTO=1 CSV=F LIST ='\n Logsum coefficient                                  ', CLSUM             , ' * ' , MW[1]   
		  PRINT PRINTO=1 CSV=F LIST ='\n distance coefficient                                ', CDIST             , ' * ' , MW[2]  
		  PRINT PRINTO=1 CSV=F LIST ='\n distance square coeffficient                        ', CDISTSQ           , ' * ' , POW(MW[2],2)    
		  PRINT PRINTO=1 CSV=F LIST ='\n distance cube coefficient                           ', CDISTCUB          , ' * ' , POW(MW[2],3)   
		  PRINT PRINTO=1 CSV=F LIST ='\n distance log coefficient                            ', CDISTLN           , ' * ' , MW[114] 		  
		  PRINT PRINTO=1 CSV=F LIST ='\n Intrazonal constant                                 ', KINTRAZ           , ' * ' , MW[111]  
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (0-1 Mile)            ', KDIST01           
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (1-2 Mile)            ', KDIST12            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (2-3 Mile)            ', KDIST23            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (3-4 Mile)            ', KDIST34            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (4-5 Mile)            ', KDIST45            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (5-6 Mile)            ', KDIST56            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (6-7 Mile)            ', KDIST67            
		  PRINT PRINTO=1 CSV=F LIST ='\n Applied  calibration constant                       ', MW[113]
      PRINT PRINTO=1 CSV=F LIST ='\n Size Term                                           ', MW[112] 
      PRINT PRINTO=1 CSV=F LIST ='\n Ln(Size Term)                                       ', MW[113]     
		  PRINT PRINTO=1 CSV=F LIST ='\n Computed Utility                                    ', MW[100]            	  
		  PRINT PRINTO=1 CSV=F LIST ='\n Total Productions in Origin                         ', personTrips[I]     			  
		  PRINT PRINTO=1 CSV=F LIST ='\n Trip Attractions                                    ', MW[200]            		  
   ENDIF
    
   ; Report total intrazonals 
    IF(I = J)  INTRAZONAL_sum = INTRAZONAL_sum + MW[200]
    IF (I = ZONES && J = ZONES) PRINT PRINTO=1 CSV=F LIST ='\n Intrazonal Sum            ', INTRAZONAL_sum 
 ENDJLOOP
    
ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_HBW_ShadowPrice.s"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Shadow Price'

FILEI ZDATI[1] = "{SCENARIO_DIR}\OUTPUT\HBW_shadowPrice.DBF"
FILEO RECO[1] = "{SCENARIO_DIR}\OUTPUT\HBW_shadowPrice.DBF",
 fields=Z,PROD1,ATTR1,SizeTerm,Shadow_price
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"

MW[1]=mi.1.1
MW[2]=mi.1.1.t
MW[3]=mi.1.2

RO.PROD1=ROWSUM(1)
RO.ATTR1=ROWSUM(2)
RO.Z=I
RO.SizeTerm = MW[3][I]
Ro.prev =  ZI.1.SHADOW_PRIC 

IF (RO.ATTR1 > 0 )
  RO.Shadow_price = Ro.prev + LOG(MW[3][I]/RO.ATTR1)
ENDIF

WRITE RECO=1
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*COPY {SCENARIO_DIR}\OUTPUT\HBW_shadowPrice.dbf {SCENARIO_DIR}\OUTPUT\HBW_shadowPrice_@ITERATION@.dbf



; End of PILOT Script

  ENDLOOP

  LOOP PURPOSE = 2, 4, 1

; PILOT Script

IF (PURPOSE=1) ; HBW PK
PURP='HBW'
MCLS_MAT = 'HBW'
PERIOD='PK'
PURPNO=1
MARKETS=1
isHBW=' '
noHBW=';'
isNHB=';'
noNHB=' '
PRINT LIST="Trip Distribution Loop Number = 1 of 4 HBW", printo=0

ELSEIF (PURPOSE=2) ; HBO 
PURP='HBO'
MCLS_MAT = 'HBO'
PERIOD='PK'
PURPNO=2
MARKETS=1
isHBW=';'
noHBW=' '
isNHB=';'
noNHB=' '
PRINT LIST="Trip Distribution Loop Number = 2 of 4 HBO ", printo=0

ELSEIF (PURPOSE=3) ; HBSH  
PURP='HBSH'
MCLS_MAT = 'HBO'
PERIOD='PK'
PURPNO=3
MARKETS=1
isHBW=';'
noHBW=' '
isNHB=';'
noNHB=' '
PRINT LIST="Trip Distribution Loop Number = 3 of 4 HBSH", printo=0

ELSEIF (PURPOSE=4) ; NHBW  
PURP='NHB'
MCLS_MAT = 'NHB'
PERIOD='PK'
PURPNO=4
MARKETS=1
isHBW=';'
noHBW=' '
isNHB=' '
noNHB=';'
PRINT LIST="Trip Distribution Loop Number = 4 of 4 NHB ", printo=0

ENDIF
; End of PILOT Script

; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_nonWork.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\tripDist_@PURP@.PRN" MSG='Apply Destination Choice Model'
FILEI ZDATI[3] = "{SCENARIO_DIR}\Output\NHBNR_PA_{year}.DBF"
FILEI ZDATI[2] = "{SCENARIO_DIR}\OUTPUT\HH_PROD.DBF"
FILEI ZDATI[1] = "{SCENARIO_DIR}\OUTPUT\se_classified_{year}{Alternative}.dbf"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\DESTCHOICE_PARAMETERS.DBF"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\@MCLS_MAT@_MCLS.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\op_Hwyskim.MAT"

FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT",
  MO=200, DEC=1*D, NAME=@PURP@
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\DESTCHOICE_DEBUG.RPT"
FILEO PRINTO[2] = "{SCENARIO_DIR}\OUTPUT\DESTCHOICE_SUMMARY.TXT"
FILEO PRINTO[3] = "{SCENARIO_DIR}\OUTPUT\@PURP@@PERIOD@_Zonal_Trips.csv"

		ZONES = {Total Zones}
		ARRAY personTrips = ZONES

		; READ IN MODEL PARAMETERS
		LOOKUP, NAME=COEFF, LOOKUP[1]=NVAR, RESULT=@PURP@, INTERPOLATE=N, LIST=Y, LOOKUPI=1
		Coeff_HH = COEFF(1,1)              ; SizeTerm = household coefficient
		Coeff_OTH_OFF_EMP = COEFF(1,2)     ; SizeTerm = Other + Office Emp coefficient
		Coeff_OFF_EMP = COEFF(1,3)         ; SizeTerm = Office Emp coefficient
		Coeff_OTH_EMP = COEFF(1,4)         ; SizeTerm = Other Emp coefficient
		Coeff_RET_EMP = COEFF(1,5)         ; SizeTerm = Retail Emp coefficient
		DISTCAP       = COEFF(1,6)         ; Capped distance (this is a value, not coefficient) ?
		CLSUM         = COEFF(1,7)         ; Logsum coefficient
		CDIST         = COEFF(1,8)         ; distance coefficient 
		CDISTSQ       = COEFF(1,9)         ; distance square coeffficient
		CDISTCUB      = COEFF(1,10)        ; distance cube coefficient
		CDISTLN       = COEFF(1,11)        ; distance log coefficient		
		KINTRAZ       = COEFF(1,12)        ; Intrazonal constant
		KDIST01       = COEFF(1,13)        ; distance calibration constant (0-1 Mile)
		KDIST12       = COEFF(1,14)        ; distance calibration constant (1-2 Mile)
		KDIST23       = COEFF(1,15)        ; distance calibration constant (2-3 Mile)
		KDIST34       = COEFF(1,16)        ; distance calibration constant (3-4 Mile)
		KDIST45       = COEFF(1,17)        ; distance calibration constant (4-5 Mile)
		KDIST56       = COEFF(1,18)        ; distance calibration constant (5-6 Mile)
		KDIST67       = COEFF(1,19)        ; distance calibration constant (6-7 Mile)

		; Mode choice logsums
		MW[1] = MI.1.1 
		
		; Hwy distance skim
		MW[2] = DISTCAP
    
    ; Distance calibration
    MW[113] = 0
		JLOOP
		
		  ; Read productions
		  @noNHB@ personTrips[I] = ZI.2.@PURP@P
      @isNHB@ personTrips[I] = ZI.2.NHBWP +  ZI.2.NHBOP + ZI.3.NHBNR_A
		  
		  ; Compute size term
		  MW[112] = Coeff_HH * ZI.1.HH[J] + Coeff_OFF_EMP * ZI.1.OFF[J] + Coeff_RET_EMP * (ZI.1.RET[J] + ZI.1.HTRET[J]) + Coeff_OTH_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.OFF[J]  - ZI.1.RET[J] - ZI.1.HTRET[J]) + Coeff_OTH_OFF_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.RET[J] - ZI.1.HTRET[J])
      
		  ; Log (sizeTerm)
		  IF(MW[112] > 0)   MW[113] = Ln(MW[112])  
		
		  ; Intrazonal boolean
		  IF(J == I) MW[111] = 1
		
		  ; Hwy distance
		  IF (MI.2.Distance < DISTCAP)  MW[2] = MI.2.Distance  
		  IF (MI.2.Distance > 0)  MW[114] = Ln(MI.2.Distance) 
		  		
		  ; Distance calibration constants          
		  IF(MW[2] > 0 && MW[2] <=1) MW[115] = KDIST01    ; Calibration constant for distance 0-1 bin
		  IF(MW[2] > 1 && MW[2] <=2) MW[115] = KDIST12    ; Calibration constant for distance 1-2 bin
		  IF(MW[2] > 2 && MW[2] <=3) MW[115] = KDIST23    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 3 && MW[2] <=4) MW[115] = KDIST34    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 4 && MW[2] <=5) MW[115] = KDIST45    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 5 && MW[2] <=6) MW[115] = KDIST56    ; Calibration constant for distance 2-5 bin
		  IF(MW[2] > 6 && MW[2] <=7) MW[115] = KDIST67    ; Calibration constant for distance 2-5 bin
		
		  ; Utility expression
		  MW[100] =  CLSUM * MW[1] +                ; modechoice logsum
		             CDIST * MW[2] +                ; distance
		             CDISTSQ * (POW(MW[2],2)) +     ; distance sq
		             CDISTCUB * (POW(MW[2],3)) +    ; distance cube
		             CDISTLN * MW[114] + 						; log(distance)  
		             MW[113] + 											; log(sizeterm)  
		             KINTRAZ * MW[111] +            ; intrazonal        
		             MW[115]                        ; calibration distance  
		   
		ENDJLOOP

  	; Destination choice model 
  	XCHOICE,  
  	ALTERNATIVES = All, 
  	DEMAND = personTrips[I],
  	UTILITIESMW = 100,
  	ODEMANDMW = 200,
  	DESTSPLIT= TOTAL All, INCLUDE=1-{Internal Zones},
  	STARTMW = 800 
    
; Report coefficient values to summary file and debug file;
    JLOOP
		; Debug destination choice
	  IF({DebugDC} = 1 && I = {SelOrigin} && J = {SelDest}) 
	  	PRINT PRINTO=1 CSV=F LIST ='DESTINTION CHOICE TRACE @PURP@','\n\n'
	  	PRINT PRINTO=1 CSV=F LIST =' Destination Choice Model Trace \n\nSelected Interchange for Tracing:    ',{SelOrigin}(4.0),'-',{SelDest}(4.0),'\n'
	  	PRINT PRINTO=1 CSV=F LIST ='\n PURPOSE -                   @PURP@  '
	  	PRINT PRINTO=1 CSV=F LIST ='\n Size Term is computed on the Destination '	  	      
	  	PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = household coefficient                    ', Coeff_HH          , ' * ' , ZI.1.HH[J]  
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Other + Office Emp coefficient           ', Coeff_OTH_OFF_EMP , ' * ' , ZI.1.EMP[J], ZI.1.RET[J] ,ZI.1.HTRET[J]   
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Office Emp coefficient                   ', Coeff_OFF_EMP     , ' * ' , ZI.1.OFF[J] 
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Other Emp coefficient                    ', Coeff_OTH_EMP     , ' * ' , ZI.1.EMP[J],  ZI.1.OFF[J], ZI.1.RET[J], ZI.1.HTRET[J] 
		  PRINT PRINTO=1 CSV=F LIST ='\n SizeTerm = Retail Emp coefficient                   ', Coeff_RET_EMP     , ' * ' , ZI.1.RET[J] , ZI.1.HTRET[J]
		  PRINT PRINTO=1 CSV=F LIST ='\n Capped distance (this is a value)  								 ', DISTCAP             
		  PRINT PRINTO=1 CSV=F LIST ='\n Logsum coefficient                                  ', CLSUM             , ' * ' , MW[1]   
		  PRINT PRINTO=1 CSV=F LIST ='\n distance coefficient                                ', CDIST             , ' * ' , MW[2]  
		  PRINT PRINTO=1 CSV=F LIST ='\n distance square coeffficient                        ', CDISTSQ           , ' * ' , POW(MW[2],2)    
		  PRINT PRINTO=1 CSV=F LIST ='\n distance cube coefficient                           ', CDISTCUB          , ' * ' , POW(MW[2],3)   
		  PRINT PRINTO=1 CSV=F LIST ='\n distance log coefficient                            ', CDISTLN           , ' * ' , MW[114] 		  
		  PRINT PRINTO=1 CSV=F LIST ='\n Intrazonal constant                                 ', KINTRAZ           , ' * ' , MW[111]  
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (0-1 Mile)            ', KDIST01           
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (1-2 Mile)            ', KDIST12            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (2-3 Mile)            ', KDIST23            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (3-4 Mile)            ', KDIST34            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (4-5 Mile)            ', KDIST45            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (5-6 Mile)            ', KDIST56            
		  PRINT PRINTO=1 CSV=F LIST ='\n distance calibration constant (6-7 Mile)            ', KDIST67            
		  PRINT PRINTO=1 CSV=F LIST ='\n Applied  calibration constant                       ', MW[113]
      PRINT PRINTO=1 CSV=F LIST ='\n Size Term                                           ', MW[112] 
      PRINT PRINTO=1 CSV=F LIST ='\n Ln(Size Term)                                       ', MW[113]     
		  PRINT PRINTO=1 CSV=F LIST ='\n Computed Utility                                    ', MW[100]            	  
		  PRINT PRINTO=1 CSV=F LIST ='\n Total Productions in Origin                         ', personTrips[I]     			  
		  PRINT PRINTO=1 CSV=F LIST ='\n Trip Attractions                                    ', MW[200]            		  
   ENDIF
    
   ; Report total intrazonals 
    IF(I = J)  INTRAZONAL_sum = INTRAZONAL_sum + MW[200]
    IF (I = ZONES && J = ZONES) PRINT PRINTO=1 CSV=F LIST ='\n Intrazonal Sum            ', INTRAZONAL_sum 
 ENDJLOOP
    
ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_nonWork_TLFD.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\non-work_tlfd.PRN" MSG='Non-Work Trip Length Frequency'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\@PURP@_TDLF.dbf",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\OP_Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\@PURP@_TDLF.PRN"

             MW[1]=MI.1.@PURP@
             MW[2]=MI.2.Distance
             MW[3]=MI.2.Time
             gps=22-1
             Array trips=22
             
             ; Distance
             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[2]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,22
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=2 VALUEMW=1 RANGE=0-100-1 

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_nonWork_TLFD_Time.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\non-work_ttfd.PRN" MSG='Non-Work Trip Time Frequency'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\@PURP@_time_TDLF.dbf",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\OP_Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\@PURP@_time_TDLF.PRN"

             MW[1]=MI.1.@PURP@
             MW[2]=MI.2.Time
             gps=26-1
             Array trips=36
             
             ; Time
             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[2]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,36
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=2 VALUEMW=1 RANGE=0-100-1 

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_nonWork_D2DFlow.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\non-work.d2d_flowsPRN" MSG='District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_@PURP@.MAT",
 MO = 1, NAME = @PURP@

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 12, MISSINGZI=M, MISSINGZO=M
ENDRUN


  ENDLOOP

; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_work_TLFD.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\work_tlfd_msg.PRN" MSG='Work Trip Length Frequency'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\HBW_TDLF.dbf",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\pk_Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\LOGS\work_tlfd.PRN"

             MW[1]=MI.1.HBW
             MW[2]=MI.2.Distance
             MW[3]=MI.2.Time
             gps=22-1
             Array trips=22
             
             ; Distance
             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[2]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,22
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=2 VALUEMW=1 RANGE=0-100-1 

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_work_TLFD_Time.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\work_ttfd_msg.PRN" MSG='Work Trip Time Frequency'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\HBW_TravelTime_TDLF.dbf",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\pk_Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\LOGS\work_ttfd.PRN"

             MW[1]=MI.1.HBW
             MW[2]=MI.2.Time
             gps=36-1
             Array trips=36             
             ; Time
             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[2]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,36
                ro.LOW = group-1
                ro.MID = group-0.5
                ro.HIGH= group
                ro.TRIPS=trips[group]
                write reco=1
                PRINT PRINTO=1 CSV=T  LIST= ro.HIGH,ro.MID,ro.LOW,ro.TRIPS                                       
               ENDLOOP
             ENDIF
             FREQUENCY BASEMW=2 VALUEMW=1 RANGE=0-100-1 

ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\DC_work_D2DFlow.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\work_d2d_flows.PRN" MSG='HBW District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_HBW.MAT",
 MO = 1, NAME = HBW

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 12, MISSINGZI=M, MISSINGZO=M
ENDRUN


; Script for program MATRIX in file "C:\projects\rvtpo\Cube\MC_Merge_HBO_HBSH.s"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='HBO + HBSH'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBO_HBSH.MAT",
 MO = 1, NAME = HBO_HBSH
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\Dest_HBSH.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBO.MAT"

MW[1] = MI.1.1 + MI.2.1
        
ENDRUN


  LOOP PURPOSE = 1, 4, 1

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
IF (PURPOSE=1) ; HBW Purpose
PURP='HBW'
PURPNAME = 'HBW'
PURPNO=3
PRK='LONGPARK'

ELSEIF (PURPOSE=2) ; HBO Purpose
PURP='HBO'
PURPNAME = 'HBO_HBSH'
PURPNO=4
PRK='LONGPARK'

ELSEIF (PURPOSE=3) ; NHB Purpose
PURP='NHB'
PURPNAME='NHB'
PURPNO=5
PRK='LONGPARK'

ELSEIF (PURPOSE=4) ; SCH Purpose
PURP='HBSC'
PURPNAME='HBSC'
PURPNO=6
PRK='LONGPARK'
ENDIF

; End of PILOT Script

; Script for program MATRIX in file "C:\projects\rvtpo\Cube\ModeChoiceModel.s"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\@PURP@_MCTRIPS.MAT",
 MO = 21-25, NAME = DA, SR, WLB, PMB, NOM
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\TrnWalkPercent.dbf"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURPNAME@.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\@PURP@_MCPROB.MAT"

        MW[1] = MI.2.1
        FILLMW MW[11] = MI.1.1(10)
			  
			  MW[2] = MW[1] * (ZI.1.PCWPROD[I] * 0.01) * (ZI.1.PCWATTR[J] * 0.01)      ; Can Walk
        MW[3] = MW[1] - MW[2]                                                    ; No Trn Access
			  
			  MW[21] = MW[11] * MW[2] +  MW[16] * MW[3] ; DA trips
			  MW[22] = MW[12] * MW[2] +  MW[17] * MW[3] ; SR trips
			  MW[23] = MW[13] * MW[2] +  MW[18] * MW[3] ; LB trips
			  MW[24] = MW[14] * MW[2] +  MW[19] * MW[3] ; PM trips
			  MW[25] = MW[15] * MW[2] +  MW[20] * MW[3] ; NM trips
        
        ; Aggregate all trips        
        JLOOP

           EDA = EDA + MW[21]  
           ESR = ESR + MW[22]  
           ELB = ELB + MW[23]  
           EPM = EPM + MW[24]  
           ENM = ENM + MW[25]		
           
           TRN    = ELB + EPM 
           AUT    = EDA + ESR 
           TOT    = AUT + TRN + ENM
           
           IF(I==264 && J==264)
              print,list= "EST_EDA"  ," = ",EDA , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F
              print,list= "EST_ESR"  ," = ",ESR , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F
              print,list= "EST_ELB"  ," = ",ELB , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F
              print,list= "EST_EPM"  ," = ",EPM , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F
              print,list= "EST_ENM"  ," = ",ENM , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F
              print,list= "EST_TRN"  ," = ",TRN , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F
              print,list= "EST_AUT"  ," = ",AUT , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F
              print,list= "EST_TOT"  ," = ",TOT , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\@PURP@ESTIMATED.DAT",
 append = F            
           ENDIF         
        ENDJLOOP
        
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


; End of PILOT Script

  ENDLOOP

; Script for program MATRIX in file "C:\projects\rvtpo\CUBE\MCMAT00A.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='MC Trips by Mode and Purpose'
FILEI MATI[4] = "{SCENARIO_DIR}\OUTPUT\NHB_MCTRIPS.MAT"
FILEI MATI[3] = "{SCENARIO_DIR}\OUTPUT\HBSC_MCTRIPS.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\HBO_MCTRIPS.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\HBW_MCTRIPS.MAT"


FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\All_MCTRIPS.MAT",
MO = 1-20, NAME = HBW_DA, HBW_SR, HBW_WLB, HBW_PMB, HBW_NOM,
 HBO_DA, HBO_SR, HBO_WLB, HBO_PMB, HBO_NOM,
 HBSC_DA, HBSC_SR, HBSC_WLB, HBSC_PMB, HBSC_NOM,
 NHB_DA, NHB_SR, NHB_WLB, NHB_PMB, NHB_NOM
 
FILLMW MW[1] = MI.1.1(5) 
FILLMW MW[6] = MI.2.1(5) 
FILLMW MW[11] = MI.3.1(5) 
FILLMW MW[16] = MI.4.1(5) 
 
ENDRUN


  LOOP PER = 1, 4, 1

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (PER=1) ; AM
PERIOD_COL=3
PERIOD_NAME = 'AM'

ELSEIF (PER=2) ; MD
PERIOD_COL=4
PERIOD_NAME = 'MD'

ELSEIF (PER=3) ; PM
PERIOD_COL=6
PERIOD_NAME = 'PM'

ELSEIF (PER=4) ; NT 
PERIOD_COL=5
PERIOD_NAME = 'NT'
ENDIF
; End of PILOT Script

; Script for program MATRIX in file "C:\projects\rvtpo\Cube\TOD_Model.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\Logs\TOD_Model_@PERIOD_NAME@.PRN" MSG='Convert PA Trips to OD Trips'

FILEI MATI[7] = "{SCENARIO_DIR}\Output\CV_{Year}_@PERIOD_NAME@.MAT"
FILEI MATI[6] = "{SCENARIO_DIR}\Output\EE_{year}_@PERIOD_NAME@.MAT"
FILEI MATI[5] = "{SCENARIO_DIR}\Output\IEEI_{Year}_@PERIOD_NAME@.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\NHB_MCTRIPS.MAT"
FILEI MATI[4] = "{SCENARIO_DIR}\OUTPUT\HBSC_MCTRIPS.MAT"
FILEI MATI[3] = "{SCENARIO_DIR}\OUTPUT\HBO_MCTRIPS.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\HBW_MCTRIPS.MAT"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\TOD_FACS.DBF"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\ODAUTO_@PERIOD_NAME@.MAT",
MO = 1,3-6 NAME = DA, SR, IEEI, CV, EE
PARAMETERS  ZONES={Total Zones}

; Read alternative specific Constants
LOOKUP, NAME=TOD_FACS, LOOKUP[1]=1, RESULT=@PERIOD_COL@, INTERPOLATE=N, , LIST=Y, LOOKUPI=1

HBW_PA  = TOD_FACS(1,1)       
HBW_AP  = TOD_FACS(1,2)     
HBO_PA  = TOD_FACS(1,3)     
HBO_AP  = TOD_FACS(1,4)     
HBSC_PA = TOD_FACS(1,5) 
HBSC_AP = TOD_FACS(1,6) 
NHB_PA  = TOD_FACS(1,7)    
NHB_AP  = TOD_FACS(1,8)  

;  CONVERT P/A MATRIX TO O/D

; Drive Alone trips
MW[1]= MI.1.1 * NHB_PA +  MI.1.1.T * NHB_AP +
       MI.2.1 * HBW_PA +  MI.2.1.T * HBW_AP +
       MI.3.1 * HBO_PA +  MI.3.1.T * HBO_AP +
       MI.4.1 * HBSC_PA +  MI.4.1.T * HBSC_AP

; Share ride trips
MW[2]= MI.1.2 * NHB_PA +  MI.1.2.T * NHB_AP +
       MI.2.2 * HBW_PA +  MI.2.2.T * HBW_AP +
       MI.3.2 * HBO_PA +  MI.3.2.T * HBO_AP +
       MI.4.2 * HBSC_PA +  MI.4.2.T * HBSC_AP
       
MW[3] = MW[2]/2.19 ; shareride vehicle trips

MW[4] = MI.5.1 ; IEEI trips

MW[5] = MI.7.1 + MI.7.2 + MI.7.3 ;CV trips

MW[6] = MI.6.1 ; EE trips

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


; End of PILOT Script

  ENDLOOP

; Script for program MATRIX in file "C:\projects\rvtpo\CUBE\TRMAT00G.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\MC_Transit_Trips.PRN" MSG='Transit Trips'
FILEO MATO[2] = "{SCENARIO_DIR}\Output\OP_Transit.MAT",
MO = 3-4, NAME = WBUS, WPREM

FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\NHB_MCTRIPS.MAT"
FILEI MATI[4] = "{SCENARIO_DIR}\OUTPUT\HBSC_MCTRIPS.MAT"
FILEI MATI[3] = "{SCENARIO_DIR}\OUTPUT\HBO_MCTRIPS.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\HBW_MCTRIPS.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\PK_Transit.MAT",
MO = 1-2, NAME = WBUS, WPREM

; Write out HBW transit trips as Peak Trn trips
MW[1] =  MI.2.3 
MW[2] =  MI.2.4 

; Write out Off-Peak Trn trips
MW[3] = MI.1.3 + MI.3.3 + MI.4.3
MW[4] = MI.1.4 + MI.3.4 + MI.4.4

ENDRUN


  LOOP PER = 1, 4, 1

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (PER=1) ; AM
PERIOD_COL=3
PERIOD_NAME = 'AM'

ELSEIF (PER=2) ; MD
PERIOD_COL=4
PERIOD_NAME = 'MD'

ELSEIF (PER=3) ; PM
PERIOD_COL=5
PERIOD_NAME = 'PM'

ELSEIF (PER=4) ; NT 
PERIOD_COL=6
PERIOD_NAME = 'NT'

ENDIF


; End of PILOT Script

; Script for program HIGHWAY in file "C:\projects\rvtpo\Cube\HighwayAssign_Preload.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="C:\projects\rvtpo\CUBE\ASHWY00A.PRN" MSG='Preload External Trips'
FILEI TURNPENI = "{SCENARIO_DIR}\Input\TurnPenalties.pen"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\SL_Preloaded_@PERIOD_NAME@.MAT",
MO=2, NAME=SL_EE
FILEI NETI = "{SCENARIO_DIR}\Output\RVTPOBase{Year}{Alternative}.NET"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\ODAUTO_@PERIOD_NAME@.MAT"
FILEO PATHO[1] = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.PTH"
FILEO NETO = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.NET",
      DEC = 0

;Set run PARAMETERS and Controls
PARAMETERS ZONES={Total ZONES}, MAXITERS=1, COMBINE=EQUI, GAP= 0.0, RELATIVEGAP = 0.00001

PHASE=LINKREAD

   T0 = 60* (LI.DISTANCE/LI.FFSPEED)
   C  = LI.CAPE_@PERIOD_NAME@
   LW.COSTa = T0 + 0.25*LI.DISTANCE
 
ENDPHASE

PHASE=ILOOP
  ; Assign EE trips 
  PATHLOAD PATH=LW.COSTa,  MW[1] = MI.1.5, VOL[1] = MW[1], 
     MW[2] = MI.1.5, SELECTLINK=({SelectLink}), VOL[2]=MW[2] 
                                                                         
ENDPHASE


ENDRUN


; Script for program HIGHWAY in file "C:\projects\rvtpo\Cube\HighwayAssign.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\Output\Logs\@PERIOD_NAME@.PRN" MSG='Load Final Trips onto Network'
FILEI TURNPENI = "{SCENARIO_DIR}\Input\TurnPenalties.pen"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\SL_Loaded_@PERIOD_NAME@.MAT",
MO=5-8, NAME=SL_DA,SL_SR,SL_IEEI, SL_CV
FILEI NETI = "{SCENARIO_DIR}\Output\PRELOADED_@PERIOD_NAME@.NET"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\ODAUTO_@PERIOD_NAME@.MAT"
FILEO PATHO[1] = "{SCENARIO_DIR}\Output\LOADED_@PERIOD_NAME@.PTH"
FILEO NETO = "{SCENARIO_DIR}\Output\LOADED_@PERIOD_NAME@.NET",
      DEC = 0

;Set run PARAMETERS and Controls
PARAMETERS ZONES={Total ZONES}, MAXITERS=500, COMBINE=EQUI, GAP= 0.0, RELATIVEGAP = 0.00001

PHASE=LINKREAD
    LW.EEVOL = LI.V_1 
    
   T0 = 60* (LI.DISTANCE/LI.FFSPEED)
  ; T0 = 60* (LI.DISTANCE/LI.POST_SPEED)
  C  = LI.CAPE_@PERIOD_NAME@ 

  LW.COSTa = T0 + 0.25*LI.DISTANCE
  LW.COSTb = T0 + 0.25*LI.DISTANCE
  LW.COSTc = T0 + 0.25*LI.DISTANCE
  LW.COSTd = T0 + 0.25*LI.DISTANCE
  
/*
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
*/

; Group facility types
  IF(LI.FACTYPE=1,2,9,10)    LINKCLASS=1 ; Freeway
  IF(LI.FACTYPE=3,4)    LINKCLASS=2 ; Major Arterial
  IF(LI.FACTYPE=5)      LINKCLASS=3 ; Minor Arterial
  IF(LI.FACTYPE=6,7)    LINKCLASS=4 ; Collector
  IF(LI.FACTYPE=8)      LINKCLASS=5 ; Local
  IF(LI.FACTYPE>10)     LINKCLASS=6 ; Connectors

ENDPHASE

PHASE=ILOOP
/*
  PATHLOAD VOL[1] = MI.1.1,  PATH=LW.COSTa  
  PATHLOAD VOL[2] = MI.1.2,  PATH=LW.COSTb 
  PATHLOAD VOL[3] = MI.1.3,  PATH=LW.COSTc  
  PATHLOAD VOL[4] = MI.1.4,  PATH=LW.COSTd 
  */
  PATHLOAD PATH=LW.COSTa , MW[1] = MI.1.1, VOL[1] = MW[1],   
      MW[5] = MI.1.1, SELECTLINK=({SelectLink}), VOL[5]=MW[5] 
  PATHLOAD PATH=LW.COSTb , MW[2] = MI.1.2, VOL[2] = MW[2],
     ; MW[6] = MI.1.2, SELECTLINK=(L= 4451-4424), VOL[6]=MW[6]      
  MW[6] = MI.1.2, SELECTLINK=({SelectLink}), VOL[6]=MW[6]    
  PATHLOAD PATH=LW.COSTc , MW[3] = MI.1.3, VOL[3] = MW[3] ,
      MW[7] = MI.1.3, SELECTLINK=({SelectLink}), VOL[7]=MW[7]  
  PATHLOAD PATH=LW.COSTd , MW[4] = MI.1.4, VOL[4] = MW[4], 
      MW[8] = MI.1.4, SELECTLINK=({SelectLink}), VOL[8]=MW[8]    
  
ENDPHASE

PHASE=ADJUST

function {
    V=VOL[1]+VOL[2]+VOL[3]+VOL[4]+  LW.EEVOL ; Add preloaded EE Volumes here
   ; V=VOL[1]+VOL[2]+VOL[4]
     ; TC[1] = Min(T0 * (1 + 0.83*(V/C)^5.5), T0*100)    ; Freeway     
     ; TC[2] = Min(T0 * (1 + 0.83*(V/C)^3.7), T0*100)    ; Major Arterial  
    TC[1] = Min(T0 * (1 + 0.65*(V/C)^4.5), T0*100)    ; Freeway        
    TC[2] = Min(T0 * (1 + 0.65*(V/C)^4.0), T0*100)    ; Major Arterial         
    TC[3] = Min(T0 * (1 + 0.83*(V/C)^2.8), T0*100)    ; Minor Arterial    
    TC[4] = Min(T0 * (1 + 0.2*(V/C)^4), T0*100)       ; Collector
    TC[5] = Min(T0 * (1 + 0.6*(V/C)^5.5), T0*100)     ; Local
    TC[6] = T0                                        ; Connectors                       
    }

  LW.COSTa=TIME + 0.25*LI.DISTANCE
  LW.COSTb=TIME + 0.25*LI.DISTANCE
  LW.COSTc=TIME + 0.25*LI.DISTANCE
  LW.COSTd=TIME + 0.25*LI.DISTANCE
  
ENDPHASE
ENDRUN


  ENDLOOP

; Script for program NETWORK in file "C:\projects\rvtpo\Cube\HighwayAssign_MergeNetworks.s"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\Merge_Hwy_Assignments.PRN"
FILEO NETO = "{SCENARIO_DIR}\Output\LOADED_{Year}{Alternative}.NET",
 EXCLUDE = V_1, VC_1, V1_1, V2_1, V3_1, V4_1, VT_1, V1T_1, V2T_1, V3T_1, V4T_1, TIME_1 ,CSPD_1 ,VDT_1, VDT_2 ,VHT_1 ,TIME_2 ,VC_2 ,CSPD_2 ,CDT_2 ,VHT_2 ,V_2 ,V1_2 ,V2_2 ,V3_2 ,V4_2 ,V5_2 ,V6_2 ,V7_2 ,V8_2 ,VT_2 ,V1T_2 ,V2T_2 ,V3T_2 ,V4T_2 ,V5T_2 ,V6T_2 ,V7T_2 ,V8T_2

FILEI LINKI[4] = "{SCENARIO_DIR}\Output\LOADED_NT.NET"
FILEI LINKI[3] = "{SCENARIO_DIR}\Output\LOADED_PM.NET"
FILEI LINKI[2] = "{SCENARIO_DIR}\Output\LOADED_MD.NET"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\LOADED_AM.NET"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\Hwy_eval_period.csv"
 
; =========================================================
; LINKMERGE PHASE
; =========================================================
PHASE=LINKMERGE  
; Total Volume
AM_Vol=li.1.V_2 
MD_Vol=li.2.V_2
PM_Vol=li.3.V_2 
NT_Vol=li.4.V_2 
Total_Vol = AM_Vol + MD_Vol + PM_Vol + NT_Vol

; Drive Alone
AM_DA=li.1.V1_2 
MD_DA=li.2.V1_2 
PM_DA=li.3.V1_2 
NT_DA=li.4.V1_2 
TOTAL_DA = AM_DA + MD_DA + PM_DA + NT_DA

; ShareRide 2+
AM_SR=li.1.V2_2 
MD_SR=li.2.V2_2 
PM_SR=li.3.V2_2 
NT_SR=li.4.V2_2 
TOTAL_SR = AM_SR + MD_SR + PM_SR + NT_SR

; IEEI
AM_IEEI=li.1.V3_2 
MD_IEEI=li.2.V3_2 
PM_IEEI=li.3.V3_2 
NT_IEEI=li.4.V3_2 
TOTAL_IEEI = AM_IEEI + MD_IEEI + PM_IEEI + NT_IEEI

; Commercial Vehicles
AM_CV=li.1.V4_2 
MD_CV=li.2.V4_2 
PM_CV=li.3.V4_2 
NT_CV=li.4.V4_2 
TOTAL_CV = AM_CV + MD_CV + PM_CV + NT_CV

; EE
AM_EX=li.1.V1_1 
MD_EX=li.2.V1_1 
PM_EX=li.3.V1_1 
NT_EX=li.4.V1_1 
TOTAL_EX = AM_EX + MD_EX + PM_EX + NT_EX

;Sum period specific loaded attributes to all period (24 hour)...
; Congested Speed by Time Period
AM_CongSpeed=li.1.CSPD_2 
MD_CongSpeed=li.2.CSPD_2 
PM_CongSpeed=li.3.CSPD_2 
NT_CongSpeed=li.4.CSPD_2 

; Congested Time by Time Period
AM_Time=li.1.TIME_2 
MD_Time=li.2.TIME_2 
PM_Time=li.3.TIME_2 
NT_Time=li.4.TIME_2 

; Vehicle Hours of Delay (Minutes)
AM_VDT=li.1.VDT_2 
MD_VDT=li.2.VDT_2 
PM_VDT=li.3.VDT_2 
NT_VDT=li.4.VDT_2 
TOTAL_VDT = AM_VDT + MD_VDT + PM_VDT + NT_VDT

; Vehcile Hours of Travel (Miles)
AM_VHT=li.1.VHT_2                               
MD_VHT=li.2.VHT_2                               
PM_VHT=li.3.VHT_2                               
NT_VHT=li.4.VHT_2                               
TOTAL_VHT = AM_VHT + MD_VHT + PM_VHT + NT_VHT   

; Volume to Capacity Ratio
AM_VC=li.1.VC_2 
MD_VC=li.2.VC_2 
PM_VC=li.3.VC_2 
NT_VC=li.4.VC_2

IF (Total_Vol > 0)
  TOTAL_VC = AM_VC * (AM_Vol/Total_Vol) + MD_VC * (MD_Vol/Total_Vol)+ PM_VC * (PM_Vol/Total_Vol) + NT_VC * (NT_Vol/Total_Vol) 
ELSE
  TOTAL_VC = 0
ENDIF

; Select Link Volumes
sl_DA=li.1.V5_2 +li.2.V5_2 +li.3.V5_2 +li.4.V5_2  
sl_SR=li.1.V6_2 +li.2.V6_2 +li.3.V6_2 +li.4.V6_2  
sl_IEEI=li.1.V7_2 +li.2.V7_2 +li.3.V7_2 +li.4.V7_2  
sl_CV=li.1.V8_2 +li.2.V8_2 +li.3.V8_2 +li.4.V8_2  
sl_EE=li.1.V2_1 +li.2.V2_1 +li.3.V2_1 +li.4.V2_1  
sl_tot=sl_DA+ sl_SR +  sl_IEEI + sl_CV + sl_EE

; write out peak and off-peak congested time to use in feedback
SPEED_PK_CNG =  li.1.CSPD_2  ; AM Congested Speed
TIME_PK_CNG = li.1.TIME_2    ; AM Congested Time
SPEED_OP_CNG =  li.2.CSPD_2  ; MD Congested Speed
TIME_OP_CNG = li.2.TIME_2    ; MD Congested Time

; Group facility types
oft=LI.1.FACTYPE                                 ; Facility Type
if (oft = 1 | oft =2 | oft =9 | oft = 10) ft = 1 ; Freeway       
if (oft = 3 | oft =4)                     ft = 2 ; Major Arterial
if (oft = 5)                              ft = 3 ; Minor Arterial
if (oft = 6 | oft = 7 | oft = 8)          ft = 4 ; Collector + Local         
if (oft = 10)                             ft = 5 ; Connectors   

; Write a header file for links
 if (A=1) print CSV=T,list='ScreenLine', 'A','B','Area Type','Fac Type','Fac Type Group', 'FFSPEED', 'Count' ,'Volume','Distance', 'AM_Vol', 'MD_Vol',  'PM_Vol', 'NT_Vol',  'AM_VMT', 'MD_VMT' , 'PM_VMT' , 'NT_VMT',   
 'AM_VHT', 'MD_VHT' , 'PM_VHT' , 'NT_VHT', 'AM_Speed', 'MD_Speed' , 'PM_Speed' , 'NT_Speed' printo=1 
 
IF (Li.1.AAWDT>0)
 ; Write out links with counts
 print CSV=T list = LI.1.SCREENLN , LI.1.A, LI.1.B, LI.1.ATYPE, LI.1.FACTYPE, FT,  FFSPEED, LI.1.AAWDT, TOTAL_VOL, LI.1.DISTANCE,  AM_Vol, MD_Vol,  PM_Vol, NT_Vol, li.1.VDT_2, li.2.VDT_2, li.3.VDT_2 , li.4.VDT_2, li.1.VHT_2,  li.2.VHT_2,  li.3.VHT_2,  li.4.VHT_2, li.1.CSPD_2, li.2.CSPD_2, li.3.CSPD_2, li.4.CSPD_2 printo=1

 ENDIF
 
 
ENDPROCESS
ENDRUN


; Script for program NETWORK in file "C:\projects\rvtpo\Cube\HighwayAssign_Evaluate.s"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\Hwy_eval.PRN"
FILEO PRINTO[2] = "{SCENARIO_DIR}\Output\Hwy_eval_links.csv"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\LOADED_{Year}{Alternative}.NET"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\Hwy_eval.csv"

; =========================================================
; LINKMERGE PHASE
; =========================================================
PHASE=LINKMERGE

; Netwok attribute information
LNS=LI.1.LANEs
TOTAL_VOL=ROUND(LI.1.TOTAL_VOL)     ; Total Volume
oft=LI.1.FACTYPE                     ; Facility Type
atg=LI.1.ATYPE                      ; Area Type

ftg=INT(LI.1.FACTYPE/10)
sl=LI.1.SCREENLN              ;MPO Scrreenline/Cutline

count=LI.1.AAWDT               ; Count
_countsum=_countsum+count      ;  
if ((count>0)&(sl=0)) sl=98    ; Counts with MPO Screenline/Cutline of ZERO are reported as SL/CL of 98

_distmile=DISTANCE                 ; distance in mile   
_ctimehr=AM_TIME/60                 ; Congestime time in hour
VOLVMT=ROUND(TOTAL_VOL*_distmile)  ; VMT-Volume
VOLVHT=ROUND(TOTAL_VOL*_ctimehr)   ; VHT-Volume
CNTVMT=ROUND(count*_distmile)      ; VMT-Count
CNTVHT=ROUND(count*_ctimehr)       ; VHT-Count

; Group facility types
if (oft = 1 | oft =2 | oft =9 | oft = 10) ft = 1 ; Freeway       
if (oft = 3 | oft =4)                     ft = 2 ; Major Arterial
if (oft = 5)                              ft = 3 ; Minor Arterial
if (oft = 6 | oft = 7 | oft = 8)          ft = 4 ; Collector + Local         
if (oft = 10)                             ft = 5 ; Connectors    
 
; initialize arrays and variables
   ARRAY _err=10, _cns=10, _cnt=10, _RGP=10, _vols=10
   ARRAY FT_ERR=100, FT_CNS=100, FT_CNT=100, FT_VOLS=100
   
   ARRAY _lnkbyft=100, _volbyft=100, _cntbyft=100
   ARRAY _volbyftg=100, _volbyatg=100, _cntbyftg=100, _cntbyatg=100
   ARRAY _lnkbyftg=100, _lnkbyatg=100
   ARRAY _volbyLNS=100, _cntbyLNS=100, _lnkbyLNS=100
   ARRAY _volbysl=100, _cntbysl=100, _lnkbysl=100
   ARRAY _volbysl2=100, _cntbysl2=100, _lnkbysl2=100
   ARRAY _volbycord=1000, _cntbycord=1000, _lnkbycord=1000
   ARRAY _volbyscord=5000, _cntbyscord=5000, _lnkbyscord=5000
   ARRAY _volbycnty=100, _cntbycnty=100, _lnkbycnty=100

   ARRAY _vmtvbyft=100, _vmtcbyft=100
   ARRAY _vmtvbyftg=100, _vmtcbyftg=100
   ARRAY _vmtvbyatg=100, _vmtcbyatg=100
   ARRAY _vmtvbyLNS=100, _vmtcbyLNS=100
   ARRAY _vmtvbysl=100, _vmtcbysl=100
   ARRAY _vmtvbysl2=100, _vmtcbysl2=100
   ARRAY _vmtvbycnty=100, _vmtcbycnty=100  
   ARRAY _vmtvbycord=1000, _vmtcbycord=1000
   ARRAY _vmtvbyscord=5000, _vmtcbyscord=5000

   ARRAY _vhtvbyft=100, _vhtcbyft=100
   ARRAY _vhtvbyftg=100, _vhtcbyftg=100
   ARRAY _vhtvbyatg=100, _vhtcbyatg=100
   ARRAY _vhtvbyLNS=100, _vhtcbyLNS=100
   ARRAY _vhtvbysl=100, _vhtcbysl=100
   ARRAY _vhtvbysl2=100, _vhtcbysl2=100
   ARRAY _vhtvbycnty=100, _vhtcbycnty=100  
   ARRAY _vhtvbycord=1000, _vhtcbycord=1000
   ARRAY _vhtvbyscord=5000, _vhtcbyscord=5000

   _RGP[1]=1, _RGP[2]=5000, _RGP[3]=10000, _RGP[4]=15000, _RGP[5]=20000, _RGP[6]=30000, _RGP[7]=50000,
   _RGP[8]=60000, _RGP[9]=1000000
   
   IF (A=1)
     LOOP _iter=1,10
         _err[_iter]=0,_cnt[_iter]=0,_cns[_iter]=0,_vols[_iter]=0
     ENDLOOP

     LOOP _iter=1,100
           FT_ERR[_iter]=0, FT_CNS[_iter]=0, FT_CNT[_iter]=0, FT_VOLS[_iter]=0
           _volbyft[_iter]=0, _cntbyft[_iter]=0, _lnkbyft[_iter]=0
           _volbyftg[_iter]=0, _cntbyftg[_iter]=0, _lnkbyftg[_iter]=0
           _volbyatg[_iter]=0, _cntbyatg[_iter]=0, _lnkbyatg[_iter]=0
           _volbyLNS[_iter]=0, _cntbyLNS[_iter]=0, _lnkbyLNS[_iter]=0
           _volbysl[_iter]=0, _cntbysl[_iter]=0, _lnkbysl[_iter]=0
           _volbysl2[_iter]=0, _cntbysl2[_iter]=0, _lnkbysl2[_iter]=0
           _volbycnty[_iter]=0, _cntbycnty[_iter]=0, _lnkbycnty[_iter]=0

           _vmtvbyft[_iter]=0, _vmtcbyft[_iter]=0
           _vmtvbyftg[_iter]=0, _vmtcbyftg[_iter]=0
           _vmtvbyatg[_iter]=0, _vmtcbyatg[_iter]=0
           _vmtvbyLNS[_iter]=0, _vmtcbyLNS[_iter]=0
           _vmtvbysl[_iter]=0, _vmtcbysl[_iter]=0
           _vmtvbysl2[_iter]=0, _vmtcbysl2[_iter]=0
           _vmtvbycnty[_iter]=0, _vmtcbycnty[_iter]=0
           _vhtvbyft[_iter]=0, _vhtcbyft[_iter]=0
           _vhtvbyftg[_iter]=0, _vhtcbyftg[_iter]=0
           _vhtvbyatg[_iter]=0, _vhtcbyatg[_iter]=0
           _vhtvbyLNS[_iter]=0, _vhtcbyLNS[_iter]=0
           _vhtvbysl[_iter]=0, _vhtcbysl[_iter]=0
           _vhtvbysl2[_iter]=0, _vhtcbysl2[_iter]=0
           _vhtvbycnty[_iter]=0, _vhtcbycnty[_iter]=0
     ENDLOOP


     LOOP _iter=1,1000
           _volbycord[_iter]=0, _cntbycord[_iter]=0, _lnkbycord[_iter]=0

           _vmtvbycord[_iter]=0, _vmtcbycord[_iter]=0
           _vhtvbycord[_iter]=0, _vhtcbycord[_iter]=0
     ENDLOOP

     LOOP _iter=1,5000
         _volbyscord[_iter]=0, _cntbyscord[_iter]=0, _lnkbyscord[_iter]=0

         _vmtvbyscord[_iter]=0, _vmtcbyscord[_iter]=0
         _vhtvbyscord[_iter]=0, _vhtcbyscord[_iter]=0
     ENDLOOP

   ENDIF


; calculate and compartmentalize
   IF (COUNT>0) VOLCNT=TOTAL_VOL/COUNT, _TVOL=TOTAL_VOL, NETDIFF=TOTAL_VOL-COUNT, ABSDIFF=ABS(NETDIFF), ERRORSQ=NETDIFF^2, PCTDIFF=100*NETDIFF/COUNT, _group=1
   IF (COUNT>  5000) _group=2
   IF (COUNT> 10000) _group=3
   IF (COUNT> 15000) _group=4
   IF (COUNT> 20000) _group=5
   IF (COUNT> 30000) _group=6
   IF (COUNT> 50000) _group=7
   IF (COUNT> 60000) _group=8
   
   IF (COUNT>0)
     _ERR[_group]=ERRORSQ+_ERR[_group], _CNS[_group] = COUNT+_CNS[_group], _cnt[_group]= _cnt[_group]+1, _VOLS[_group]=_TVOL+_VOLS[_group]
     _ERR[9]=ERRORSQ+_ERR[9], _CNS[9]=COUNT+_CNS[9], _CNT[9]=_CNT[9]+1, _VOLS[9]=_TVOL+_VOLS[9]
     
     FT_ERR[ft]=ERRORSQ+ FT_ERR[ft], FT_CNS[ft]=COUNT+FT_CNS[ft], FT_CNT[ft]=FT_CNT[ft]+1, FT_VOLS[ft]=_TVOL+FT_VOLS[ft]
     FT_ERR[100]=ERRORSQ+FT_ERR[100], FT_CNS[100]=COUNT+FT_CNS[100], FT_CNT[100]=FT_CNT[100]+1, FT_VOLS[100]=_TVOL+FT_VOLS[100]
   ENDIF

  ; Write a header file for links
 if (A=1) print CSV=T,list='ScreenLine', 'A','B','Area Type','Fac Type','Fac Type Group','Volume','Count','Distance' printo=2   
   
IF (COUNT>0)

;2-digit FT
   _volbyft[ft]=_volbyft[ft]+TOTAL_VOL
   _cntbyft[ft]=_cntbyft[ft]+COUNT
   _vmtvbyft[ft]=_vmtvbyft[ft]+VOLVMT
   _vmtcbyft[ft]=_vmtcbyft[ft]+CNTVMT
   _vhtvbyft[ft]=_vhtvbyft[ft]+VOLVHT
   _vhtcbyft[ft]=_vhtcbyft[ft]+CNTVHT
   _lnkbyft[ft]=_lnkbyft[ft]+1

   _volbyft[100]=_volbyft[100]+TOTAL_VOL
   _cntbyft[100]=_cntbyft[100]+COUNT
   _vmtvbyft[100]=_vmtvbyft[100]+VOLVMT
   _vmtcbyft[100]=_vmtcbyft[100]+CNTVMT
   _vhtvbyft[100]=_vhtvbyft[100]+VOLVHT
   _vhtcbyft[100]=_vhtcbyft[100]+CNTVHT
   _lnkbyft[100]=_lnkbyft[100]+1

;1-digit FTG
   _volbyftg[ftg]=_volbyftg[ftg]+TOTAL_VOL
   _cntbyftg[ftg]=_cntbyftg[ftg]+COUNT
   _vmtvbyftg[ftg]=_vmtvbyftg[ftg]+VOLVMT
   _vmtcbyftg[ftg]=_vmtcbyftg[ftg]+CNTVMT
   _vhtvbyftg[ftg]=_vhtvbyftg[ftg]+VOLVHT
   _vhtcbyftg[ftg]=_vhtcbyftg[ftg]+CNTVHT
   _lnkbyftg[ftg]=_lnkbyftg[ftg]+1

   _volbyftg[100]=_volbyftg[100]+TOTAL_VOL
   _cntbyftg[100]=_cntbyftg[100]+COUNT
   _vmtvbyftg[100]=_vmtvbyftg[100]+VOLVMT
   _vmtcbyftg[100]=_vmtcbyftg[100]+CNTVMT
   _vhtvbyftg[100]=_vhtvbyftg[100]+VOLVHT
   _vhtcbyftg[100]=_vhtcbyftg[100]+CNTVHT
   _lnkbyftg[100]=_lnkbyftg[100]+1

;1-digit AT
   _volbyatg[atg]=_volbyatg[atg]+TOTAL_VOL
   _cntbyatg[atg]=_cntbyatg[atg]+COUNT
   _vmtvbyatg[atg]=_vmtvbyatg[atg]+VOLVMT
   _vmtcbyatg[atg]=_vmtcbyatg[atg]+CNTVMT
   _vhtvbyatg[atg]=_vhtvbyatg[atg]+VOLVHT
   _vhtcbyatg[atg]=_vhtcbyatg[atg]+CNTVHT
   _lnkbyatg[atg]=_lnkbyatg[atg]+1

   _volbyatg[100]=_volbyatg[100]+TOTAL_VOL
   _cntbyatg[100]=_cntbyatg[100]+COUNT
   _vmtvbyatg[100]=_vmtvbyatg[100]+VOLVMT
   _vmtcbyatg[100]=_vmtcbyatg[100]+CNTVMT
   _vhtvbyatg[100]=_vhtvbyatg[100]+VOLVHT
   _vhtcbyatg[100]=_vhtcbyatg[100]+CNTVHT
   _lnkbyatg[100]=_lnkbyatg[100]+1

;No of Lanes
   _volbyLNS[LNS]=_volbyLNS[LNS]+TOTAL_VOL
   _cntbyLNS[LNS]=_cntbyLNS[LNS]+COUNT
   _vmtvbyLNS[LNS]=_vmtvbyLNS[LNS]+VOLVMT
   _vmtcbyLNS[LNS]=_vmtcbyLNS[LNS]+CNTVMT
   _vhtvbyLNS[LNS]=_vhtvbyLNS[LNS]+VOLVHT
   _vhtcbyLNS[LNS]=_vhtcbyLNS[LNS]+CNTVHT
   _lnkbyLNS[LNS]=_lnkbyLNS[LNS]+1

   _volbyLNS[100]=_volbyLNS[100]+TOTAL_VOL
   _cntbyLNS[100]=_cntbyLNS[100]+COUNT
   _vmtvbyLNS[100]=_vmtvbyLNS[100]+VOLVMT
   _vmtcbyLNS[100]=_vmtcbyLNS[100]+CNTVMT
   _vhtvbyLNS[100]=_vhtvbyLNS[100]+VOLVHT
   _vhtcbyLNS[100]=_vhtcbyLNS[100]+CNTVHT
   _lnkbyLNS[100]=_lnkbyLNS[100]+1

;MPO Screenline/Cutline
   _volbysl[sl]=_volbysl[sl]+TOTAL_VOL
   _cntbysl[sl]=_cntbysl[sl]+COUNT
   _vmtvbysl[sl]=_vmtvbysl[sl]+VOLVMT
   _vmtcbysl[sl]=_vmtcbysl[sl]+CNTVMT
   _vhtvbysl[sl]=_vhtvbysl[sl]+VOLVHT
   _vhtcbysl[sl]=_vhtcbysl[sl]+CNTVHT
   _lnkbysl[sl]=_lnkbysl[sl]+1

   _volbysl[100]=_volbysl[100]+TOTAL_VOL
   _cntbysl[100]=_cntbysl[100]+COUNT
   _vmtvbysl[100]=_vmtvbysl[100]+VOLVMT
   _vmtcbysl[100]=_vmtcbysl[100]+CNTVMT
   _vhtvbysl[100]=_vhtvbysl[100]+VOLVHT
   _vhtcbysl[100]=_vhtcbysl[100]+CNTVHT
   _lnkbysl[100]=_lnkbysl[100]+1

   
   
 ; Write out links with counts
 print CSV=T list = LI.1.SCREENLN , LI.1.A, LI.1.B, LI.1.ATYPE, LI.1.FACTYPE, FT,  LI.1.TOTAL_VOL, LI.1.AAWDT, LI.1.DISTANCE printo=2

endif


ENDPHASE

; =========================================================
; SUMMARY REPORTING
; =========================================================
PHASE=SUMMARY

if (_countsum>0)   ;condition on _countsum>0

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ Loop to write out the Percent Root Mean Square Error
LOOP _iter=1,8

   if (_iter=1) vol_label = '    1 -  5000', _limit='100'
   if (_iter=2) vol_label = ' 5000 - 10000', _limit=' 45'
   if (_iter=3) vol_label = '10000 - 15000', _limit=' 35'
   if (_iter=4) vol_label = '15000 - 20000', _limit=' 30'
   if (_iter=5) vol_label = '20000 - 30000', _limit=' 27'
   if (_iter=6) vol_label = '30000 - 50000', _limit=' 25'
   if (_iter=7) vol_label = '50000 - 60000', _limit=' 20'
   if (_iter=8) vol_label = 'Above 60000' , _limit=' 19'
   
   ; Write header
   if (_iter=1) print CSV=T, list = 'ALL DAY: Volume Count Deviation Summary' printo=1
   if (_iter=1) print CSV=T, list = '\n A. Volume Count % Diff By Volume Group' printo=1
   if (_iter=1) print CSV=T, list = '\n Vol Grp', 'Count Range', 'Volume', 'Count',  'Model Dev(%)', 'Target', 'No of Links' printo=1
  
   if (_cnt[_iter]>0) print CSV=T, 
   list= _iter(2.0c),   
            vol_label,
            _vols[_iter],
            _cns[_iter],
            ((_VOLS[_iter]/_cns[_iter])-1)*100,
            _limit,
            _cnt[_iter] PRINTO=1

ENDLOOP    

_iter=9, vol_label = 'All ', _limit=' 10'
  print CSV=T,  list = _iter(2.0c),  
          vol_label, 
          _vols[_iter],
 					_cns[_iter],
          ((_VOLS[_iter]/_cns[_iter])-1)*100,
          _limit,
          _cnt[_iter], PRINTO=1
 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Summary for Vol/Cnt by FT2 
_iter=0
LOOP _iter=1,100

   if (_iter=1) _limit=' 20%' , fac_Label = 'Freeway          ', pct_diff =  '7%'
   if (_iter=2) _limit=' 35%' , fac_Label = 'Major Arterial   ', pct_diff = '10%'
   if (_iter=3) _limit=' 50%' , fac_Label = 'Minor Arterial   ', pct_diff = '15%'
   if (_iter=4) _limit=' 90%' , fac_Label = 'Collector & Local', pct_diff = '25%'    
   if (_iter=5) _limit=' 50%' , fac_Label = 'Connectors       ', pct_diff = ' NA'
   if (_iter=100) _limit=' 20%', fac_Label = 'Total           ', pct_diff = '10%'

  ; -- Volume and Count difference by Facility types
  if (_iter=1) print list="\n","\n B. Volume Count  % Diff  by Facility Type " PRINTO=1
  if (_iter=1) print CSV=T,list='Type','FT2 Grp','No of Links','Volume','Count','Target % Deviation','Model % Deviation' printo=1
   
  if ((_cntbyft[_iter]>0)&(_iter<100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
          pct_diff,
          ((_volbyft[_iter]/_cntbyft[_iter]) -1)*100 PRINTO=1
     
 if (_iter=100) _limit=' 30- 40%'
  ENDLOOP
  
_iter=100   
 if ((_cntbyft[100]>0)&(_iter=100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,  
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
           pct_diff,
          ((_volbyft[_iter]/_cntbyft[_iter])-1)*100 PRINTO=1
       

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; --  Volume and Count RMSE difference by Facility types  
_iter=0
LOOP _iter=1,100

   if (_iter=1) _limit=' 20%' , fac_Label = 'Freeway          ', pct_diff =  '7%'
   if (_iter=2) _limit=' 35%' , fac_Label = 'Major Arterial   ', pct_diff = '10%'
   if (_iter=3) _limit=' 50%' , fac_Label = 'Minor Arterial   ', pct_diff = '15%'
   if (_iter=4) _limit=' 90%' , fac_Label = 'Collector & Local', pct_diff = '25%'    
   if (_iter=5) _limit=' 50%' , fac_Label = 'Connectors       ', pct_diff = ' NA'
   if (_iter=100) _limit=' 20%', fac_Label = 'Total           ', pct_diff = '10%'

; -- Volume and Count difference by Facility types
if (_iter=1) print list="\n","\n B. Volume and Count RMSE by Facility Type" PRINTO=1
if (_iter=1) print CSV=T,list='Type','FT2 Grp','No of Links','Volume','Count','TARGET RMSE','MODEL RMSE' printo=1 

  if ((_cntbyft[_iter]>0)&(_iter<100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
          _limit,     
          sqrt(FT_err[_iter]/(FT_cnt[_iter]-1))/(FT_cns[_iter]/FT_cnt[_iter])*100 PRINTO=1
     
 if (_iter=100) _limit=' 30- 40%'
  ENDLOOP
  
_iter=100   
 if ((_cntbyft[100]>0)&(_iter=100)) print CSV=T,
    list= _iter(3.0c),
           fac_Label,  
          _lnkbyft[_iter],
          _volbyft[_iter],
          _cntbyft[_iter],
          _limit,     
          sqrt(FT_err[_iter]/(FT_cnt[_iter]-1))/(FT_cns[_iter]/FT_cnt[_iter])*100 PRINTO=1
                  
 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Summary for Vol/Cnt by FT1 
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n C. VOLUME AND COUNT SUMMARY BY 1-DIGIT FACILITY TYPE ", PRINTO=1
  if (_iter=1) print CSV=T,list='FT Grp','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 
  
  if ((_cntbyftg[_iter]>0)&(_iter<100)) print CSV=T,
    list=_iter(3.0c),
         _lnkbyftg[_iter],
         _volbyftg[_iter],
         _cntbyftg[_iter],
         ((_volbyftg[_iter]/_cntbyftg[_iter])-1)*100,

         _vmtvbyftg[_iter],
         _vmtcbyftg[_iter],
         ((_vmtvbyftg[_iter]/_vmtcbyftg[_iter])-1)*100,

         _vhtvbyftg[_iter],
         _vhtcbyftg[_iter],
         ((_vhtvbyftg[_iter]/_vhtcbyftg[_iter])-1)*100, PRINTO=1
     

 if ((_cntbyftg[100]>0)&(_iter=100))  print CSV=T,
    list= "ALL",
     _lnkbyftg[_iter],
     _volbyftg[_iter],
     _cntbyftg[_iter],
     ((_volbyftg[_iter]/_cntbyftg[_iter])-1)*100,
     _vmtvbyftg[_iter],
     _vmtcbyftg[_iter],
     ((_vmtvbyftg[_iter]/_vmtcbyftg[_iter])-1)*100,
     _vhtvbyftg[_iter],
     _vhtcbyftg[_iter],
     ((_vhtvbyftg[_iter]/_vhtcbyftg[_iter])-1)*100, PRINTO=1

ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ Summary for for Vol/Cnt by AT1
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n D. VOLUME AND COUNT SUMMARY BY 1-DIGIT AREA TYPE", PRINTO=1
  if (_iter=1) print CSV=T,list='AT Grp','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 


  if ((_cntbyatg[_iter]>0)&(_iter<100)) print CSV=T,
    list=_iter(3.0c),
         _lnkbyatg[_iter],

         _volbyatg[_iter],
         _cntbyatg[_iter],
         ((_volbyatg[_iter]/_cntbyatg[_iter])-1)*100,

         _vmtvbyatg[_iter],
         _vmtcbyatg[_iter],
         ((_vmtvbyatg[_iter]/_vmtcbyatg[_iter])-1)*100,

         _vhtvbyatg[_iter],
         _vhtcbyatg[_iter],
         ((_vhtvbyatg[_iter]/_vhtcbyatg[_iter])-1)*100, PRINTO=1


 if ((_cntbyatg[100]>0)&(_iter=100)) print CSV=T,
    list= "ALL",
         _lnkbyatg[_iter],

         _volbyatg[_iter],
         _cntbyatg[_iter],
         ((_volbyatg[_iter]/_cntbyatg[_iter])-1)*100,

         _vmtvbyatg[_iter],
         _vmtcbyatg[_iter],
         ((_vmtvbyatg[_iter]/_vmtcbyatg[_iter])-1)*100,

         _vhtvbyatg[_iter],
         _vhtcbyatg[_iter],
         ((_vhtvbyatg[_iter]/_vhtcbyatg[_iter])-1)*100, PRINTO=1

ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ one for Vol/Cnt by LNS 
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n E. VOLUME AND COUNT SUMMARY BY LANES PER DIRECTION ", PRINTO=1
  if (_iter=1) print CSV=T,list='Lanes/Direction','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 

  if ((_cntbyLNS[_iter]>0)&(_iter<100)) print CSV=T,
    list=_iter(3.0c),
         _lnkbyLNS[_iter],

         _volbyLNS[_iter],
         _cntbyLNS[_iter],
         ((_volbyLNS[_iter]/_cntbyLNS[_iter])-1)*100,

         _vmtvbyLNS[_iter],
         _vmtcbyLNS[_iter],
         ((_vmtvbyLNS[_iter]/_vmtcbyLNS[_iter])-1)*100,
         
         _vhtvbyLNS[_iter],
         _vhtcbyLNS[_iter],
         ((_vhtvbyLNS[_iter]/_vhtcbyLNS[_iter])-1)*100, PRINTO=1

 if ((_cntbyLNS[100]>0)&(_iter=100)) print CSV=T,
    list= "ALL",
         _lnkbyLNS[_iter],

         _volbyLNS[_iter],
         _cntbyLNS[_iter],
         ((_volbyLNS[_iter]/_cntbyLNS[_iter])-1)*100,

         _vmtvbyLNS[_iter],
         _vmtcbyLNS[_iter],
         ((_vmtvbyLNS[_iter]/_vmtcbyLNS[_iter])-1)*100,
         
         _vhtvbyLNS[_iter],
         _vhtcbyLNS[_iter],
         ((_vhtvbyLNS[_iter]/_vhtcbyLNS[_iter])-1)*100, PRINTO=1

ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++ one for Vol/Cnt by SL (MPO Scrrenline/Cutline)
_iter=0
LOOP _iter=1,100
  if (_iter=1) print list="\n","\n F. VOLUME AND COUNT SUMMARY BY MPO SCREENLINE & CUTLINE ", PRINTO=1
  if (_iter=1) print CSV=T,list='Screen/Cut-Line','No of Links','Volume','Count',' % Diff', 'VMT (Volume)', 'VMT(Count)', 
                                 '% Diff VMT', 'VHT(Volume)', 'VHT (Count)', '% Diff VHT'   printo=1 
                                 
  if ((_cntbySL[_iter]>0)&(_iter<100)) print CSV=T,
    list= _iter(3.0c),
          _lnkbySL[_iter],

          _volbySL[_iter],
          _cntbySL[_iter],
          ((_volbySL[_iter]/_cntbySL[_iter])-1)*100,

          _vmtvbySL[_iter],
          _vmtcbySL[_iter],
          ((_vmtvbySL[_iter]/_vmtcbySL[_iter])-1)*100,

          _vhtvbySL[_iter],
          _vhtcbySL[_iter],
          ((_vhtvbySL[_iter]/_vhtcbySL[_iter])-1)*100, PRINTO=1
 
 if ((_cntbySL[100]>0)&(_iter=100)) print CSV=T,
    list= "ALL",
          _lnkbySL[_iter],

          _volbySL[_iter],
          _cntbySL[_iter],
          ((_volbySL[_iter]/_cntbySL[_iter])-1)*100,

          _vmtvbySL[_iter],
          _vmtcbySL[_iter],
          ((_vmtvbySL[_iter]/_vmtcbySL[_iter])-1)*100,

          _vhtvbySL[_iter],
          _vhtcbySL[_iter],
          ((_vhtvbySL[_iter]/_vhtcbySL[_iter])-1)*100, 
 "\n Note: Counts with MPO Screenline/Cutline of ZERO are reported as SL/CL of 98", PRINTO=1


ENDLOOP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

endif ; condition on _countsum>0

ENDPHASE

ENDRUN


; Script for program HIGHWAY in file "C:\projects\rvtpo\Cube\HwySkims_Congested_PK.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="{SCENARIO_DIR}\Output\Logs\PBHWY00B.PRN" MSG='Build PK congested skims'
       
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\ZONAL AT{Year}{Alternative}.DBF",
 Z = N
FILEI NETI = "{SCENARIO_DIR}\Output\LOADED_{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\Term_Time.dbf"

FILEO MATO[1] = "{SCENARIO_DIR}\Output\PK_CNG_HwySkim.MAT",
      MO=1-5, NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME,
      DEC=2,2,0,0,2

;# lookup table for terminal times based on area type
LOOKUP LOOKUPI=1, NAME=Term_Time,
         LOOKUP[1]=ATYPE, RESULT=OTIME,
         LOOKUP[2]=ATYPE, RESULT=DTIME,
       FAIL[3]=0
; example of use: v=Term_Time(2,25)
; look for 25 in the ATYPE field and returns the DTIME value


PARAMETERS  ZONES={Total Zones}



PROCESS PHASE=LINKREAD

  ; use Peak congested speed as speed for feedback skim
  SPEED = LI.SPEED_PK_CNG

ENDPROCESS

PROCESS PHASE=ILOOP

  ;# skim network for time and distance
  PATH=COST,MW[1]=PATHTRACE(LI.TIME_PK_CNG,1),MW[2]=PATHTRACE(LI.DISTANCE)
  MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time is half of the time to the nearest zone.
  MW[2][I] = 0                ; Set Intrazonal Dist = 0

  IF(i < {Internal Zones})  ;# terminal times only exist for internal Zones
    JLOOP
      MW[3] = Term_Time(1, zi.1.ATYPE[i])       ;origin terminal time
      MW[4] = Term_Time(2, zi.1.ATYPE[j])       ;destination terminal time
    ENDJLOOP
  ELSE ;# external stations
    MW[3] = 0
    MW[4] = 0
  ENDIF

  ;# Total Impedance including terminal times
  MW[5] = MW[1]+MW[3]+MW[4]

ENDPROCESS

ENDRUN


; Script for program HIGHWAY in file "C:\projects\rvtpo\Cube\HwySkims_Congested_OP.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY PRNFILE="C:\projects\rvtpo\CUBE\PBHWY00A.PRN" MSG='Build OP congested skims'
       
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\ZONAL AT{Year}{Alternative}.DBF",
 Z = N
FILEI NETI = "{SCENARIO_DIR}\Output\LOADED_{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\Term_Time.dbf"

FILEO MATO[1] = "{SCENARIO_DIR}\Output\OP_CNG_HwySkim.MAT",
      MO=1-5, NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME,
      DEC=2,2,0,0,2

;# lookup table for terminal times based on area type
LOOKUP LOOKUPI=1, NAME=Term_Time,
         LOOKUP[1]=ATYPE, RESULT=OTIME,
         LOOKUP[2]=ATYPE, RESULT=DTIME,
       FAIL[3]=0
; example of use: v=Term_Time(2,25)
; look for 25 in the ATYPE field and returns the DTIME value


PARAMETERS  ZONES={Total Zones}



PROCESS PHASE=LINKREAD

  ; use Peak congested speed as speed for feedback skim
  SPEED = LI.SPEED_OP_CNG

ENDPROCESS

PROCESS PHASE=ILOOP

  ;# skim network for time and distance
  PATH=COST,MW[1]=PATHTRACE(LI.TIME_OP_CNG,1),MW[2]=PATHTRACE(LI.DISTANCE)
  MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time is half of the time to the nearest zone.
  MW[2][I] = 0                ; Set Intrazonal Dist = 0

  IF(i < {Internal Zones})  ;# terminal times only exist for internal Zones
    JLOOP
      MW[3] = Term_Time(1, zi.1.ATYPE[i])       ;origin terminal time
      MW[4] = Term_Time(2, zi.1.ATYPE[j])       ;destination terminal time
    ENDJLOOP
  ELSE ;# external stations
    MW[3] = 0
    MW[4] = 0
  ENDIF

  ;# Total Impedance including terminal times
  MW[5] = MW[1]+MW[3]+MW[4]

ENDPROCESS

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*COPY {SCENARIO_DIR}\Output\PK_CNG_HwySkim.MAT {SCENARIO_DIR}\OUTPUT\PK_HWYSKIM_@Feedback_ITER@.MAT
*COPY {SCENARIO_DIR}\Output\OP_CNG_HwySkim.MAT {SCENARIO_DIR}\OUTPUT\OP_HWYSKIM_@Feedback_ITER@.MAT

; End of PILOT Script

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


; End of PILOT Script

ENDLOOP

; Script for program PUBLIC TRANSPORT in file "C:\projects\rvtpo\Cube\Transit_Assignment_PK.S"
;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\Trn_Assignment_PK.PRN" MSG='Transit Assignment'
FILEI NETI = "{SCENARIO_DIR}\Output\PK_TransitWalk.NET"
FILEI ROUTEI[2] = "{SCENARIO_DIR}\Output\PK_TPATHPrem.RTE"
FILEI ROUTEI[1] = "{SCENARIO_DIR}\Output\PK_TPATHBus.RTE"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\PK_Transit.mat"

FILEO LINKO[1] = "{SCENARIO_DIR}\Output\Trn_PK.dbf",
 NTLEGS=T, ONOFFS=T
FILEO REPORTO = "{SCENARIO_DIR}\Output\Trn_PK.rpt"
FILEO NETO = "{SCENARIO_DIR}\Output\Trn_PK.net"

            ; OVERALL PARAMETERS OF RUN
            PARAMETERS NOROUTEMSGS=0, NOROUTEERRS=9999999, USERCLASSES=1-2,HDWAYPERIOD=1,
                TRIPSIJ[1]=MI.1.1,
                TRIPSIJ[2]=MI.1.2
            REPORT LINES=T, LINEVOLS=T
     
ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\projects\rvtpo\Cube\Transit_Assignment_OP.S"
;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\Trn_Assignment_OP.PRN" MSG='Transit Assignment'
FILEO NETO = "{SCENARIO_DIR}\Output\Trn_OP.net"
FILEI NETI = "{SCENARIO_DIR}\Output\OP_TransitWalk.NET"
FILEI ROUTEI[2] = "{SCENARIO_DIR}\Output\OP_TPATHPrem.RTE"
FILEI ROUTEI[1] = "{SCENARIO_DIR}\Output\OP_TPATHBus.RTE"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\OP_Transit.mat"

FILEO LINKO[1] = "{SCENARIO_DIR}\Output\Trn_OP.dbf",
 NTLEGS=T, ONOFFS=T
FILEO REPORTO = "{SCENARIO_DIR}\Output\Trn_OP.rpt"

            ; OVERALL PARAMETERS OF RUN
            PARAMETERS NOROUTEMSGS=0, NOROUTEERRS=9999999, USERCLASSES=1-2,HDWAYPERIOD=2,
                TRIPSIJ[1]=MI.1.1,
                TRIPSIJ[2]=MI.1.2
            REPORT LINES=T, LINEVOLS=T
     
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*IF EXIST "{SCENARIO_DIR}\Output\Output.MDB" DEL "{SCENARIO_DIR}\Output\Output.MDB"
*COPY "{CATALOG_DIR}\MAPS\EMPTY.GDB" "{SCENARIO_DIR}\OUTPUT\OUTPUT.GDB"
*COPY "{CATALOG_DIR}\MAPS\Daily_VOC.MXD" "{SCENARIO_DIR}\OUTPUT\Daily_VOC.MXD"
*COPY "{CATALOG_DIR}\MAPS\AM_VOC.MXD" "{SCENARIO_DIR}\OUTPUT\AM_VOC.MXD"
*COPY "{CATALOG_DIR}\MAPS\PM_VOC.MXD" "{SCENARIO_DIR}\OUTPUT\PM_VOC.MXD"
*COPY "{CATALOG_DIR}\MAPS\MD_VOC.MXD" "{SCENARIO_DIR}\OUTPUT\MD_VOC.MXD"
*COPY "{CATALOG_DIR}\MAPS\NT_VOC.MXD" "{SCENARIO_DIR}\OUTPUT\NT_VOC.MXD"

*COPY "{CATALOG_DIR}\CUBE\*.PRN" "{SCENARIO_DIR}\OUTPUT\LOGS\*.PRN"
*DEL "{CATALOG_DIR}\CUBE\*.PRN" 
; End of PILOT Script

; Script for program NETWORK in file "C:\projects\rvtpo\CUBE\FBNET00A.S"
;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\output\Logs\export_to_geodatabase.prn" MSG='Export NET to Geodatabase'
FILEO NETO = "{SCENARIO_DIR}\output\output.gdb\loaded_network"
FILEI LINKI[1] = "{CATALOG_DIR}\Maps\empty.gdb\HWNetwork"
FILEI LINKI[2] = "{SCENARIO_DIR}\OUTPUT\LOADED_{Year}{Alternative}.NET"
;FILEI GEOMI[1] = "{CATALOG_DIR}\MasterNetwork\cubeShapeFile_2012A.shp"
 
ENDRUN


