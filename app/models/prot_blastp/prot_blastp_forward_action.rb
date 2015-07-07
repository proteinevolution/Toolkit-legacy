require 'forward_hits'

class ProtBlastpForwardAction < Action
  include ForwardHits

  attr_accessor :hits, :includehits, :alignment

  validates_checkboxes(:hits, {:on => :create, :include => :includehits, :alternative => :alignment})

  def run
    forward_hits(".protblastp", false, false, logger, job, params, queue)
  end

  def forward_params
    res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
    mode = params['fw_mode']
    informat = 'fas'
    inputmode = "alignment"
    if (!mode.nil? && mode == "sequence")
      inputmode = "sequence"
    end

    controller = params['forward_controller']
    if (controller == "patsearch")
      logger.debug "L25 patsearch"
      {'db_input' => res.join, 'std_dbs' => ""}
    elsif (controller == "pcoils")
      logger.debug "L28 pcoils"
      {'sequence_input' => res.join, 'inputmode' => '2'}
    else
      logger.debug "L31 forwarding to: #{params['forward_controller']}"
      {'sequence_input' => res.join, 'inputmode' => inputmode, 'informat' => informat}
    end
  end

end
