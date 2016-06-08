; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00B.PRN" MSG='AM AND PM Peak Hour Trip Tables'
FILEI MATI[3] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}B.MAT"
FILEI MATI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\04MAT{Year}A.MAT"
FILEI MATI[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00A.MAT"
FILEO MATO[2] = "{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00C.MAT",
MO=5-8 NAME=PMHBWVeh, PMHBOVeh, PMNHBVeh, TotPMVeh

FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00B.MAT",
MO=1-4 NAME=AMHBWVeh, AMHBOVeh, AMNHBVeh, TotAMVeh

FILEI ZDATI[1] = "{SCENARIO_DIR}\EXTERNAL{Year}.DBF"

PAR ZONEMSG=10
JLOOP
fizone=1
lizone={IZONES}
fezone=lizone+1
lezone=_zones
  ; APPLY IE FACTORS
IF (I=fizone-lizone&J=fezone-lezone)
    MW[1]=(MI.1.HBWVeh)*ZI.1.AMPerIE[J]
    MW[2]=(MI.1.HBOVeh)*ZI.1.AMPerIE[J]
    MW[3]=(MI.1.NHBVeh)*ZI.1.AMPerIE[J]
    MW[4]=MW[1]+MW[2]+MW[3]
    MW[5]=(MI.1.HBWVeh)*ZI.1.PMPerIE[J]
    MW[6]=(MI.1.HBOVeh)*ZI.1.PMPerIE[J]
    MW[7]=(MI.1.NHBVeh)*ZI.1.PMPerIE[J]
    MW[8]=MW[5]+MW[6]+MW[7]
endif
  ; APPLY EI FACTORS
IF (I=fezone-lezone&J=fizone-lizone)
    MW[1]=MI.1.HBWVeh*ZI.1.AMPerEI[I]
    MW[2]=MI.1.HBOVeh*ZI.1.AMPerEI[I]
    MW[3]=MI.1.NHBVeh*ZI.1.AMPerEI[I]
    MW[4]=MW[1]+MW[2]+MW[3]
    MW[5]=MI.1.HBWVeh*ZI.1.PMPerEI[I]
    MW[6]=MI.1.HBOVeh*ZI.1.PMPerEI[I]
    MW[7]=MI.1.NHBVeh*ZI.1.PMPerEI[I]
    MW[8]=MW[5]+MW[6]+MW[7]
endif
;    APPLY THE II FACTORS
IF (I=fizone-lizone&J=fizone-lizone)
    MW[1]=(MI.1.HBWVeh)*0.1528+(MI.1.HBWVeh.T)*0.0066
    MW[2]=(MI.1.HBOVeh)*0.0510+(MI.1.HBOVeh.T)*0.0034
    MW[3]=(MI.1.NHBVeh)*0.0104+(MI.1.NHBVeh.T)*0.0104
    MW[4]=MW[1]+MW[2]+MW[3]
    MW[5]=(MI.1.HBWVeh)*0.0077+(MI.1.HBWVeh.T)*0.1188
    MW[6]=(MI.1.HBOVeh)*0.0337+(MI.1.HBOVeh.T)*0.0395
    MW[7]=(MI.1.NHBVeh)*0.0428+(MI.1.NHBVeh.T)*0.0428
    MW[8]=MW[5]+MW[6]+MW[7]
ENDIF
;    APPLY THE EE FACTORS
 IF (I=fezone-lezone&J=fezone-lezone)
    mw[4]=mi.2.AMEE
    mw[8]=mi.3.PMEE
 ENDIF

ENDJLOOP


ENDRUN
