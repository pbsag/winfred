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
