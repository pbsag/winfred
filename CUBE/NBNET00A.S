; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\NBNET00A.prn" MSG='Remove Unused Variables'

FILEI LINKI[1] = "{CATALOG_DIR}\Base\Master_highway.NET"

FILEO NETO = "{SCENARIO_DIR}\OUTPUT\HIGHWAY_CLEAN.NET",
  INCLUDE=A, B, ID, LENGTH, DIR, DISTANCE, NETWRK, FACTYPE, LANES,
          POST_SPD, RTE_NAME, AAWDT, TMS_ID, SCREENLN,
          TUNNEL, BRIDGE, TRK_PHB, TRAFF_PHB, VDOT_CAP,
          VDOT_FFSPD, COUNT, COUNT_YEAR, ROUTE_NAME

  REPORT CAPACITY=Y, SPEED=Y, DEADLINKS=Y, UNCONNECTED=Y, DUPLICATES=Y

  ; Extract the scenario specific network
  PROCESS  PHASE=LINKMERGE
    ; Assign the scenario specific attributes for valid links
    IF (NETWRK_{Year}{Alternative}=1)
        NETWRK=LI.1.NETWRK_{Year}{Alternative}
        FACTYPE=LI.1.FACTYPE_{Year}{Alternative}
        LANES=LI.1.LANES_{Year}{Alternative}
        POST_SPD=LI.1.POST_SPD_{Year}{Alternative}
        VDOT_CAP=LI.1.VDOT_CAP_{Year}{Alternative}
        VDOT_FFSPD=LI.1.VDOT_FFS_{Year}{Alternative}
    ENDIF

    ; Delete invalid links for a specific scenario
    IF (NETWRK_{Year}{Alternative}!=1)
        DELETE
    ENDIF

  ENDPROCESS

  PROCESS  PHASE=SUMMARY
    ; Use this phase for combining and reporting of working variables.
  ENDPROCESS

ENDRUN
