;;<<Default Template>><<NETWORK>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\FreeflowSpeeds.prn" MSG='Attach Capacity and Free Flow Speed'
FILEI LOOKUPI[2] = "{CATALOG_DIR}\Params\Spd_Lookup.dbf"
FILEI LINKI[1] = "{SCENARIO_DIR}\Output\ATYPE NETWORK{Year}{Alternative}.NET"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\SpdCap_Lookup.dbf"

FILEO NETO = "{SCENARIO_DIR}\Output\Interim{Year}{Alternative}.NET"

; Define LOOKUP FUNCTION
; Capacity (Level of Service E) based on Facility Type, Land Use Density(1-3) and Number of Lanes
LOOKUP LOOKUPI=1,
       NAME=CAP_LU,
         LOOKUP[1]=LINKID, RESULT=CAP,
         FAIL[1]=0,FAIL[2]=0,FAIL[3]=0,
         LIST=Y

; Define LOOKUP FUNCTION
; Freeflow speed adjustment (applied to Posted Speed) for links based on Facility Type and Land Use Density(1-3)
LOOKUP LOOKUPI=1,
       NAME=SPD_LU,
         LOOKUP[1]=LINKID, RESULT=SPDADJ,
         FAIL[1]=0,FAIL[2]=0,FAIL[3]=0,
         LIST=Y
         
         
REPORT DEADLINKS=T, DUPLICATES=T, UNCONNECTED=T MERGE=T

PROCESS  PHASE=LINKMERGE
;   Recode Area Types (1-5) into three categories of Land Use Density (LUD)
LUD=0
IF (LI.1.ATYPE <=2) 
    LUD=1
  ELSEIF (LI.1.ATYPE >=3 & LI.1.ATYPE <=4) 
    LUD=2
  ELSEIF (LI.1.ATYPE = 5) 
    LUD=3
ENDIF

; Lookup Capacity and Speed
CAPE = (CAP_LU(1,((LI.1.FACTYPE*10) + LUD)))* LANES
FFSPEED = LI.1.POST_SPD + SPD_LU(1,((LI.1.FACTYPE*10) + LUD))

/*
The lookup table capacities can be over-ridden for a specific link by coding a non-zero 
  capacity in the VDOT_CAP field on the input network.  This over-ride should be used 
  cautiously, and the justification should documented by the user. 
*/
IF (LI.1.VDOT_CAP > 0)
    CAPE = LI.1.VDOT_CAP
ENDIF

; Capacities by time of day are derived from CAPE with adjustment factors.
CAPE_AM = CAPE * 2.79 ; 2.5  ; AM Capacity
CAPE_MD = CAPE * 4.40 ; 5.5  ; MD Capacity
CAPE_PM = CAPE * 3.18 ; 2.5  ; PM Capacity
CAPE_NT = CAPE * 5.63 ; 4.5  ; NT Capacity

ENDPROCESS

PROCESS  PHASE=SUMMARY
; Use this phase for combining and reporting of working variables.
ENDPROCESS

ENDRUN
