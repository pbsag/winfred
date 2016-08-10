;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='HBO + HBSH'
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBO_HBSH.MAT",
 MO = 1, NAME = HBO_HBSH
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\Dest_HBSH.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBO.MAT"

MW[1] = MI.1.1 + MI.2.1
        
ENDRUN
