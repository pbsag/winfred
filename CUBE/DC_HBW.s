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
;      MW[112] = Coeff_HH * ZI.1.HH[J] + Coeff_OFF_EMP * ZI.1.OFF[J] + Coeff_RET_EMP * (ZI.1.RET[J] + ZI.1.HTRET[J]) + Coeff_OTH_EMP * (ZI.1.EMP_NOSG[J] - ZI.1.OFF[J]  - ZI.1.RET[J] - ZI.1.HTRET[J]) + Coeff_HOS * ZI.1.SG_HOS[J] 
      
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
	  	PRINT PRINTO=1 CSV=F LIST ='DESTINTION CHOICE TRACE HBW','\n\n'
	  	PRINT PRINTO=1 CSV=F LIST =' Destination Choice Model Trace \n\nSelected Interchange for Tracing:    ',{SelOrigin}(4.0),'-',{SelDest}(4.0),'\n'
	  	PRINT PRINTO=1 CSV=F LIST ='\n PURPOSE -                   HBW  '
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
