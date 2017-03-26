;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\MC_Merge_HBO_HBSH_HBU.PRN" MSG='HBO + HBSH + HBU'
FILEI MATI[3] = "{SCENARIO_DIR}\Output\Dest_HBU.MAT"
FILEO MATO[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBO_HBSH_HBU.MAT",
 MO = 1, NAME = HBO_HBSH_HBU
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\Dest_HBSH.MAT"
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_HBO.MAT"

MW[1] = MI.1.1 + MI.2.1 + MI.3.1
        
ENDRUN
