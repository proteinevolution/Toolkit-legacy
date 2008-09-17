class TprpredAction < Action
  TPRPRED = File.join(BIOPROGS, 'tprpred')
  
  attr_accessor :sequence_input, :sequence_file, :mail, :jobid
  attr_accessor :evalue, :minhits, :maxrows

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
                                                    :inputmode => 'sequence',
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, :evalue, :minhits, :maxrows, {:on => :create})
  
  validates_format_of(:evalue, {:with => /^\d+\.?\d*(e|e-|E|E-|\.)?\d+$/, 
                                :on => :create,
                                :message => 'Invalid value!' })
  
  validates_format_of(:minhits, :maxrows, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"    
    @outfile = @basename+".results"
    params_to_file(@infile, 'sequence_input', 'sequence_file')

    @commands = []

    @evalue = params['evalue'] ? params['evalue'] : '10000'
    @minhits = params['minhits'] ? params['minhits'] : '1'
    @maxrows = params['maxrows'] ? params['maxrows'] : '100'
    @pssm = params['pssm']
    @advanced = params['advanced_options']
    
  end

  def perform
    params_dump
    
    if (@advanced == "true")
    	@commands << "#{TPRPRED}/tprpred #{@infile} -r #{@pssm} -o #{@outfile} -E #{@evalue} -e #{@evalue} -N #{@minhits} -n #{@minhits} -L #{maxrows} &> #{job.statuslog_path}"
    else
    	@commands << "#{TPRPRED}/tprpred_wrapper.pl #{@infile} > #{@outfile}"
    end

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end

end




