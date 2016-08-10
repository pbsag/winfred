
IF (PURPOSE=1) ; HBW PK
PURP='HBW'
MCLS_MAT = 'HBW'
PERIOD='PK'
PURPNO=1
MARKETS=1
isHBW=' '
noHBW=';'
isNHB=';'
noNHB=' '
PRINT LIST="Trip Distribution Loop Number = 1 of 4 HBW", printo=0

ELSEIF (PURPOSE=2) ; HBO 
PURP='HBO'
MCLS_MAT = 'HBO'
PERIOD='PK'
PURPNO=2
MARKETS=1
isHBW=';'
noHBW=' '
isNHB=';'
noNHB=' '
PRINT LIST="Trip Distribution Loop Number = 2 of 4 HBO ", printo=0

ELSEIF (PURPOSE=3) ; HBSH  
PURP='HBSH'
MCLS_MAT = 'HBO'
PERIOD='PK'
PURPNO=3
MARKETS=1
isHBW=';'
noHBW=' '
isNHB=';'
noNHB=' '
PRINT LIST="Trip Distribution Loop Number = 3 of 4 HBSH", printo=0

ELSEIF (PURPOSE=4) ; NHBW  
PURP='NHB'
MCLS_MAT = 'NHB'
PERIOD='PK'
PURPNO=4
MARKETS=1
isHBW=';'
noHBW=' '
isNHB=' '
noNHB=';'
PRINT LIST="Trip Distribution Loop Number = 4 of 4 NHB ", printo=0

ENDIF
