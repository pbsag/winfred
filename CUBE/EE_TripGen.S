;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_TripGen.PRN" MSG='IEEI_TripGen'
FILEI ZDATI[2] = "{CATALOG_DIR}\Params\EXTERNALTRIPS.DBF"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Params\IEEI_GEN_RATES.dbf"
FILEO PAO[1] = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF",
FORM=10.3, DBF=T, LIST=Z, P[1], A[1]
FILEI ZDATI[1] = "{SCENARIO_DIR}\Input\se.dbf"

ZONES={Total Zones}
LOOKUP LOOKUPI=1,
       NAME=G_RATES,
         LOOKUP[1]=IND_VAR, RESULT=COEFF,
       FAIL[3]=0

; 1 = HH    
; 2 = IND
; 3 = SER
; 4 = OFFHTR
; 5 = RET
; 6 = SG                  
       
PHASE=ILOOP
  IF (I <= {Internal Zones})
    TOTALSG = ZI.1.SG_RET + ZI.1.SG_HOS + ZI.1.SG_AIR + ZI.1.SG_COL
    OFFHTRET = ZI.1.OFF + ZI.1.HTRET
    A[1]=(ZI.1.HH * G_RATES(1,1)) + (ZI.1.IND * G_RATES(1,2)) + (ZI.1.RET * G_RATES(1,5)) +
       (OFFHTRET * G_RATES(1,4)) + (ZI.1.SER * G_RATES(1,3)) + (TOTALSG * G_RATES(1,6))
    P[1]= 0
  ELSE
    A[1]=0
    P[1]= ZI.2.IEEI
  ENDIF
  ENDPHASE

PHASE=ADJUST
;  BALANCE A2P=1
  
REPORT A=Y P=Y
ENDPHASE
 

ENDRUN
