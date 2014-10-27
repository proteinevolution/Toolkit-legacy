-- add jobs count and times to be able to provide average job time
alter table stats
   add column (jobs_count int default 0,
       	       jobs_time  int default 0);
