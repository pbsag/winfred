; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01MAT00S.PRN" MSG='FIND THE CLOSEST ZONE TO EACH LINK'
FILEO RECO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\CLOSEST.DBF",
FIELDS=A,B,ZN
FILEI ZDATI[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\XY.DAT",
Z=#1,X=#2,Y=#3
FILEI RECI = "{CATALOG_DIR}\Output\{Scenario_FullName}\LINK.DAT"

ZONES={Total zones}

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
      if (zi.1.x[iz] > 0)
        d = sqrt((zi.1.x[iz] - xmid)^2 + (zi.1.y[iz] - ymid)^2)
        if (d < dmin)
          dmin = d
          zn   = iz
        endif
      endif
    endloop

  endif

 A=RI.A
 B=RI.B
 WRITE RECO=1
 ; print list = ri.a,ri.b,zn, PRINTO=1


ENDRUN
