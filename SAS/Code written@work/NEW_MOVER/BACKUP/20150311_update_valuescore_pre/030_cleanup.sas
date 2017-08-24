%include "./.mover_includes.inc";

%macro cleanit;

*MOVE ALL RAW IMPORTED FILES INTO THE IMPORTED SUBFOLDER*;
   filename nmlst temp;
   data nmlsttemp;
      infile "./file_listing.txt";
      format filename $50.;
      input filename $;
      if index(filename,"gz") gt 0 and index(filename,"txt") gt 0 /* and substr(upcase(strip(filename)),1,2)="N0" */ then output;
   run;

   %nobs(data=nmlsttemp);
   %let pknobs=&nobs;

   data _null_;
      file nmlst;
      set nmlsttemp end=eof;
      if _n_=1 then put '%let nmlst=';
      put filename;
      if eof then put ';';
   run;

   %include nmlst;

%put LIST OF IMPORTED: &nmlst;

%do pk=1 %to &pknobs;
   x "mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/%scan(&nmlst,&pk,' ') /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED";
%end;

*MOVE ALL LOGS LSTS AND OTHER THINGS INTO TIMESTAMPED FILES IN SUBFOLDER*;
x "mv ./010_mover_import.log ./LOGS/010_mover_import_&tdate..log";
x "mv ./010_mover_import.lst ./LOGS/010_mover_import_&tdate..lst";
x "mv ./020_mover_processing.log ./LOGS/020_mover_processing_&tdate..log";
x "mv ./020_mover_processing.lst ./LOGS/020_mover_processing_&tdate..lst";
x "mv ./qc_report*htm ./LOGS";
x "mv ./file_listing.txt ./LOGS/file_listing_&tdate..txt";

*MOVE ALL SUPPORTING DOCUMENTATION FOR RAW DATA INTO DOCUMENTATION SUBFOLDER*;
x "mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/*.html /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/DOCUMENTATION";
x "mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/*xml /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/DOCUMENTATION";
x "mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/*rtf /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/DOCUMENTATION";
x "mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/*PDF /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/DOCUMENTATION";

*GZIP SAS DATASET*;
x "gzip /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/SAS/*.sas7bdat";

*DELETE SAS DATASET IF 30 DAYS OLD*;
%global deldt;
data _null_;
   format newdt date9.;
   newdt=today()-30;
   day=put(day(newdt),z2.);
   mo=put(newdt,monname3.);
   yr=substr(put(year(newdt),4.),3,2);
   deldt=compress("/project/CACDIRECT/DATA/NEW_MOVER/EPSILON/SAS/new_mover_"||day||lowcase(mo)||yr||".sas7bdat.gz");
   call symput("deldt",deldt);
run;
%put DELETE FILENAME: &deldt;

%if %sysfunc(fileexist(&deldt)) %then %do;
   x "rm &deldt";
%end;

%mend cleanit;
%cleanit;
