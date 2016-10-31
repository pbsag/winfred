;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\ModeChoice_Logsum_@PURP@.PRN" MSG='Mode Choice Logsums and Probabilities'
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

zones={Internal Zones}

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
