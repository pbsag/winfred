; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\WMMAT00D.PRN"
FILEI MATI[2] = "{CATALOG_DIR}\Output\{Scenario_FullName}\Cong_Skim.MAT"
FILEI MATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\03DST00A.MAT"
FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\REPORTS\Model_Area_Trip_Chracterstics.DBF",
FIELDS=purpose,time,distance,code



; The MATRIX module does not have any explicit phases.  The module does run within an implied ILOOP
; where I is the origin zones.  All user statements in the module are processed once for each origin.
; Matrix computation (MW[#]=) are solved for all values of J for each I.  Thus for a given origin zone I
; the values for all destination zones J are automatically computed.  The user can control the computations
; at each J by using a JLOOP.


zones={Total Zones}

;For Harrisonburg Region

   mw[1]=mi.1.1                          ;HBW Person Trips
   mw[2]=mi.1.2                          ;HBSch Person Trips
   mw[3]=mi.1.3                          ;HBO Person Trips

   mw[4]=mi.1.4                            ;total
   mw[9]=mi.2.4                          ;Uncongested Times with Terminal Times
   mw[10]=mi.2.2                          ;Uncongested Distances with Terminal Distances

array time=4, dist=4, trips=4
array cnty_time=4, cnty_dist=4, cnty_trips=4
array city_time=4, city_dist=4, city_trips=4


;**************************************************************************************************
;                                          Frederick County w/o City
;**************************************************************************************************
if(z<111 || z=136 || z=163 || z>167)

loop iter=1,4
   mw[13]=mw[iter]*mw[9]                  ;Time calculation
   mw[14]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   city_time[iter]=rowsum(13)+city_time[iter]
   city_dist[iter]=rowsum(14)+city_dist[iter]
   city_trips[iter]=rowsum(iter)+city_trips[iter]
elseif (i=169)
   city_time[4]=city_time[1]+city_time[2]+city_time[3]
   city_dist[4]=city_dist[1]+city_dist[2]+city_dist[3]
   city_trips[4]=city_trips[1]+city_trips[2]+city_trips[3]
endif

if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if(i=169)
    ro.purpose=iters
    ro.time=city_time[iter]/city_trips[iter]
    ro.distance=city_dist[iter]/city_trips[iter]
    code=1
    write reco=1 ; 2
endif

endloop

endif


;**************************************************************************************************
;                                          Winchester City
;**************************************************************************************************

if(z=111-135 || z=137-162 || z=164-167)

loop iter=1,4
   mw[13]=mw[iter]*mw[9]                  ;Time calculation
   mw[14]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   cnty_time[iter]=rowsum(13)+cnty_time[iter]
   cnty_dist[iter]=rowsum(14)+cnty_dist[iter]
   cnty_trips[iter]=rowsum(iter)+cnty_trips[iter]
elseif (i=167)
   cnty_time[4]=cnty_time[1]+cnty_time[2]+cnty_time[3]
   cnty_dist[4]=cnty_dist[1]+cnty_dist[2]+cnty_dist[3]
   cnty_trips[4]=cnty_trips[1]+cnty_trips[2]+cnty_trips[3]
endif

if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if(i=167)
    ro.purpose=iters
    ro.time=cnty_time[iter]/cnty_trips[iter]
    ro.distance=cnty_dist[iter]/cnty_trips[iter]
    code=2
    write reco=1  ;3
endif

endloop

endif



;**************************************************************************************************
;                                          Model Region
;**************************************************************************************************

loop iter=1,4
   mw[11]=mw[iter]*mw[9]                  ;Time calculation
   mw[12]=mw[iter]*mw[10]           ;Distance calculation
if (iter<4)
   time[iter]=rowsum(11)+time[iter]
   dist[iter]=rowsum(12)+dist[iter]
   trips[iter]=rowsum(iter)+trips[iter]
elseif (i=zones)
   time[4]=time[1]+time[2]+time[3]
   dist[4]=dist[1]+dist[2]+dist[3]
   trips[4]=trips[1]+trips[2]+trips[3]
endif


if (iter=1) comp iters='HBW'
if (iter=2) comp iters='HBO'
if (iter=3) comp iters='NHB'
if (iter=4) comp iters='Total'

if (i=zones)
    ro.purpose=iters
    ro.time=time[iter]/trips[iter]
    ro.distance=dist[iter]/trips[iter]
    code=3
    write reco=1
endif

endloop


;***************************************************************************************
;***************************************************************************************



ENDRUN
