;;<<Default Template>><<PUBLIC TRANSPORT>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="{SCENARIO_DIR}\OUTPUT\LOGS\Trn_Assignment_PK.PRN" MSG='Transit Assignment'
FILEI NETI = "{SCENARIO_DIR}\Output\PK_TransitWalk.NET"
FILEI ROUTEI[2] = "{SCENARIO_DIR}\Output\PK_TPATHPrem.RTE"
FILEI ROUTEI[1] = "{SCENARIO_DIR}\Output\PK_TPATHBus.RTE"
FILEI MATI[1] = "{SCENARIO_DIR}\Output\PK_Transit.mat"

FILEO LINKO[1] = "{SCENARIO_DIR}\Output\Trn_PK.dbf",
 NTLEGS=T, ONOFFS=T
FILEO REPORTO = "{SCENARIO_DIR}\Output\Trn_PK.rpt"
FILEO NETO = "{SCENARIO_DIR}\Output\Trn_PK.net"

            ; OVERALL PARAMETERS OF RUN
            PARAMETERS NOROUTEMSGS=0, NOROUTEERRS=9999999, USERCLASSES=1-2,HDWAYPERIOD=1,
                TRIPSIJ[1]=MI.1.1,
                TRIPSIJ[2]=MI.1.2
            REPORT LINES=T, LINEVOLS=T
     
ENDRUN
