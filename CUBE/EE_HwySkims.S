; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\EE_HwySkims.PRN" MSG='Process Highway Skims'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Hwyskim.MAT",
 MO=11-15,DEC=5*D,NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME
FILEI MATI[1] = "{SCENARIO_DIR}\Output\IMPED11.MAT"

FILLMW MW[1]=MI.1.1(5)                ; highway skims

; Reset invalid values to zero
; Matrices in the Matrix File IMPED11.MAT
;   1 = TIME
;   2 = DIST
;   3 = OTERM
;   4 = DTERM
;   5 = TOTAL_TIME

;  For skim values that are extraordinaryly large, set the value to 0.
  JLOOP
      IF (MW[1] > 1000)
          MW[11] = 0
      ELSE
          MW[11] = MW[1]
      ENDIF

      IF (MW[2] > 1000)
          MW[12] = 0
      ELSE
          MW[12] = MW[2]
      ENDIF

      IF (MW[3] > 1000)
          MW[13] = 0
      ELSE
          MW[13] = MW[3]
      ENDIF

      IF (MW[4] > 1000)
          MW[14] = 0
      ELSE
          MW[14] = MW[4]
      ENDIF

      IF (MW[5] > 1000)
          MW[15] = 0
      ELSE
          MW[15] = MW[5]
      ENDIF

      ENDJLOOP

ENDRUN
