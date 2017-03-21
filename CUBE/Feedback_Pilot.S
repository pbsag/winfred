; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (FeedBack_ITER=1) 
FB_ITER = 1
*COPY {SCENARIO}\OUTPUT\PK_FreeFlow_Skim.MAT {SCENARIO}\OUTPUT\PK_CNG_HwySkim.MAT
*COPY {SCENARIO}\OUTPUT\OP_FreeFlow_Skim.MAT {SCENARIO}\OUTPUT\OP_CNG_HwySkim.MAT
;pk_hwy_skim = 'PK_FreeFlow_Skim.MAT'
;OP_hwy_skim = 'OP_FreeFlow_Skim.MAT'

ELSE 
;pk_hwy_skim = 'PK_CNG_HwySkim.MAT'
;OP_hwy_skim = 'OP_CNG_HwySkim.MAT'
ENDIF



