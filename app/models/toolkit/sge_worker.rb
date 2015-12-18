class SgeWorker < AbstractWorker
  set_table_name "queue_workers"
  belongs_to :queue_job
  
  def execute
    basename = File.join(queue_job.action.job.job_dir, id.to_s)
    self.commandfile = basename+".sh"
    self.wrapperfile = basename+"wrapper.sh"    
    writeShWrapperFile(basename)
    writeShCmdsFile(basename)
    self.status = STATUS_QUEUED
    save!
    self.queue_job.update_status
    
    tries = 0

    if LOCATION == "Tuebingen"
      #if RAILS_ENV == "development"
        # Parameter -p 10 not available on OLT, try to specify short queue in local_environment.rb
        #command = "#{QUEUE_DIR}/qsub -p 10 #{self.wrapperfile}"
      #else
        command = "#{QUEUE_DIR}/qsub #{self.wrapperfile}"
        logger.debug "L23 qsub command: #{command}"
      #end
    else
      # LOCATION = Munich !!  
      if LINUX == "SL6"
        #command = "#{QUEUE_DIR}/qsub -pe threadssl6.pe 1 #{self.wrapperfile}" 
        command = "#{QUEUE_DIR}/qsub  #{self.wrapperfile}"
        logger.debug "L30 qsub command: #{command}"
      else
        command = "#{QUEUE_DIR}/qsub  #{self.wrapperfile}"
      end
    end
    
    logger.debug "L36 ID"+`id`
    # Remove all Line Carriage characters from returned result command
    res = `#{command}`.chomp
    logger.debug "L39 Original  QID: #{res}"
    self.qid = res.gsub(/Your job (\d+) .*$/, '\1')
    logger.debug "L41 Substituded QID: #{qid}"
    
    while (!$?.success? && tries < 5)
      tries += 1
      logger.debug "L45 Try no. #{tries} in  PE Queue"
      res = `#{command}`.chomp
 
      self.qid = res.gsub(/Your job (\d+) .*$/, '\1')
      logger.debug "L49 Job has QID #{qid}"
    end
    save!
    if (!$?.success? && tries == 5)
      raise "Unable to submit job!"
    end
    # Avoid parallel writing to .exec_host file?
    # For administration, it's more convenient to have easily the qid of waiting jobs.
    # If that leads to problems, get JOB_ID in wrapper file below.
    system("echo 'QID #{qid}' >> #{basename}.exec_host")
  end

  def stop
    # possible improvement: synchronize with execute method and with cleaning
    # up of directory (see Job.remove).

    # in case the job just has been submitted, it still might be in the
    # execute method and qid is not set yet.
    if !self.qid
      # don't wait, better improve synchronization.
      logger.debug "L69 No qid available (yet) for stopping worker #{id}"
    end

    if self.qid
      command = "#{QUEUE_DIR}/qdel #{qid}"
      logger.debug "L74: Worker command: #{command}"
      system(command)
    end
  end
  
  # creates a shell wrapper file for all jobcomputations-commands that are executed on the queue, sets the status of the job
  # this must be a wrapper to be able to print to stdout and stderr files when disk file size limit is reached in the subshell.
  def writeShWrapperFile(basename)
    queue = QUEUES[:normal]
    cpus = nil
    additional = false
    timelimit = nil
    warningtimelimit = nil

    if (!options.nil? || !options.empty?)
      if (options['queue']) then queue = options['queue'] end
      if (options['cpus']) then cpus = options['cpus'] end
      if (options['additional']) then additional = true end
    end
    if (defined? QUEUETIMELIMITS && QUEUETIMELIMITS) then
      timelimit = QUEUETIMELIMITS[QUEUES.index(queue)]
    end
    usequeue = queue && queue != "" && queue[0] != "-"[0]

    begin
      f = File.open(self.wrapperfile, 'w')
      f.write "#!/bin/bash\n"
      #f.write "#!/bin/sh\n"
      # SGE options
      toolShortcut = makeSGEname(getToolShortcut || "TOOLKIT")
      # truncate toolShortcut to 7 characters because qstat only shows 10
      # characters in its tabular view.
      f.write '#$' + " -N #{toolShortcut[0...7]}_#{queue_job.action.job.jobid}\n"

      if LINUX == 'SL6'
          f.write '#$' + " -pe #{queue}\n"
          #f.write '#$' + " -q #{queue}\n"
      else
        if (cpus && cpus.to_i > 1)
          f.write '#$' + " -pe parallel #{cpus}\n"
        end
        if usequeue
          # for compatibility only
          f.write '#$' + " -q #{queue}\n"
        end
      end
      if LOCATION != "Tuebingen" && RAILS_ENV == "development"
        if queue == "express.q"
          f.write '#$' + " -l express=TRUE\n"
        end
      end

      if LOCATION == "Tuebingen"
        # The switches -l immediate and -l long are used
        # only to select the immediate/long queue
        if usequeue # (RAILS_ENV == "production")
          if queue == QUEUES[:long]
            f.write '#$' + " -l long\n"
          else
            if queue == QUEUES[:immediate]
              f.write '#$' + " -l immediate\n"
            end
          end
        end
        # else: The sge setup for the test and development systems
        # does not supply the immediate/long ressource. Appropriate
        # replacements are not known.
        # Direct execution on the web server is very problematic.
        # Therefore, that's avoided even in the immediate case.
      end

      if (timelimit)
        delaytime=300
        # delaytime interval [s] in which the system is supposed to react.
        # It should be large enough, that the resulting s_rt value still
        # qualifies jobs for the short queue, if h_rt would allow for the
        # short queue.
        # => delaytime should be at least the difference between the queue
        # limits of h_rt and s_rt.
        f.write '#$' + " -l h_rt=#{timelimit}\n"
        warningtimelimit = SgeWorker.addSeconds2Timelimit(-delaytime, timelimit)
        if USE_SOFT_LIMITS && (warningtimelimit > delaytime)
          f.write '#$' + " -l s_rt=#{warningtimelimit}\n"
        else
          warningtimelimit = nil
        end
        # These timelimits of the wrapper file can be overwritten in the command
        # line
      end

      # Location Tuebingen, using variable memory limiting to circumvent memory constraints and queue crowding
      if LOCATION == "Tuebingen"
        # Identify the Action which is to be submitted by the toolkit and set the max Memory count to a individual value
        action_classname = queue_job.action.type # inherited from ActiveRecord
        # Memory contains the Nr of GB used for Tuebinger Queue
        memory = select_memory(action_classname);
        if (cpus && cpus.to_i > 1)
          # The sge engine will multiply the given memory with the number of cpus
          min_cpu_number = cpus.to_i
          memory = (memory + min_cpu_number - 1) / min_cpu_number
        end
        logger.debug "L175 Memory #{memory} "

        f.write '#$' + " -l h_vmem=#{memory}G\n"
        if USE_SOFT_LIMITS
          # to get a signal before SIGKILL, we define a warning memory limit, which is 100M below memory.
          warning_memory = memory * 1024 - 100
          f.write '#$' + " -l s_vmem=#{warning_memory}M\n"
        end
      end

      f.write '#$' + " -wd #{queue_job.action.job.job_dir}\n"
      f.write '#$' + " -o #{queue_job.action.job.job_dir}\n"
      f.write '#$' + " -e #{queue_job.action.job.job_dir}\n"
      f.write '#$' + " -notify\n" # to handle resource limits not specified in sge_worker.rb
      f.write '#$' + " -w n\n"

      # Source all modules on SL6
      if LINUX == 'SL6'
        f.write "source /etc/profile\n"
        f.write "export RUBYLIB=#{RUBY_LIB}  \n"
        f.write "export GEM_HOME=#{GEM_HOME} \n"
        f.write "env \n"
      end

      f.write "sig_handler() {\n"
      f.write "  if [[ $REPEATED != *$1* ]]\n"
      f.write "  then\n"
      f.write "    REPEATED=\"$REPEATED\"\" $1\"\n"
      write_qupdate_call(f, id, STATUS_ERROR, "    ","")

      f.write "    echo >> #{queue_job.action.job.statuslog_path}\n"
      f.write "    case \"$1\" in\n"

      if warningtimelimit
        f.write "        USR1) echo \"Probably grid time limit reached. Job terminating.\" >> #{queue_job.action.job.statuslog_path}\n"
        f.write "            ;;\n"
      else
        f.write "        USR1) echo \"Signal caught: SIG$1. Program stopped, job terminating.\" >> #{queue_job.action.job.statuslog_path}\n"
        f.write "            ;;\n"
      end
      f.write "        USR2) echo \"Termination of job by user or because of reaching a resource limit.\" >> #{queue_job.action.job.statuslog_path}\n"
      f.write "            ;;\n"
      # Signal SIGXCPU only used in Tuebingen in this way (see trap calls)
      if LOCATION == "Tuebingen" && USE_SOFT_LIMITS
        f.write "        XCPU) echo \"Grid memory limit reached. Job terminating.\" >> #{queue_job.action.job.statuslog_path}\n"
        f.write "            ;;\n"
      end
      # Always provide this "otherwise" case for detecting incorrect or additional installations of this signal handler
      f.write "        *) echo \"Signal caught: SIG$1.\" >> #{queue_job.action.job.statuslog_path}\n"
      f.write "            ;;\n"
      f.write "    esac\n"
      # let the shell script determine the exception
      # f.write "    exit\n"
      f.write "  fi\n"
      f.write "}\n\n"

      f.write "export TK_ROOT=" + TOOLKIT_ROOT + "\n"

      f.write "echo \"HOSTNAME `hostname`\" >> #{basename}.exec_host\n"
      # is equivalent to f.write "echo \"HOSTNAME $HOSTNAME\" >> #{basename}.exec_host\n"
      # JOB_ID is same as QID. If storing QID leads to problems, use that instead:
      # f.write "echo \"JOB_ID $JOB_ID\" >> #{basename}.exec_host\n"
      # Not required, because currently the tools don't submit array jobs:
      # f.write "echo \"SGE_TASK_ID $SGE_TASK_ID\" >> #{basename}.exec_host\n"
      if RAILS_ENV == "development"
        f.write "echo 'Starting job #{id.to_s}...' >> #{queue_job.action.job.statuslog_path}\n"
      end

      # SET STATUS OF THIS JOB TO RUNNING
      write_qupdate_call(f, id, STATUS_RUNNING, "","")
      if RAILS_ENV == "development"
        f.write "echo 'Status set to running...' >> #{queue_job.action.job.statuslog_path}\n"
      end
      f.write "REPEATED=\"\"\n"

      # handles signals caused by -notify and hard limits
      f.write "trap 'sig_handler USR2' USR2\n"

      # handles signals caused by -notify and, only used in case of
      # warningtimelimit
      # signals caused by -l s_rt (or probably other reasons)
      f.write "trap 'sig_handler USR1' USR1\n"

      if LOCATION == "Tuebingen" && USE_SOFT_LIMITS

        # handles signals caused by -l s_vmem
        f.write "trap 'sig_handler XCPU' XCPU\n"

      end

      # ALL THE SUBSHELL SCRIPT 
      if RAILS_ENV == "development"
        f.write "echo 'Before executing the commandfile...' #{self.commandfile} >> #{queue_job.action.job.statuslog_path}\n"
      end

      #f.write "#{self.commandfile}\n"
      f.write "{ { _utime=\"$( { { TIMEFORMAT='%0U';time (#{self.commandfile} 1>&4 2>&3); } 3>&2 2>&1; } )\"; } 4>&1 1>&3; } 3>/dev/null\n"
      # CAPTURE EXITSTATUS OF THE 'CHILD'-SHELL SCRIPT WHICH IS SAVED IN $? INTO A VARIABLE WITH THE SAME NAME IN THIS SHELL 
      f.write "exitstatus=$?\n"
      # were there any errors?
      if (additional == true)
        if RAILS_ENV == "development"
          f.write "echo 'Running Additional Script '\n"
        end
        write_qupdate_call(f, id, STATUS_DONE, "","_utime")

        if RAILS_ENV == "development"
          f.write "echo 'Running under developement environment ' >> #{queue_job.action.job.statuslog_path}\n"
        end

      else
        f.write "if [ ${exitstatus} -eq 0 ] ; then\n"
        if RAILS_ENV == "development"
          f.write "  echo \"Queue worker #{id.to_s} DONE! (${_utime}s cpu time)\" >> #{queue_job.action.job.statuslog_path}\n"
        end
        write_qupdate_call(f, id, STATUS_DONE, "  ","_utime")
        f.write "else\n"
        write_qupdate_call(f, id, STATUS_ERROR, "  ", "_utime")
        f.write "  echo 'Error while executing Job!' >> #{queue_job.action.job.statuslog_path}\n"
        if RAILS_ENV == "development"
          f.write "  echo \"Used ${_utime}s cpu time, exit status ${exitstatus}\" >> #{queue_job.action.job.statuslog_path}\n"
        end
        f.write "fi\n"
      end
      f.chmod(0755)
      f.close
    rescue  Exception => e
      raise "Unable to create Wrapperfile #{self.wrapperfile} in #{self.class} id: #{id}.\n#{e.message}\n"
    end
  end
  
  # creates a jobcomputation-commands file (sh script) + minimal errorhandling and limiting of memory and disk-file-size
  # if a program does not return 0 the subsequent commands are not executed and the script exits
  def writeShCmdsFile(basename)
    begin
      f = File.open(self.commandfile, 'w')
      f.write "#!/bin/bash\n"
      # f.write "#!/bin/sh\n"
      # FILE SIZE LIMIT 1Gb (1024 * 1000000), MEMORY LIMIT 6Gb (see man bash -> ulimit)
      f.write "ulimit -f 1000000\n" #-m 6000000\n"
      f.write "export TK_ROOT=#{ENV['TK_ROOT']}\n"
      if (LOCATION == "Tuebingen" && RAILS_ENV == "development")
        f.write "export PATH=/usr/local/bin:/usr/bin:/bin:\n"
      end
      # Have to decide where the module load shall be put ....
      if (LOCATION == 'Munich' && LINUX == 'SL6')
        logger.debug "L321 Location Munich Source etc/profiles "
        f.write "source /etc/profile\n"
        f.write "module load perl\n"
        f.write "module load python2.6\n"
      end
      # print the process id of this shell execution
      f.write "echo \"PID $$\" >> #{basename}.exec_host\n"
      logger.debug "L328 Exec_host file written."
      if (!(options.nil? || options.empty?) && options['ncpuvar'])
        ncpuvar=options['ncpuvar']
        if (options['cpus']) then
          min_cpu_number = options['cpus'].to_i()
        else
          min_cpu_number = 1
        end
        # $NSLOTS gives the number of allocated cpus on the sge cluster,
        # when the job was submitted using qsub.
        # Otherwise, it has to initialized with the minimum cpus value.
        f.write "#{ncpuvar}=${NSLOTS:-#{min_cpu_number}}\n"
      end
      f.write "exitstatus=0;\n"

      commands.each do |cmd|
        f.write"if [ ${exitstatus} -eq 0 ] ; then\n"
        f.write"#{cmd}\n"
        f.write"exitstatus=$?\n"
        f.write"if [ ${exitstatus} -ne 0 ] ; then\n"
        f.write"echo 'Error executing #{cmd} ' >> #{queue_job.action.job.statuslog_path}\n"   
        f.write"echo 'Exit status '${exitstatus} >> #{queue_job.action.job.statuslog_path}\n"
        f.write"fi\n"
        f.write"fi\n"
      end
      
      # RETURN EXITSTATUS OF THE 'CHILD'-SHELL SCRIPT
      f.write"exit ${exitstatus}\n"
      f.chmod(0755)
      f.close
    rescue  Exception => e
      raise "Unable to create Commandfile #{self.commandfile} in #{self.class} id: #{id}.\n#{e.message}\n"
    end
  end

  #########################################################################################
  # Individualized Memory Management for each tool
  # It should return the maximal memory used, independend of the number of cpus used.
  #
  #########################################################################################
  def select_memory(method)
    #init local Vars
    my_memory = 18  # The Default memory constraint for Clans an Hhpred

    # Implement versatile memory constraints for each job   
    my_memory = case method
                  
                  ### A ###
                when "AncesconAction" then 3
                when "Ali2dAction" then 50 # runs use memsat2 which uses blastpgp
                when "Aln2plotAction" then 10
                when "AlnvizAction" then 5
                  ### B ###  
                when "BlammerAction" then 10
                when "BlammerForwardAction" then 10
                when "BlastclustAction" then 10
                when "BacktransAction" then 3
                  ### C ###
                when "ClansAction"    then 50 # uses blastpgp
                when "CsBlastAction"  then 50 # uses blastpgp
                when "ClustalwAction" then 10
                when "ClustalwForwardAction" then 10
                when "ClustalwExportAction" then 5
                  ### D ###
                when "DataaAction" then 15
                when "Dataa2Action" then 3
                  ### F ###
                when "FrpredAction" then 64 # uses blastpgp, 3 iterations
                  ### G ###
                when "GcviewAction" then 50 # uses blastpgp
                when "Gi2seqExportAction" then 3  
                when "Gi2seqAction" then 3  
                when "Gi2seqForwardAction" then 3
                  ### H ###  
                when "HamppredAction" then 28
                when "HamppredForwardAction" then 19
                when "HamppredShowtemplalignAction" then 18
                when "HhpredForwardAction" then 19
                when "HhpredAction" then 36
                when "HhblitsAction" then 36
                when "HhblitsForwardAction" then 18
                when "HhblitsShowtemplalignAction" then 30
                when "HhpredShowtemplalignAction" then 18
                when "Hh3dTemplAction" then 18
                when "HhmakemodelAction" then 18
                when "HhsenserAction" then 20
                when "HhsenserForwardAction" then 18
                when "HhfragAction" then 18
                when "HhalignAction" then 18
                when "HhrepidAction" then 36
                when "HhrepAction" then 36
                when "HhrepMergealiAction" then 18
                when "HhclusterAction" then 50 # uses blastpgp
                when "HhblitsForwardAction" then 18
                when "HhompAction" then 50 # uses blastpgp
                when "HhfilterAction" then 18
                when "HhblitsForwardHmmAction" then 18
                when "Hmmer3Action" then 18
                when "HhrepForwardHmmAction" then 18
                when "Hh3dQuerytemplAction" then 18
                when "HhmergealiAction" then 18
                  ### K ###
                when "KalignAction" then 10
                when "KalignForwardAction" then 5
                  ### M ###
                when "ModellerAction" then 18  
                when "MarcoilAction" then 5
                when "MuscleAction" then 5  
                when "MuscleForwardAction" then 5
                when "MafftAction" then 5
                when "MafftForwardAction" then 5
                  ### P ###
                when "ProtBlastAction" then 50 # uses blastpgp
                when "PcoilsAction" then 6
                when "PsiBlastAction" then 50 # uses blastpgp
                when "PsiBlastpAction" then 18
                when "PatsearchAction" then 5
                when "PsiBlastForwardAction" then 5
                when "PatsearchForwardAction" then 5
                when "ProtBlastForwardAction" then 5
                  ### Q ###
                when "Quick2DAction" then 50 # disopred2 needed more than 22, uses blastpgp
                  ### R ###
                when "RepperAction" then 15
                when "ReformatAction" then 4
                when "RnasehpredAction" then 28
                when "RnasehpredForwardAction" then 19
                when "RnasehpredShowtemplalignAction" then 18
                  ### S ###
                when "SimshiftAction" then 5
                when "SixframeAction" then 10
                  ### T ###
                when "TprpredAction" then 10
                when "TCoffeeAction" then 10
                when "TCoffeeExportAction" then 4
                when "TCoffeeForwardAction" then 4
                  ### V ###
                when "ViewClansAction" then 10
                when "ViewRepeatsAction" then 5

                else my_memory
                end

    #############################################
    # Special Memory allocation for large hhpred jobs
    if (!options.nil? && !options.empty?)
      if (options['memory']) then my_memory = options['memory'] end
    end

    logger.debug "L472 #{method} : #{my_memory}"
    return my_memory;
  end

  def SgeWorker.addSeconds2Timelimit(seconds, timelimit)
    if timelimit =~ /(\d\d?):(\d\d?):(\d\d?)/
      (60 * $1.to_i + $2.to_i) * 60 + $3.to_i + seconds
    else
      timelimit.to_i + seconds
    end
  end

private

  def write_qupdate_call(file, id, status, indent, timevar)
    file.write indent
    qupdate_call = File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{status}"
    unless timevar.empty?
      qupdate_call += " $#{timevar}"
    end
    if (LOCATION == "Munich")
      # Munich setup is different from Tuebingen.
      if RAILS_ENV == "development"
        qupdate_call = "ssh ws04 \"" + qupdate_call + "\""
      else
        qupdate_call = "ssh ws01 \"" + qupdate_call + "\""
      end
    else
      qupdate_call = "source " + qupdate_call
    end
    qupdate_call += "\n"
    file.write qupdate_call;
  end

  def makeSGEname(name)
    # prerequisite (not checked): name is alphanumeric ('+' sign also allowed).
    # SGE requires, that name does not start with a digit.
    name.sub(/\A([\d\+])/, 't\1')
  end
end
