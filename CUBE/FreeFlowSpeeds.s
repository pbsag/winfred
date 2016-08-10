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
