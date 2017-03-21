; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (PURPOSE=1) ; HBW Purpose
PURP='HBW'
PURPNO=3
PRK='LONGPARK'
hwySkim = 'pk_Hwyskim.MAT'
busSkim = 'pk_TSKIMBus.MAT'
premSkim = 'PK_TSKIMPrem.MAT'

ELSEIF (PURPOSE=2) ; HBO Purpose
PURP='HBO'
PURPNO=4
PRK='LONGPARK'
hwySkim = 'op_Hwyskim.MAT'
busSkim = 'op_TSKIMBus.MAT'
premSkim = 'op_TSKIMPrem.MAT'

ELSEIF (PURPOSE=3) ; NHB Purpose
PURP='NHB'
PURPNO=5
PRK='LONGPARK'
hwySkim = 'op_Hwyskim.MAT'
busSkim = 'op_TSKIMBus.MAT'
premSkim = 'op_TSKIMPrem.MAT'

ELSEIF (PURPOSE=4) ; HBSC Purpose
PURP='HBSC'
PURPNO=6
PRK='LONGPARK'
hwySkim = 'op_Hwyskim.MAT'
busSkim = 'op_TSKIMBus.MAT'
premSkim = 'op_TSKIMPrem.MAT'
ENDIF

