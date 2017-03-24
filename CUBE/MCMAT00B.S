;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\ModeChoiceModel_HBO.PRN"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\HBO_MCTRIPS.MAT",
 MO = 21-25, NAME = DA, SR, WLB, PMB, NOM
FILEI ZDATI[1] = "{SCENARIO_DIR}\INPUT\TRNWALKPERCENT.DBF"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\DEST_HBO_HBSH_HBU.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\HBO_MCPROB.MAT"

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
           
           IF(I=={Internal Zones} && J=={Internal Zones})
              print,list= "EST_EDA"  ," = ",EDA , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F
              print,list= "EST_ESR"  ," = ",ESR , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F
              print,list= "EST_ELB"  ," = ",ELB , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F
              print,list= "EST_EPM"  ," = ",EPM , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F
              print,list= "EST_ENM"  ," = ",ENM , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F
              print,list= "EST_TRN"  ," = ",TRN , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F
              print,list= "EST_AUT"  ," = ",AUT , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F
              print,list= "EST_TOT"  ," = ",TOT , FILE = "{SCENARIO_DIR}\OUTPUT\LOGS\HBOESTIMATED.DAT",
 append = F            
           ENDIF         
        ENDJLOOP
        
ENDRUN
