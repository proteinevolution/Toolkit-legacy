class QueueJob < ActiveRecord::Base
  belongs_to :action, :order => "created_on"
  has_many :workers, :class_name => "AbstractWorker", :foreign_key => "queue_job_id", :order => "created_on"

  include Dbhack
  
  def logger
    @logger ||= Logger.new("#{RAILS_ROOT}/log/#{self.class.name.to_us}.log")
  end

  # final  : boolean (nil|true|false)
  #
  # cmds   : array of commands (each entry one program call!), shell-execution 
  #
  # final is set to true by default which means that the job status 
  # is set to STATUS_DONE subsequent to the successful execution 
  # (in case of final=false the job status is not updated)
  # if an action has sequential executions (on the queue), 
  # all but the last submit calls must set final = true
  # this might be the case if there are parallel executions 
  # that use results of a preparing computation step
  def submit(cmds=nil, final=nil, options={})
    set_attributes(cmds, final, options)
    return unless initialized?
    spawn_worker(commands, options).execute
  end

  def set_attributes(cmds, final, options)
    if !cmds.nil?
      #cmds = cmds.join("\n") if cmds.is_a?(Array)
      if !cmds.is_a?(Array)
        cmds_ar = []
        cmds_ar << cmds
        write_attribute("commands", cmds_ar)
      else
        write_attribute("commands", cmds)
      end
    end
    if final.nil?
      # assume final=true (there is only ONE computation which might contain several commands)
      self.final = true 
    else
      self.final = final
    end
    self.options = options unless options.nil?
    save!
  end

  def spawn_worker(cmds, opts)
    # !!!local execution is currently not maintained!!! repair of this class is needed
    qw = nil
    
    excep = nil
    repeat = 0
    while (repeat < 6)
      begin    	
        if QUEUE_MODE == 'local'
          qw = LocalWorker.create(:queue_job => self, :commands => cmds, :options => options, :status => STATUS_INIT)
        elsif QUEUE_MODE == 'pbs'
          qw = PbsWorker.create(:queue_job => self, :commands => cmds, :options => options, :status => STATUS_INIT)
        elsif QUEUE_MODE == 'sge'
          qw = SgeWorker.create(:queue_job => self, :commands => cmds, :options => options, :status => STATUS_INIT)
        else
          # ERROR
        end
        break
      rescue Exception => e
        excep = e
        repeat += 1
        ActiveRecord::Base.establish_connection(ActiveRecord::Base.remove_connection())
      end
    end
    
    if (repeat == 6) then raise excep end
    
#    qw.queue_job = self
    qw.save!
    qw
  end

  def initialized?
    self.commands && self.options
  end

  def submit_parallel(cmds=nil, final=nil, options={})
    set_attributes(cmds, final, options)
    return unless initialized?
    qw = []
    commands.each do |cmd|
      qw << spawn_worker(cmd, options)
    end
    qw.each do |w| 
      w.execute
    end
  end

  def commands=(cmds)
    if !cmds.is_a?(Array)
      cmds_ar =[] 
      cmds_ar << cmds 
      write_attribute("commands", cmds_ar)
    else
      write_attribute("commands", cmds)
    end
    # sets the instance variable "commands" to cmds, equivalent to self[:commands]=cmds
    
  end

  def update_status
    stat = workers.inject(STATUS_DONE)  do |s, w|
      STATUS_CMP[w.status] < STATUS_CMP[s] ? w.status : s
    end
    self.status = stat
    
    save!
    

    if self.status == STATUS_DONE && on_done then action.send(on_done) end
    action.update_status
  end

end

