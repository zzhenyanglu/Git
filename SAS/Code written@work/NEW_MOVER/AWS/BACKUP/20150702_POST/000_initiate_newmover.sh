#!/bin/bash

# RUN THE SQL SCRIPTS ON AWS ACCORDINGLY
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U ais --port=5432 dbname=cac_prod -f /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/000_initiate_cogensia_movers_onetime 

