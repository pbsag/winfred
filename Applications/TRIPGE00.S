; Script for program GENERATION in file "C:\1Projects\VDOT\Win-Fred-Model-Jan0709\WinFred-Model\Applications\02GEN00A.S"
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

If (i=199)

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


; Script for program GENERATION in file "C:\1Projects\VDOT\Win-Fred-Model-Jan0709\WinFred-Model\Applications\02GEN00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\02GEN00B.PRN" MSG='Balancing Productions and Attractions'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Balfac"

FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN00A.DAT",
Z=#1, UBHBWP=#2, UBHBOP=#3, UBNHBP=#4, UBHBWA=#5, UBHBOA=#6, UBNHBA=#7
FILEO PAO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\02GEN{Year}B.DAT",
FORM=10.O, LIST=Z, P[1], P[2], P[3],  
                  A[1], A[2], A[3]


Zones=199

lookup,lookupi=1,
NAME=Balance,    ; Balance factor lookup table
       lookup[1]=1, result=2       ; Factors
;LOOKUP,
; FILE = "{SCENARIO_DIR}\DAILYBALFAC.TXT",
       ;NAME=Balance,    ; Balance factor lookup table
       ;lookup[1]=1, result=2       ; Factors
     
; Balance Internal Trips
If (i<=167)

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


