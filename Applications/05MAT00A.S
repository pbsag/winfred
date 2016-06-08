; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\output\{Scenario_FullName}\logs\05MAT00A.PRN" MSG='Prepare Matrix for Peak Hour Conversion'
FILEI LOOKUPI[1] = "{CATALOG_DIR}\Calibration Constants\AutoOcc.dbf"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEO MATO[1] = "{CATALOG_DIR}\output\{Scenario_FullName}\05MAT00A.MAT",
MO=1-3,11-13, Name=HBWPer, HBOPer, NHBPer, HBWVeh, HBOVeh, NHBVeh


PAR ZONEMSG=10
JLOOP
fizone=1
lizone={IZONES}
fezone=lizone+1
lezone=_zones
  ; Balance IE
IF (I=fizone-lizone&J=fezone-lezone)
    MW[1]= ((MI.1.HBW+MI.1.HBW.T) * .5)
    MW[2]= ((MI.1.HBO+MI.1.HBO.T) * .5)
    MW[3]= ((MI.1.NHB+MI.1.NHB.T) * .5)
endif
  ; Balance EI
IF (I=fezone-lezone&J=fizone-lizone)
    MW[1]= ((MI.1.HBW+MI.1.HBW.T) * .5)
    MW[2]= ((MI.1.HBO+MI.1.HBO.T) * .5)
    MW[3]= ((MI.1.NHB+MI.1.NHB.T) * .5)
endif
  ; II equals PA original
IF (I=fizone-lizone&J=fizone-lizone)
    MW[1]= MI.1.HBW
    MW[2]= MI.1.HBO
    MW[3]= MI.1.NHB
endif

ENDJLOOP

/*Commented out by TCG for the use of external lookup tables*/
;-------------------------------------------------

;lookup name=autoocc,
       ;lookup[1]=1, result=2,       ; Morning Peak
       ;list=y,
;              AM      PM
     ;r='1     1.11',          ; HBW Auto Occupancy
     ;r='2     1.56',          ; HBO Auto Occupancy
     ;r='3     1.56'          ; NHB Auto Occupancy
;-------------------------------------------------

   lookup, lookupi=1, name=autoocc,
   lookup[1]=ROW, result=AUTOOCC,       ; Morning peak
   INTERPOLATE=N
     
MW[11]=MW[1]/autoocc(1,1)
MW[12]=MW[2]/autoocc(1,2)
MW[13]=MW[3]/autoocc(1,3)


ENDRUN
