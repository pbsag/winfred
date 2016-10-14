; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{SCENARIO_DIR}\Output\LOGS\AT_1.PRN" MSG='OUTPUT LINK AND ZONE DATA'
FILEI LINKI[1] = "{SCENARIO_DIR}\OUTPUT\highway_clean.net"
FILEO PRINTO[1] = "{SCENARIO_DIR}\Output\XY.dat"
FILEO NODEO = "{SCENARIO_DIR}\Output\NODE.DAT"
FILEO LINKO = "{SCENARIO_DIR}\Output\LINK.DAT"

ARRAY _CNT={Total zones},_CENTX={Total zones},_CENTY={Total zones},_CENT={Total zones},
      _NO=99999,_MIDX=99999,_MIDY=99999,_MID_POINT=99999,_NO=99999,XMILES=999999,
      YMILES=999999,DIST=99999

PHASE=NODEMERGE


IF(n<={Total zones})

PRINT LIST=N,X(20.5),Y(20.5), PRINTO=1
;  _CNT=_CNT+1
;  _CENT[_CNT]=N
;  _CENTX[_CNT]=X
;  _CENTY[_CNT]=Y
;  _BB=_BB+1
;  Z=_BB
;PRINT LIST=_CNT,_CENT[_CNT],_CENTX[_CNT],_CENTY[_CNT],N,X,Y
ENDIF

ENDPHASE

PHASE=LINKMERGE

AX=A.X
BX=B.X
AY=A.Y
BY=B.Y

;calculate the link distance in straight-line coordinates

dist_xy =(sqrt((a.x-b.x)^2+(a.y-b.y)^2)) / 5280  ; convert feet to miles

;# determine the average directionality of the link.
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X<B.X) ROADDIR='EB' ;east bound
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X>B.X) ROADDIR='WB' ; west bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y<B.Y) ROADDIR='NB' ; north bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y>B.Y) ROADDIR='SB' ; south bound

ENDPHASE

ENDRUN
