drop table if exists jobs;
create table jobs (
  id                    int             not null auto_increment,
  type                  varchar(50)     null,
  parent_id             int             null,
  jobid                 varchar(100)    null,
  user_id               int             null,
  status                char(1)         null,
  tool                  varchar(100)    null,
  created_on            datetime        null,
  updated_on            datetime        null,
  viewed_on             datetime        null,
  primary key (id)
);

drop table if exists actions;
create table actions (
  id                    int             not null auto_increment,
  status                char(1)         default 'i',
  params                longtext        null,
  job_id                int             not null,
  type                  varchar(50)     null,
  forward_controller    varchar(100)    null,
  forward_action        varchar(100)    null,
  flash                 text            null,
  active                bool            default 1,
  created_on            datetime        null,
  primary key (id)
);

drop table if exists users;
CREATE TABLE users (
  id                    INTEGER UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  login                 VARCHAR(80) NOT NULL,
  salted_password VARCHAR(40) NOT NULL,
  firstname VARCHAR(40),
  lastname      VARCHAR(40),
  institute varchar(100)        null,
  street                varchar(100)    null,
  city          varchar(100)    null,
  country       varchar(100)    null,
  groups                varchar(50) default 'member',
  modeller_key  varchar(20) null,
  salt          CHAR(40)  null,
  verified      INT default 0,
  role          VARCHAR(40) default NULL,
  security_token CHAR(40) default NULL,
  token_expiry DATETIME default NULL,
  created_at DATETIME default NULL,
  updated_at DATETIME default NULL,
  logged_in_at DATETIME default NULL,
  deleted       INT default 0,
  delete_after DATETIME default NULL
);

drop table if exists userdbs;
CREATE TABLE userdbs (
  id                                    INTEGER UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name                          varchar(50) not null,
  dbtype                                varchar(1)      not null,
  size                          int                     not null,
  path                          text                    not null,
  user_id                       int                     null,
  sessionid                     varchar(50)     null,
  formatted                     bool                    default 0,
  created_on            datetime        null
);

drop table if exists queue_jobs;
create table queue_jobs (
  id                    int             not null auto_increment,
  status                char(1)         default 'i',
  final                 bool            default 1,
  parallel              bool            default 0,
  options               text            null,
  action_id             int             not null,
  commands              text            null,
  parent_id             int             null,
  on_done               varchar(100)    null,
  on_error              varchar(100)    null,
  created_on            datetime        null,
  primary key (id)
);

drop table if exists queue_workers;
create table queue_workers (
  id                    int             not null auto_increment,
  type                  varchar(50)     not null,
  status                char(1)         default 'i',
  commands              text            not null,
  commandfile           varchar(100)    null,
  wrapperfile           varchar(100)    null,
  queue_job_id          int             not null,
  qid                   varchar(100)    default 0,
  pid                   int             default 0,
  options               text            null,
  created_on            datetime        null,
  primary key (id)
);

drop table if exists stats;
create table stats (
  id                    int             not null auto_increment,
  toolname              varchar(50)     not null,
  visits_int            int             default 0,
  visits_ext            int             default 0,
  visits_user           int             default 0,
  day                   varchar(10)     null,
  primary key (id)
);

DROP TABLE IF EXISTS watchlists;
CREATE TABLE watchlists (
  id                    int             NOT NULL auto_increment,
  user_id               int             default '0',
  path                  varchar(200)    default NULL,
  name                  varchar(60)     NOT NULL,
  length                int             default '0',
  job_id                int             default '0',
  str_id                int             default '0',
  probability           float           default '0',
  created_on            datetime        default NULL,
  updated_on            datetime        default NULL,
  warning_key           int             default '0',
  params                text            default NULL,
  PRIMARY KEY  (id)
)
