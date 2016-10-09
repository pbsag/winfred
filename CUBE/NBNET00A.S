; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\NBNET00A.prn" MSG='Remove Unused Variables'

FILEI LINKI[1] = "{SCENARIO_DIR}\INPUT\HIGHWAY.NET"

FILEO NETO = "{SCENARIO_DIR}\OUTPUT\HIGHWAY_CLEAN.NET",
  INCLUDE=A, B, ID, LENGTH, DIR, DISTANCE, FACTYPE, LANES,
          POST_SPD, RTE_NAME, AAWDT, TMS_ID, SCREENLN,
          TUNNEL, BRIDGE, TRK_PHB, PED_PHD, TRAFF_PHB, VDOT_CAP,
          COUNT, COUNT_YEAR, ROUTE_NAME, SCREEN_ID

REPORT CAPACITY=Y, SPEED=Y, DEADLINKS=Y, UNCONNECTED=Y, DUPLICATES=Y


ENDRUN