class AlnvizAction < Action
  HH = File.join(BIOPROGS, 'hhpred')
  
  attr_accessor :sequence_input, :sequence_file, :informat, :mail, :jobid

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 1000,
                                                    :min_seqs => 2,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, {:on => :create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @outfile = @basename+".out"
    params_to_file(@outfile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "clu", @outfile)

    @commands = []
 
  end

  def perform
    params_dump
    
    @commands << "#{HH}/reformat.pl clu fas #{@basename}.out #{@basename}.align"
    @commands << "#{HH}/reformat.pl clu fas #{@basename}.out #{@basename}.ralign -M first -r"
    @commands << "#{HH}/hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
  
end

