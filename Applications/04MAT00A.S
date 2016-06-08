; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\Logs\04MAT00A.PRN" MSG='Build External Trip Tables Using Old TP+ Model (2003) Data'

FILEO MATO[3] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT00C.MAT",
              MO=3,
              Name=DailyEE

FILEO MATO[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}B.MAT",
              MO=2,
              Name=PMEE

FILEO MATO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}A.MAT",
              MO=1,
              Name=AMEE


FILEI MATI[3] = "{SCENARIO_DIR}\DAILYEE{Year}.PRN",
         pattern=IJ:V fields=#1,2,3
      Zones={Total Zones}
      mw[3]=mi.3.1

FILEI MATI[2] = "{SCENARIO_DIR}\PMEE{Year}.PRN",
              pattern=IJ:V fields=#1,2,3
      Zones={Total Zones}
      MW[2]=mi.2.1


FILEI MATI[1] = "{SCENARIO_DIR}\AMEE{Year}.PRN",
                   pattern=IJ:V fields=#1,2,3
      Zones={Total Zones}
      mw[1]=mi.1.1

; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.

ENDRUN
