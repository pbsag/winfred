; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK PRNFILE="{CATALOG_DIR}\Output\{Scenario_FullName}\LOGS\01NET00C.PRN" MSG='OUTPUT LINK AND ZONE DATA'
FILEO PRINTO[1] = "{CATALOG_DIR}\Output\{Scenario_FullName}\XY.DAT"
FILEO NODEO = "{CATALOG_DIR}\Output\{Scenario_FullName}\NODE.DAT"
FILEO LINKO = "{CATALOG_DIR}\Output\{Scenario_FullName}\LINK.DAT"
FILEI LINKI[1] = "{SCENARIO_DIR}\WF_{Year}{ALT}.NET"

ARRAY _CNT={Total zones},_CENTX={Total zones},_CENTY={Total zones},_CENT={Total zones},
      _NO=99999,_MIDX=99999,_MIDY=99999,_MID_POINT=99999,_NO=99999,XMILES=999999,
      YMILES=999999

PHASE=NODEMERGE

IF(n<={Total zones})

PRINT form=20.3 LIST=N,X,Y, PRINTO=1
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

;calculate distance between the links

;distance=(sqrt((a.x-b.x)^2+(a.y-b.y)^2))*0.000621371192237334

IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X<B.X) ROADDIR='EB' ;east bound
IF (ABS(A.X-B.X)>ABS(A.Y-B.Y)&A.X>B.X) ROADDIR='WB' ; west bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y<B.Y) ROADDIR='NB' ; north bound
IF (ABS(A.X-B.X)<ABS(A.Y-B.Y)&A.Y>B.Y) ROADDIR='SB' ; south bound

ENDPHASE

ENDRUN
