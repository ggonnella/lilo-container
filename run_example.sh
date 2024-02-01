#!/bin/bash
MEDAKA=r104_e81_sup_g5015
#RAW=/srv/giorgio/virology/ASFV/reads/20230908_03_R10/20230908_AFS_Run_03_R10/raw
RAW=/srv/giorgio/virology/ASFV/reads/20230908_03_R10/tmp3
./run_container.sh $RAW $MEDAKA
