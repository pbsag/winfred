;FILEO PRINTO[1] = "{SCENARIO_DIR}\OUTPUT\LINK_CAPACITY.PRN"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

; **NOTE THAT PILOT PROGRAMS TAKE NO INPUTS OR OUTPUTS IN THE APPLICATION MANAGER**
; set location of R executable
Rexe = '{CATALOG_DIR}\R\R-3.2.2\bin\Rscript.exe'

; set location of R script that runs the classification step
Rscript = '{CATALOG_DIR}\R\calculate_capacities.R'

; Collect arguments for R script.
link_file = '{SCENARIO_DIR}\Output\link_atype{Year}{Alternative}.DBF'
output_file = '{SCENARIO_DIR}\Output\link_capacities{Year}{Alternative}.DBF'

; Write batch file to run R model
PRINT LIST= Rexe ' ' Rscript ' ' link_file ' ' output_file, 
 FILE = "{CATALOG_DIR}\CUBE\LINK_CALC.BAT"
  
; Duplicate command in print file
;PRINT LIST= Rexe ' ' Rscript ' ' input_se_file ' ' output_file, 
; PRINTO = 1

; Run batch file from command line
*{CATALOG_DIR}\CUBE\LINK_CALC.BAT

