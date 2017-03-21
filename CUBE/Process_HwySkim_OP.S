; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\Process_HwySkim_OP.PRN" MSG='Process Highway Skims'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\OP_Hwyskim.MAT",
 MO=11-15,DEC=5*D,NAME=TIME,DISTANCE,OTERM,DTERM,TOTAL_TIME
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\OP_CNG_HwySkim.MAT"

FILLMW MW[1]=MI.1.1(5)                ; highway skims

; Reset invalid values to zero
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
