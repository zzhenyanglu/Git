/* HEY DONT RUN THIS JOB UNLESS THE REGULAR PROCESS HAS CRASHED */

drop table if exists cogensia_movers;

create table cogensia_movers(like cogensia_movers_bak);

insert into cogensia_movers select * from cogensia_movers_bak;

