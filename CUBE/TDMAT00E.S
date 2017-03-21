; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\DC_nonwork_TLFD_@PURP@.PRN" MSG='Non-Work Trip Length Frequency'
FILEI MATI[1] = "{SCENARIO_DIR}\OUTPUT\Dest_@PURP@.MAT"
FILEI MATI[2] = "{SCENARIO_DIR}\OUTPUT\OP_Hwyskim.MAT"
FILEO RECO[1] = "{SCENARIO_DIR}\Output\@PURP@_TDLF.dbf"
FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\@PURP@_TDLF.PRN"


ENDRUN
