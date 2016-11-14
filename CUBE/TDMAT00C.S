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
