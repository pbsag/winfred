; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

IF (FeedBack_ITER=1) 
*COPY "{SCENARIO_DIR}\OUTPUT\PK_FreeFlow_Skim.MAT" "{SCENARIO_DIR}\OUTPUT\PK_CNG_HwySkim.MAT" /y
*COPY "{SCENARIO_DIR}\OUTPUT\OP_FreeFlow_Skim.MAT" "{SCENARIO_DIR}\OUTPUT\OP_CNG_HwySkim.MAT" /y
;    pk_hwy_skim = 'PK_FreeFlow_Skim.MAT'
;    oP_hwy_skim = 'OP_FreeFlow_Skim.MAT'
;ELSE 
;  pk_hwy_skim = 'PK_CNG_HwySkim.MAT'
;  op_hwy_skim = 'OP_CNG_HwySkim.MAT'
ENDIF



