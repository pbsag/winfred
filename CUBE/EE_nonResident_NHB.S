;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='NR-NHB Model'
FILEO RECO[1] = "{SCENARIO_DIR}\Output\NHBNR_PA_{year}.DBF",
 FIELDS=Z, NHBNR_P, NHBNR_A
FILEI RECI = "{SCENARIO_DIR}\Output\IEEI_PA_{year}.DBF"


ZONES = {Total Zones}
NHB_PCT = .30 ; 30% of External trips make NHB trips inside the region

RO.Z=RI.Z
RO.NHBNR_P = RI.P1 * NHB_PCT
RO.NHBNR_A = RI.A1 * NHB_PCT
WRITE RECO=1

ENDRUN
