;;<<Default Template>><<GENERATION>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION MSG='Household Trip Production'
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\hbw.csv"
FILEI LOOKUPI[6] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\NHBO.DBF"
FILEI LOOKUPI[5] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBSHOP.DBF"
FILEI LOOKUPI[4] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBSCHOOL.DBF"
FILEI LOOKUPI[3] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBO.DBF"
FILEI LOOKUPI[2] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\NHBW.DBF"
FILEI LOOKUPI[1] = "{CATALOG_DIR}\PARAMS\TRIP_PROD\HBW.DBF"
FILEO PAO[1] = "{SCENARIO_DIR}\OUTPUT\HH_PROD.DBF",
  FORM=10.3, LIST = Z, P[1], P[2], P[3], P[4], P[5], P[6], DBF=T, 
  NAMES = TAZ, HBWP, NHBWP, HBOP, HBSCP, HBSHP, NHBOP
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\se_classified_{year}{Alternative}.dbf"

ZONES = {Total Zones}

LOOKUP LOOKUPI=1, NAME=hbw_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
LOOKUP LOOKUPI=2, NAME=nhbw_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0

LOOKUP LOOKUPI=3, NAME=hbo_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
LOOKUP LOOKUPI=4, NAME=hbschool_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
LOOKUP LOOKUPI=5, NAME=hbshop_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0

LOOKUP LOOKUPI=6, NAME=nhbo_lu,
  LOOKUP[1]=index, RESULT=vehicle0,
  LOOKUP[2]=index, RESULT=vehicle1,
  LOOKUP[3]=index, RESULT=vehicle2,
  LOOKUP[4]=index, RESULT=vehicle3,
  FAIL[3]=0
  
  
PROCESS PHASE=ILOOP
; This phase performs a zonal loop (I=1,Zones).  This phase is used to compute productions (P[#]=) and
; attractions (A[#]=) by zone.  Up to 20 P's and 20 A's can be computed in a single run.
  /*#
    #Work trip purposes use cross-classification tables of workers vehicles.
    #Other trip purposes use cross-classification tables of size and vehicles.
    #The input zone data contains the number of households in each zone for each
    #class. The production model works by taking this number of housheolds
    #and multiplying it by the average rate in the lookup tables.
  */

  ;# Home-based work productions
  P[1] = 0 +
    zi.1.w0v0 * hbw_lu(1, 1) + zi.1.w0v1 * hbw_lu(2, 1) + zi.1.w0v2 * hbw_lu(3, 1) + zi.1.w0v3 * hbw_lu(4, 1) +
    zi.1.w1v0 * hbw_lu(1, 2) + zi.1.w1v1 * hbw_lu(2, 2) + zi.1.w1v2 * hbw_lu(3, 2) + zi.1.w1v3 * hbw_lu(4, 2) +
    zi.1.w2v0 * hbw_lu(1, 3) + zi.1.w2v1 * hbw_lu(2, 3) + zi.1.w2v2 * hbw_lu(3, 3) + zi.1.w2v3 * hbw_lu(4, 3) +
    zi.1.w3v0 * hbw_lu(1, 4) + zi.1.w3v1 * hbw_lu(2, 4) + zi.1.w3v2 * hbw_lu(3, 4) + zi.1.w3v3 * hbw_lu(4, 4)
    
  ;# Non home-based work productions
  P[2] = 0 +
    zi.1.w0v0 * nhbw_lu(1, 1) + zi.1.w0v1 * nhbw_lu(2, 1) + zi.1.w0v2 * nhbw_lu(3, 1) + zi.1.w0v3 * nhbw_lu(4, 1) +
    zi.1.w1v0 * nhbw_lu(1, 2) + zi.1.w1v1 * nhbw_lu(2, 2) + zi.1.w1v2 * nhbw_lu(3, 2) + zi.1.w1v3 * nhbw_lu(4, 2) +
    zi.1.w2v0 * nhbw_lu(1, 3) + zi.1.w2v1 * nhbw_lu(2, 3) + zi.1.w2v2 * nhbw_lu(3, 3) + zi.1.w2v3 * nhbw_lu(4, 3) +
    zi.1.w3v0 * nhbw_lu(1, 4) + zi.1.w3v1 * nhbw_lu(2, 4) + zi.1.w3v2 * nhbw_lu(3, 4) + zi.1.w3v3 * nhbw_lu(4, 4)

  ;# Home-based other productions
  P[3] =
    zi.1.p1v0 * hbo_lu(1, 1) + zi.1.p1v1 * hbo_lu(2, 1) + zi.1.p1v2 * hbo_lu(3, 1) + zi.1.p1v3 * hbo_lu(4, 1) +
    zi.1.p2v0 * hbo_lu(1, 2) + zi.1.p2v1 * hbo_lu(2, 2) + zi.1.p2v2 * hbo_lu(3, 2) + zi.1.p2v3 * hbo_lu(4, 2) +
    zi.1.p3v0 * hbo_lu(1, 3) + zi.1.p3v1 * hbo_lu(2, 3) + zi.1.p3v2 * hbo_lu(3, 3) + zi.1.p3v3 * hbo_lu(4, 3) +
    zi.1.p4v0 * hbo_lu(1, 4) + zi.1.p4v1 * hbo_lu(2, 4) + zi.1.p4v2 * hbo_lu(3, 4) + zi.1.p4v3 * hbo_lu(4, 4)
    
 
  ;# Home-based school productions
  P[4] = 0 +
    zi.1.p1v0 * hbschool_lu(1, 1) + zi.1.p1v1 * hbschool_lu(2, 1) + zi.1.p1v2 * hbschool_lu(3, 1) + zi.1.p1v3 * hbschool_lu(4, 1) +
    zi.1.p2v0 * hbschool_lu(1, 2) + zi.1.p2v1 * hbschool_lu(2, 2) + zi.1.p2v2 * hbschool_lu(3, 2) + zi.1.p2v3 * hbschool_lu(4, 2) +
    zi.1.p3v0 * hbschool_lu(1, 3) + zi.1.p3v1 * hbschool_lu(2, 3) + zi.1.p3v2 * hbschool_lu(3, 3) + zi.1.p3v3 * hbschool_lu(4, 3) +
    zi.1.p4v0 * hbschool_lu(1, 4) + zi.1.p4v1 * hbschool_lu(2, 4) + zi.1.p4v2 * hbschool_lu(3, 4) + zi.1.p4v3 * hbschool_lu(4, 4)
    
  
  ;# Home-based shop productions
  P[5] = 0 +
    zi.1.p1v0 * hbshop_lu(1, 1) + zi.1.p1v1 * hbshop_lu(2, 1) + zi.1.p1v2 * hbshop_lu(3, 1) + zi.1.p1v3 * hbshop_lu(4, 1) +
    zi.1.p2v0 * hbshop_lu(1, 2) + zi.1.p2v1 * hbshop_lu(2, 2) + zi.1.p2v2 * hbshop_lu(3, 2) + zi.1.p2v3 * hbshop_lu(4, 2) +
    zi.1.p3v0 * hbshop_lu(1, 3) + zi.1.p3v1 * hbshop_lu(2, 3) + zi.1.p3v2 * hbshop_lu(3, 3) + zi.1.p3v3 * hbshop_lu(4, 3) +
    zi.1.p4v0 * hbshop_lu(1, 4) + zi.1.p4v1 * hbshop_lu(2, 4) + zi.1.p4v2 * hbshop_lu(3, 4) + zi.1.p4v3 * hbshop_lu(4, 4)
    
  ;# non-Home-based other productions
  P[6] = 0 +
    zi.1.p1v0 * nhbo_lu(1, 1) + zi.1.p1v1 * nhbo_lu(2, 1) + zi.1.p1v2 * nhbo_lu(3, 1) + zi.1.p1v3 * nhbo_lu(4, 1) +
    zi.1.p2v0 * nhbo_lu(1, 2) + zi.1.p2v1 * nhbo_lu(2, 2) + zi.1.p2v2 * nhbo_lu(3, 2) + zi.1.p2v3 * nhbo_lu(4, 2) +
    zi.1.p3v0 * nhbo_lu(1, 3) + zi.1.p3v1 * nhbo_lu(2, 3) + zi.1.p3v2 * nhbo_lu(3, 3) + zi.1.p3v3 * nhbo_lu(4, 3) +
    zi.1.p4v0 * nhbo_lu(1, 4) + zi.1.p4v1 * nhbo_lu(2, 4) + zi.1.p4v2 * nhbo_lu(3, 4) + zi.1.p4v3 * nhbo_lu(4, 4)
    
  p1v0 = zi.1.p1v0 * nhbo_lu(1, 1)
  p1v1 = zi.1.p1v1 * nhbo_lu(2, 1)
  p1v2 = zi.1.p1v2 * nhbo_lu(3, 1)
  p1v3 = zi.1.p1v3 * nhbo_lu(4, 1)
  p2v0 = zi.1.p2v0 * nhbo_lu(1, 2)
  p2v1 = zi.1.p2v1 * nhbo_lu(2, 2)
  p2v2 = zi.1.p2v2 * nhbo_lu(3, 2)
  p2v3 = zi.1.p2v3 * nhbo_lu(4, 2)
  p3v0 = zi.1.p3v0 * nhbo_lu(1, 3)
  p3v1 = zi.1.p3v1 * nhbo_lu(2, 3)
  p3v2 = zi.1.p3v2 * nhbo_lu(3, 3)
  p3v3 = zi.1.p3v3 * nhbo_lu(4, 3)
  p4v0 = zi.1.p4v0 * nhbo_lu(1, 4)
  p4v1 = zi.1.p4v1 * nhbo_lu(2, 4)
  p4v2 = zi.1.p4v2 * nhbo_lu(3, 4)
  p4v3 = zi.1.p4v3 * nhbo_lu(4, 4)
  all =
    p1v0 + p1v1 + p1v2 + p1v3 +
    p2v0 + p2v1 + p2v2 + p2v3 +
    p3v0 + p3v1 + p3v2 + p3v3 +
    p4v0 + p4v1 + p4v2 + p4v3
  

PRINT FORM = 10.10, CSV = T, LIST = Z, P[6], p1v0, p1v1, p1v2, p1v3, p2v0,
  p2v1, p2v2, p2v3, p3v0, p3v1, p3v2, p3v3, p4v0, p4v1, p4v2, p4v3, all,
  PRINTO = 1
    
    
ENDPROCESS


PROCESS PHASE=ADJUST
  /*
  # Implementation of a discrete choice model obviates the need to forecast
  # attractions, and therefore the need to balance
  */

  
ENDPROCESS

ENDRUN
