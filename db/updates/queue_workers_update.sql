-- add execution time column
alter table queue_workers
   add column exec_time int default 0
   after pid;