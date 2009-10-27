class HhblastForwardAction < Action
  HH=File.join(BIOPROGS, "hhpred")

  def do_fork?
    return false
  end

  attr_accessor :hits, :includehits, :result_textbox_to_file

  validates_checkboxes(:hits, {:on => :create, :include => :includehits, :alternative => :result_textbox_to_file})

  def perform

    if !params['fw_mode'].nil?  # default forward

      @forwardfile = File.join(job.job_dir, job.jobid + ".forward")
      @hhrfile = File.join(job.job_dir, job.jobid + ".hhr")
      @queryfile = File.join(job.job_dir, job.jobid + ".fasta")

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
    hash = {}
    if params['fw_mode'].nil?
      filename = File.join(job.job_dir, 'result_textbox_to_file')
      res = ""
      if (File.exists?(filename))
    	  res = IO.readlines(filename).join
      end
      res.gsub!(/>ss_pred.*?\n(.*\n)*?>/, '>')
      res.gsub!(/>ss_conf.*?\n(.*\n)*?>/, '>')
      hash = { 'sequence_input' => res, 'maxpsiblastit' => '0' }
    else
      filename = File.join(job.job_dir, job.jobid + ".forward")
      res = ""
      if (File.exists?(filename))
        res = IO.readlines(filename).join
      end
      hash = { 'sequence_input' => res, 'informat' => 'a3m' }
      if (params['forward_controller'] == "hhpred" || params['forward_controller'] == 'hhomp' || params['forward_controller'] == "hhrep" || params['forward_controller'] == 'hhrepid')
        hash['maxpsiblastit'] = 0
      end
      if (params['forward_controller'] == "psi_blast")
        hash['inputmode'] = "alignment"
      end
      if (params['forward_controller'] == "quick2_d")
        hash['psiblast_check'] = 0
      end
    end
    return hash
  end
end
