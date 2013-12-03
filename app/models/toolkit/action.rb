  class Action < ActiveRecord::Base
    acts_as_tree :order => "created_on"
    has_many :queue_jobs, :dependent => :destroy, :order => "created_on"
    belongs_to :job

    serialize :params
    serialize :flash
    
  include Dbhack
    
    def do_fork?
    	return true
    end    

    def saveparams(user_id, tool)
      toolparam = (ToolParam.find_by_sql ["SELECT * FROM tool_params WHERE user_id = ? AND tool LIKE ?", user_id, tool])
      #check database for an existing entry for tool+user and delete it
      if toolparam.first.nil?
        id = nil
      else
        id = toolparam.first['id']
      end
      if !id.nil?
        logger.debug "id: #{id}"
        ToolParam.delete(id)
      end
      ToolParam.create(:glob => params, :user_id => user_id, :tool => tool)
    end
    
    def loadparams(user_id, tool)
      return (ToolParam.find_by_sql ["SELECT * FROM tool_params WHERE user_id = ? AND tool LIKE ?", user_id, tool])
    end
        
    def params
      self[:params] ||= {}
    end

    def params=(hash)
      params.replace(hash)
    end

    def flash
      self[:flash] ||= {}
    end

    def flash=(hash)
      flash.replace(hash)
    end
    
    def initialize(*args)
      super(*args)
    end

    def logger
      @logger ||= Logger.new("#{RAILS_ROOT}/log/#{self.class.name.to_us}.log")
    end

    def done?
      self.status == STATUS_DONE
    end

    def run
      self.status = STATUS_INIT
      self.save
      
      p = fork do
        begin
          sleep(1)
          before_perform
          before_perform_on_forward if job.parent
          perform
        rescue Exception => e
          # lets do minimal error handling
          logger.error("Exception: " + e.message);
          logger.error("   Stack backtrace " + e.backtrace.join("\n     "));
          self.status = STATUS_ERROR
          self.save
          job.update_status
        end
      end
      logger.debug "Fork: #{do_fork?}"
      if do_fork?
        Process.detach(p)
      else
        Process.wait
        while (job.status != STATUS_DONE && job.status != STATUS_ERROR) do
          reload
          sleep(1)
        end
      end

    end

    def params_dump
      params.keys.each do |key|
        # logger.debug "#{key}: #{params[key].inspect}"
      end
    end

    # write formular fields to a file
    def params_to_file(filepath, *keys)
      
      #
      # if a key ends on _flash copy the data to filepath and replace *_flash with filepath
      #

      
      keys.each do |key|
       #logger.debug "#{key}: #{params[key].inspect}"
        if params[key]
          if params[key].instance_of?(ActionController::UploadedStringIO)
            params[key].rewind
            params[key] = params[key].read
            File.open(filepath, 'w') do |file|
              file.write(params[key])
            end
          elsif File.readable?(params[key])
          	if (File.size?(params[key]))
	           FileUtils.cp(params[key], filepath)
	         else
	           next
	         end
          else     
            File.open(filepath, 'w') do |file|
              file.write(params[key])
            end
          end
          return true
        end
      end
      return false
    end

    # reformat
    def reformat(informat, outformat, infile, outfile=infile)
      system(File.join(BIOPROGS, 'perl') + "/reformat.pl -f=#{infile} -a=#{outfile} -i=#{informat} -o=#{outformat} >> #{outfile}.reform_log 2>&1")
      if ($? != 0) then raise "Error in Reformat Execution" end
    end

#    def params
#      val = read_attribute('params')
#      val = val.kind_of?(String) ? YAML::load(val) : val
#      val = val.kind_of?(YAML::Syck::DomainType) ? YAML::load(val) : val
#      return val
#    end

#    def flash
#      val = read_attribute('flash')
#      val.kind_of?(String) ? YAML::load(val) : val
#    end

    def perform
      self.status = STATUS_DONE
      self.save
      job.update_status
    end

    def queue(*args)
		repeat = 0
		excep = nil
		while (repeat < 10)    	
    		begin
      		qj = QueueJob.create(:action => self, :status => STATUS_INIT, *args)
#      		qj.action = self
#      		qj.status = STATUS_INIT
      		qj.save!
      		return qj
      	rescue Exception => e
				excep = e      		
      		repeat += 1
      		ActiveRecord::Base.establish_connection(ActiveRecord::Base.remove_connection())
      	end
      end
		raise excep         
    end

    def update_status
      foundfinal = false
      stat = queue_jobs.inject(STATUS_DONE)  do |s, qj|
        if (qj.final && qj.status == STATUS_DONE) then foundfinal = true end
        STATUS_CMP[qj.status] < STATUS_CMP[s] ? qj.status : s
      end
      if stat == STATUS_DONE && !foundfinal
        stat = STATUS_RUNNING
      end
      self.status = stat
      self.save
      job.update_status
    end

    # abstract callback function, overwrite in your implementation classes
    def before_perform
    end

    # abstract callback function, overwrite in your implementation classes
    def before_perform_on_forward
    end

    # abstract callback function, overwrite in your implementation classes
    def forward_params
      { }
    end

    def process_genomes
      res = ""
      params.keys.each do |key|
        if( key =~ /^(\d+)gchk$/ )
          res += $1 + " "
          params.delete(key)          
        end
      end
      params['taxids']=res if (res!="")
    end
    
    

  end

