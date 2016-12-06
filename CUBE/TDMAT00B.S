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
