; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_2.PRN" MSG='FIND THE CLOSEST ZONE TO EACH LINK'
FILEI ZDATI[1] = "{SCENARIO_DIR}\Output\XY.dat",
 z = #1, x = #2, y = #3
FILEO RECO[1] = "{SCENARIO_DIR}\Output\CLOSEST.DBF",
FIELDS=A,B,ZN,DIST_XY
FILEI RECI = "{SCENARIO_DIR}\Output\LINK.DAT"

ZONES={Total ZONES}

; Zone number for centroid connectors is defined as the zone that
;  the connector connects to.
  if (ri.a <= zones || ri.b <= zones)
    zn = min(ri.a,ri.b)
  else

; Otherwise, calculate link midpoint.
    xmid = (ri.ax + ri.bx)/2
    ymid = (ri.ay + ri.by)/2

; Loop through the centroids to find the centroid nearest this midpoint.
    dmin = 999999
    zn   = 0

    loop iz = 1, {Total zones}
      if (zi.1.x[iz] <> 0)
        d = sqrt((zi.1.x[iz] - xmid)^2 + (zi.1.y[iz] - ymid)^2)
          
        if (d < dmin)
          dmin = d
          zn   = iz
          dist_xy = ri.dist_xy
        endif
      endif
    endloop

  endif

 A=RI.A
 B=RI.B
 WRITE RECO=1
 ; print list = ri.a,ri.b,zn, PRINTO=1


ENDRUN
