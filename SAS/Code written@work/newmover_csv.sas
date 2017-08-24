%include  "/project/DS_DEV/CODE/.mover_includes.inc";

data haha;
set nmsql.cogensia_movers(obs=1000);
run;

%flat (data =haha, droporkeep = keep, _vars = _all_, idvar = , path=,outfile =haha.csv, dd =N, write_flat=Y, ff_obs =max, dlm=| ,ffwhere=);
