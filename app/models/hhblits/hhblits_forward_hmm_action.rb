class HhblitsForwardHmmAction < Action
  HH=File.join(BIOPROGS, "hhpred")

  def do_fork?
    return false
  end

  attr_accessor :hits, :includehits, :result_textbox_to_file

  def perform
    if !params['fw_mode'].nil?  # default forward

      @forwardfile = File.join(job.job_dir, job.jobid + ".forward")
      @hhrfile = File.join(job.job_dir, job.jobid + ".hhr")
      @queryfile = File.join(job.job_dir, job.jobid + ".in")

      @command = "#{HH}/hhmakemodel.pl -i #{@hhrfile} -a3m #{@forwardfile} -q #{@queryfile}"
      if (params['includehits'] == "byevalue")
        @command += " -e #{params['hitsevalue']}"
      else
        @command += " -m #{params['hits']}"
      end

      logger.debug "Command: #{@command}"
      system(@command)

    end

    self.status = STATUS_DONE
    self.save!
    job.update_status
  end

  def forward_params
  
    logger.debug "In forward params"
    logger.debug "#{job.job_dir}"
    hash = {}
    if params['mode'].nil?
      filename = File.join(job.job_dir, 'result_textbox_to_file')
      res = ""    
      if (File.exists?(filename))     
        res = IO.readlines(filename).join
      end
      res.gsub!(/>ss_pred.*?\n(.*\n)*?>/, '>')
      res.gsub!(/>ss_conf.*?\n(.*\n)*?>/, '>')      
      hash = { 'sequence_input' => res, 'maxpsiblastit' => '0' }
    else
      res = IO.readlines(job.params_main_action['sequence_file']).join("\n")
      hash = { 'sequence_input' => res, 'informat' => job.params_main_action['informat']}
    end
    return hash

  end
end