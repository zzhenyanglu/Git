#!/bin/bash

# HEY DONT RUN THIS JOB UNLESS REGULAR WEEKLY UPDATE HAS ALREADY CRASHED 
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U ais --port=5432 dbname=cac_prod -f /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/006_restore_cogensia_movers

