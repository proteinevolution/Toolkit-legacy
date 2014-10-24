-- add possible reference to job statistics to job table
alter table jobs
   add column stat_id int null
   after tool
