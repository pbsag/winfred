;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_TripGen.PRN" MSG='IEEI_TripGen'
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
