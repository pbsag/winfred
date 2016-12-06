; Script for program MATRIX in file "C:\projects\winfred\CUBE\TDMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\TDMAT00C.PRN" MSG='HBSC FF'
    zones = 1
    alpha = 1000000
    Beta = 0.25
    gamma = -0.32

FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\HBSC_FFFile.CSV",
 APPEND=F
    PRINT CSV=T, LIST=';Friction Factors', PRINTO=1, rewind=T
    
    LOOP CT= 1,100,1     ; Creating FFs for use in distribution
      FF=alpha*(CT^Beta)*exp(gamma*CT)
      PRINT CSV=T, FORM=10.5, LIST=CT,FF, PRINTO=1
    ENDLOOP
ENDRUN


; Script for program DISTRIBUTION in file "C:\projects\winfred\Cube\TripDistribution_GravityModel_HBSC.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\Output\Logs\TripDistribution_GravityModel_HBSC.PRN" MSG='Gravity Model - HBSC'
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


; Script for program MATRIX in file "C:\projects\winfred\Cube\TripDistribution_D2DFlowsl_HBSC.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\TripDistribution_D2DFlowsl_HBSC.PRN" MSG='HBSC District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_HBSC.MAT",
 MO = 1, NAME = HBSC

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 12, MISSINGZI=M, MISSINGZO=M
ENDRUN


; Script for program MATRIX in file "C:\projects\winfred\Cube\TripDistribution_remove_SchoolBus.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\TripDistribution_remove_SchoolBus.PRN" MSG='HBSC - no sch bus trips'
FILEI MATI[1] = "{SCENARIO_DIR}\Output\Person_HBSC.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Dest_HBSC.MAT",
 MO = 1, NAME = HBSC

 MW[1] = MI.1.1 * (1 - 0.83)

ENDRUN


; PILOT Script
*COPY {CATALOG_DIR}\PARAMS\HBW_shadowPrice.dbf {SCENARIO_DIR}\OUTPUT\HBW_shadowPrice.dbf
; End of PILOT Script

LOOP Iteration = 1, 10, 1

; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_HBW.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_HBW.PRN" MSG='HBW Apply Destination Choice Model'
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

		ZONES = {Internal Zones}
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
    Coeff_HOS     = COEFF(1,20)        ; SizeTerm = Hospital coefficient
    Coeff_SG_RET  = COEFF(1,21)        ; SizeTerm = SG_RET coefficient
    Coeff_SG_COL  = COEFF(1,22)        ; SizeTerm = SG_COL coefficient
    
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
		  MW[112] = Coeff_HH * ZI.1.HH[J] + Coeff_OFF_EMP * ZI.1.OFF[J] + Coeff_RET_EMP * (ZI.1.RET[J] + ZI.1.HTRET[J]) + Coeff_OTH_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.OFF[J]  - ZI.1.RET[J] - ZI.1.HTRET[J]) + Coeff_HOS * ZI.1.SG_HOS[J] + Coeff_SG_RET * ZI.1.SG_RET[J] + Coeff_SG_COL * ZI.1.SG_COL[J]
      
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
  	DESTSPLIT= TOTAL All, INCLUDE=1-169,
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


; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_HBW_ShadowPrice.s"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_HBW_ShadowPrice.PRN" MSG='Shadow Price'

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

; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_nonWork.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonWork_@PURP@.PRN" MSG='Apply Destination Choice Model'
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
    Coeff_HOS     = COEFF(1,20)        ; SizeTerm = Hospital coefficient
    
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
		  MW[112] = Coeff_HH * ZI.1.HH[J] + Coeff_OFF_EMP * ZI.1.OFF[J] + Coeff_RET_EMP * (ZI.1.RET[J] + ZI.1.HTRET[J]) + Coeff_OTH_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.OFF[J]  - ZI.1.RET[J] - ZI.1.HTRET[J]) + Coeff_OTH_OFF_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.RET[J] - ZI.1.HTRET[J]) + Coeff_HOS * ZI.1.SG_HOS[J]
      
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


; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_nonWork_TLFD.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonwork_TLFD_@PURP@.PRN" MSG='Non-Work Trip Length Frequency'
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


; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_nonWork_TLFD_Time.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonWork_TLFD_Time_@PURP@.PRN" MSG='Non-Work Trip Time Frequency'
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


; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_nonWork_D2DFlow.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonWork_D2DFlow_@PURP@.PRN" MSG='District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_@PURP@.MAT",
 MO = 1, NAME = @PURP@

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 10, MISSINGZI=M, MISSINGZO=M
ENDRUN


ENDLOOP

; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_work_TLFD.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_work_TLFD.PRN" MSG='Work Trip Length Frequency'
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


; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_work_TLFD_Time.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_work_TLFD_Time.PRN" MSG='Work Trip Time Frequency'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\HBW_TravelTime_TDLF.dbf",
FIELDS= HIGH,MID,LOW,TRIPS(16.8)
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\pk_Hwyskim.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\LOGS\work_ttfd.PRN"

             MW[1]=MI.1.HBW
             MW[2]=MI.2.Time
             gps=31-1
             Array trips=31             
             ; Time
             JLOOP
             ;group = min(max(round(mw[2]),1),50)
             group = min(INT(mw[2]/1),gps) + 1
             trips[group]=trips[group]+mw[1]
             ENDJLOOP
          
             IF (i=zones)
               LOOP group=1,31
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


; Script for program MATRIX in file "C:\projects\winfred\Cube\DC_work_D2DFlow.s"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_work_D2DFlow.PRN" MSG='HBW District - to - District Flows'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBW.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\DEST_D2D_HBW.MAT",
 MO = 1, NAME = HBW

 MW[1] = MI.1.1
 RENUMBER, FILE = "{CATALOG_DIR}\PARAMS\TAZDISTRICT.DAT",
zones = 10, MISSINGZI=M, MISSINGZO=M
ENDRUN


; Script for program MATRIX in file "C:\PROJECTS\WINFRED\CUBE\TDMAT00A.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\HBUTripAttractions.PRN" MSG='HBU Attractions'
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\se_classified_{year}{Alternative}.dbf"
FILEO RECO[1] = "{SCENARIO_DIR}\Output\HBU_ATTR.dbf",
fields = TAZ, UNVA

zones={Internal Zones}
RO.TAZ=I

MW[1]= zi.1.UNV
MW[2][144]= 4000*0.67
RO.UNVA=MW[2][I]

WRITE RECO=1

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

ENDRUN


; Script for program MATRIX in file "C:\PROJECTS\WINFRED\CUBE\TDMAT00B.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\HBU_FF.PRN" MSG='HBU FF'
    zones = 1
    alpha = 1000000
    Beta = 0.25
    gamma = -0.32
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\HBU_FFFile.csv",
 APPEND=F
    PRINT CSV=T, LIST=';Friction Factors', PRINTO=1, rewind=T
    
    LOOP CT= 1,100,1     ; Creating FFs for use in distribution
      FF=alpha*(CT^Beta)*exp(gamma*CT)
      PRINT CSV=T, FORM=10.5, LIST=CT,FF, PRINTO=1
    ENDLOOP

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

ENDRUN


; Script for program DISTRIBUTION in file "C:\PROJECTS\WINFRED\CUBE\TDDST00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=DISTRIBUTION PRNFILE="{SCENARIO_DIR}\Output\LOGS\HBUTripDistributions.PRN" MSG='Gravity Model - HBU'
FILEI LOOKUPI[1] = "{SCENARIO_DIR}\Output\HBU_FFFile.csv"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\OP_Hwyskim.MAT"
FILEI ZDATI[2] = "{SCENARIO_DIR}\Output\HBU_ATTR.dbf"
FILEO MATO[1] = "{SCENARIO_DIR}\Output\Dest_HBU.MAT",
 MO=1,NAME=UNV
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\HBU_PROD.DBF"

  LOOKUP,
   LOOKUPI=1,
   INTERPOLATE=Y, NAME=FF,
    LOOKUP[1]=1,RESULT=2
    
  ;   output distributed trips by purpose
  PARAMETERS
    ZONES={TOTAL ZONES},MAXITERS=25
    
  ;    setup the working p's and a's
  SETPA P[1]=Zi.1.HBU  A[1]=Zi.2.UNVA

  ;  get the los matrix into work matrix 11
  MW[11] = MI.1.Total_Time
  MW[12] = MI.1.Distance


  ;  do gravity models, each followed by a frequency summation
  GRAVITY   PURPOSE=1, LOS=MW[11], FFACTORS=FF
  ;

; The DISTRIBUTION module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  The module has a built in GRAVITY statement for implementing this commonly
; used distribution method.  User defined distribution process can also be defined.

ENDRUN


