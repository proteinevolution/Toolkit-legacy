#!/bin/bash

. /cluster/opt/sge/default/common/settings.sh

# Parse command line arguments
while getopts f:s OPT; do
    case "$OPT" in
        f)
            OUTPUTFILE=$OPTARG
            ;;
        s)
            short=true
            ;;
    esac
done

# count jobs (line doesnt start with job-ID or -
data_num=$(qstat -u www-data | grep ^[^job-ID\|-] | wc -l)
toolkit_num=$(qstat -u toolkit | grep ^[^job-ID\|-] | wc -l)
toolkitmgr_num=$(qstat -u toolkitmgr | grep ^[^job-ID\|-] | wc -l)
tot_lines=$((${data_num}+${toolkit_num}+${toolkitmgr_num}))

# write total number of jobs to OUTPUTFILE
if [ $short ]; then
    echo $tot_lines > $OUTPUTFILE

# count number of running and queued jobs
else
    data_running=$(qstat -u www-data | grep " r " | wc -l)
    data_queued=$(qstat -u www-data | grep " qw " | wc -l)
    toolkit_running=$(qstat -u toolkit | grep " r " | wc -l)
    toolkit_queued=$(qstat -u toolkit | grep " qw " | wc -l)
    toolkitmgr_running=$(qstat -u toolkitmgr | grep " r " | wc -l)
    toolkitmgr_queued=$(qstat -u toolkitmgr | grep " qw " | wc -l)

    tot_running=$((${data_running}+${toolkit_running}+${toolkitmgr_running}))
    tot_queued=$((${data_queued}+${toolkit_queued}+${toolkitmgr_queued}))

    echo $tot_running "jobs are running" > $OUTPUTFILE
    echo $tot_queued "jobs are queued" >> $OUTPUTFILE
fi
