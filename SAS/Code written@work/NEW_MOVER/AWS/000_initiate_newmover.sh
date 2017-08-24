#!/bin/bash

# RUN THE SQL SCRIPTS ON AWS ACCORDINGLY
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U newmover --port=5432 dbname=cac_prod -f /project/CACDIRECT/CODE/PROD/NEW_MOVER/AWS/000_initiate_cogensia_movers_onetime.sql 

