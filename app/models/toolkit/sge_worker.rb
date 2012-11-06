 class SgeWorker < AbstractWorker
    set_table_name "queue_workers"
    belongs_to :queue_job  
    
    def execute
      basename = File.join(queue_job.action.job.job_dir, id.to_s)
      self.commandfile = basename+".sh"
      self.wrapperfile = basename+"wrapper.sh"    
      writeShWrapperFile
      writeShCmdsFile
      self.status = STATUS_QUEUED
      save!
      self.queue_job.update_status
      
      tries = 0
      
      # Identify the Action which is to be submitted by the toolkit and set the max Memory count to a individual value
      job =queue_job.action.type 
      # Memory contains the Nr of GB used for Tuebinger Queue
      memory =  select_memory(job); 
      logger.debug "L20 Memory #{memory} "      
        
        
      # Location Tuebingen, using variable Memor Limiting to circumvent Memory constraints and Queue Crowding
      if LOCATION == "Tuebingen" #&& RAILS_ENV == "development"
                  if RAILS_ENV == "development"
                    command = "#{QUEUE_DIR}/qsub -l h_vmem=#{memory}G -p 10 #{self.wrapperfile}"
                    logger.debug "qsub command: #{command}"
                  else
                    command = "#{QUEUE_DIR}/qsub -l h_vmem=#{memory}G #{self.wrapperfile}" # set h_vmem to 18G instead of 10G, because Clans does not work always with 10G
                    logger.debug "qsub command: #{command}"
                  end
      else
      # LOCATION = Munich !!  
            if LINUX == "SL6"
            #command = "#{QUEUE_DIR}/qsub -pe threadssl6.pe 1 #{self.wrapperfile}" 
            command = "#{QUEUE_DIR}/qsub  #{self.wrapperfile}"
             logger.debug "L28 qsub command: #{command}"
            else
              command = "#{QUEUE_DIR}/qsub  #{self.wrapperfile}"
          end
     end
     
      logger.debug "L36 ID"+`id`
      logger.debug
      # Remove all Line Carriage characters from returned result command
      res = `#{command}`.chomp
       logger.debug "L38 Original  QID : #{res} "
      self.qid = res.gsub(/Your job (\d+) .*$/, '\1')
      logger.debug "L40 Substituded QID : #{qid} "
      
      while (!$?.success? && tries < 5)
        logger.debug "L43 #{$?.success?} in  PE Queue"
      	res = `#{command}`.chomp
      
        #res = `#{command}`.chomp
        self.qid = res.gsub(/Your job (\d+) .*$/, '\1')
        logger.debug "L48 Your job has quid #{self.qid}"
      	tries += 1
     end
     
     save!
      if (!$?.success? && tries == 5)
      	raise "Unable to submit job!"
      end

      save!
    end
    
    def delete
      command = "#{QUEUE_DIR}/qdel #{qid}"
      logger.debug "Worker command: #{command}"
      system(command)
    end
    
    # creates a shell wrapper file for all jobcomputations-commands that are executed on the queue, sets the status of the job
    # this must be a wrapper to be able to print to stdout and stderr files when disk file size limit is reached in the subshell.
    def writeShWrapperFile
      queue = QUEUES[:normal]
      cpus = nil
      additional = false

      if (!options.nil? || !options.empty?)
        if (options['queue']) then queue = options['queue'] end
        if (options['cpus']) then cpus = options['cpus'] end
        if (options['additional']) then additional = true end
      end

      begin
        f = File.open(self.wrapperfile, 'w')
        f.write "#!/bin/bash\n"
        #f.write "#!/bin/sh\n"
        # SGE options
        f.write '#$' + " -N TOOLKIT_#{queue_job.action.job.jobid}\n"

        if LOCATION == "Tuebingen" && RAILS_ENV == "development"
        else
          if LINUX == 'SL6'
            f.write '#$' + " -pe #{queue}\n"
            #f.write '#$' + " -q #{queue}\n"
          else
            f.write '#$' + " -q #{queue}\n"
          end
          if RAILS_ENV == "development"
            if queue == "express.q"
	      f.write '#$' + " -l express=TRUE\n"
            end
	  end
	end
        f.write '#$' + " -wd #{queue_job.action.job.job_dir}\n"
        f.write '#$' + " -o #{queue_job.action.job.job_dir}\n"
        f.write '#$' + " -e #{queue_job.action.job.job_dir}\n"
        f.write '#$' + " -w n\n"

	if (queue == QUEUES[:long] && LOCATION == "Tuebingen")
	       f.write '#$' + " -l long\n"
        end

        if (queue == QUEUES[:immediate] && LOCATION == "Tuebingen")
	         f.write '#$' + " -l immediate\n"
        end

        # Source all modules on SL6
        if LINUX == 'SL6'
            f.write "source /etc/profile\n"
            f.write "export RUBYLIB=#{RUBY_LIB}  \n"
            f.write "export GEM_HOME=#{GEM_HOME} \n"
            f.write "env \n"
        end
        f.write "hostname > #{queue_job.action.job.job_dir}/#{id.to_s}.exec_host\n"
        if RAILS_ENV == "development"
          f.write "echo 'Starting job #{id.to_s}...' >> #{queue_job.action.job.statuslog_path}\n"
        end

        # SET STATUS OF THIS JOB TO RUNNING
        if LINUX == 'UBUNTU' || LOCATION == "Tuebingen"
          f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_RUNNING}\n"
        end
        if LINUX == 'SL6' && RAILS_ENV =="development"
          f.write "ssh ws04 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_RUNNING}'\n"
        end
        if LINUX == 'SL6' && RAILS_ENV =="production"
         f.write "ssh ws01 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_RUNNING}'\n"
        end              
        
        if RAILS_ENV == "development"
          f.write "echo 'Status set to running...' >> #{queue_job.action.job.statuslog_path}\n"
        end

        # ALL THE SUBSHELL SCRIPT 
        if RAILS_ENV == "development"
          f.write "echo 'Before executing the commandfile...' #{self.commandfile} >> #{queue_job.action.job.statuslog_path}\n"
        end

        f.write "#{self.commandfile}\n"
        # CAPTURE EXTISTATUS OF THE 'CHILD'-SHELL SCRIPT WHICH IS SAVED IN $? INTO A VARIABLE WITH THE SAME NAME IN THIS SHELL 
        f.write "exitstatus=$?\n"
        # were there any errors?
        if (additional == true)
              if (LOCATION == "Munich")
                      if RAILS_ENV == "development"
                        f.write "echo 'Running Additional Script '\n"
                        #f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}\n"
                        f.write "ssh ws04 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}'\n"
                        logger.debug "L138 Updateing :ssh ws04 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}'"
                        #f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}\n"
                      else
                        f.write "ssh ws01 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}'\n"
                        #f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}\n"
                      end
              else
                f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}\n"
            end
            
          if RAILS_ENV == "development"
            f.write "echo 'Running under developement environment ' >> #{queue_job.action.job.statuslog_path}\n"
            
          end

        else
          f.write "if [ ${exitstatus} -eq 0 ] ; then\n"
          if (LOCATION == "Munich")
            if RAILS_ENV == "development"
              f.write "ssh ws04 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}'\n"
            else
              f.write "ssh ws01 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}'\n"
              #f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}\n"
            end
          else
            f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}\n"
          end
          if RAILS_ENV == "development"
            f.write "echo 'Job orig #{id.to_s} DONE!' >> #{queue_job.action.job.statuslog_path}\n"
            f.write "ssh ws04 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}'\n" # naga
          end
          f.write "else\n"
          if (LOCATION == "Munich")
            if RAILS_ENV == "development"
              f.write "ssh ws04 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_ERROR}'\n"
            else
              f.write "ssh ws01 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_ERROR}'\n"
              #f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_ERROR}\n"
            end
          else
            f.write File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_ERROR}\n"
          end
          f.write "echo 'Error while executing Job!' >> #{queue_job.action.job.statuslog_path}\n"
          if RAILS_ENV == "development"
            f.write "echo 'Exit status '${exitstatus} >> #{queue_job.action.job.statuslog_path}\n"
          end
          f.write "fi\n"
        end
        f.chmod(0755)
        f.close
      rescue  Exception => e
        raise "Unable to create Wrapperfile #{self.wrapperfile} in #{self.class} id: #{id}.\n e.message\n"
      end
    end
    
    # creates a jobcomputation-commands file (sh script) + minimal errorhandling and limiting of memory and disk-file-size
    # if a program does not return 0 the subsequent commands are not executed and the script exits
    def writeShCmdsFile
      begin
        f = File.open(self.commandfile, 'w')
        f.write "#!/bin/sh\n"
        # FILE SIZE LIMIT 1Gb (1024 * 1000000), MEMORY LIMIT 6Gb (see man bash -> ulimit)
        f.write "ulimit -f 1000000\n" #-m 6000000\n"
        f.write "export TK_ROOT=#{ENV['TK_ROOT']}\n"
        if (LOCATION == "Tuebingen" && RAILS_ENV == "development")
          f.write "export PATH=/usr/local/bin:/usr/bin:/bin:\n"
        end
        # Have to decide where the module load shall be put ....
        if (LOCATION == 'Munich' && LINUX == 'SL6')
            logger.debug "L183 Location Munich Source etc/profiles "
          f.write "source /etc/profile\n"
          f.write "module load perl\n"
          f.write "module load python2.6\n"
        end
        # print the process id of this shell execution
        f.write "echo $$ >> #{queue_job.action.job.job_dir}/#{id.to_s}.exec_host\n" 
        logger.debug "Exec_host file geschrieben."
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
        raise "Unable to create Commandfile #{self.commandfile} in #{self.class} id: #{id}.\n e.message \n"
      end
    end
#########################################################################################
# Individualized Memory Management for each tool, this has to be tested on wye
#
#########################################################################################
def select_memory(method)
  #init local Vars
  my_memory = 18  # The Default memory constraint for Clans an Hhpred

 # Implement versatile memory constraints for each job   
 my_memory = case method
 
  ### A ###
  when "AncesconAction" then 2
  when "Aln2plotAction" then 10
  when "AlnvizAction" then 5
  ### B ###  
  when "BlammerAction" then 10
  when "BlammerForwardAction" then 10
  when "BlastclustAction" then 10
  when "BacktransAction" then 2
  ### C ###
  when "ClansAction"    then 18
  when "CsBlastAction"  then 15
  when "ClustalwAction" then 10
  when "ClustalwForwardAction" then 10
  when "ClustalwExportAction" then 5
  ### D ###
  when "DataaAction" then 15
  ### F ###
  when "FrpredAction" then 10
  ### G ###
  when "GcviewAction" then 10  
  when "Gi2seqExportAction" then 2  
  when "Gi2seqAction" then 2  
  when "Gi2seqForwardAction" then 2
  ### H ###  
  when "HhpredForwardAction" then 19
  when "HhpredAction" then 19
  when "HhblitsAction" then 18
  when "HhblitsForwardAction" then 18
  when "HhblitsShowtemplalignAction" then 18
  when "HhpredShowtemplalignAction" then 18
  when "Hh3dTemplAction" then 18
  when "HhmakemodelAction" then 18
  when "HhsenserAction" then 18
  when "HhsenserForwardAction" then 18
  when "HhfragAction" then 18
  when "HhalignAction" then 18
  when "HhrepidAction" then 18
  when "HhrepAction" then 18
  when "HhpredForwardAction" then 18
  when "HhrepMergealiAction" then 18
  when "HhclusterAction" then 18
  when "HhblitsForwardAction" then 18
  when "HhompAction" then 18
  when "HhfilterAction" then 18
  when "HhblitsForwardHmmAction" then 18
  when "Hmmer3Action" then 10
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
  when "ProtBlastAction" then 15
  when "PcoilsAction" then 4
  when "PsiBlastAction" then 15
  when "PatsearchAction" then 5
  when "PsiBlastForwardAction" then 5
  when "PatsearchForwardAction" then 5
  when "ProtBlastForwardAction" then 5
  ### R ###
  when "RepperAction" then 15
  when "ReformatAction" then 4
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
  
   else 15
end

#############################################
# Special Memory allocation for large hhpred jobs
if (!options.nil? || !options.empty?)
        if (options['memory']) then my_memory = options['memory'] end
end


    logger.debug "L319 #{method} : #{my_memory}"
    return my_memory;
 end


end

