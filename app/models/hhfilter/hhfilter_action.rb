class HhfilterAction < Action
  HH = File.join(BIOPROGS, 'hhpred')
  
  if LOCATION == "Munich" && LINUX == 'SL6'
    HHPERL = "perl "+File.join(BIOPROGS, 'hhpred')
  else
    HHPERL = File.join(BIOPROGS, 'hhpred')
  end
  
  
  attr_accessor :sequence_input, :sequence_file, :informat, :mail, :jobid
  attr_accessor :maxident, :minident, :mincov, :extract

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 1000,
                                                    :min_seqs => 2,                                                    
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_int_into_list(:maxident, :minident, :mincov, {:in => 0...100, :on => :create})
  
  validates_format_of(:extract, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  validates_shell_params(:jobid, :mail, :maxident, :minident, :mincov, :extract, {:on => :create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename + ".in"
    @a3mfile = @basename + ".a3m"
    @outfile = @basename + ".results"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)

    @commands = []
    
    @maxident = params['maxident'] ? params['maxident'] : '90'  
    @minident = params['minident'] ? params['minident'] : '0'
    @mincov = params['mincov'] ? params['mincov'] : '0'
    @extract = params['extract'] ? params['extract'] : '100'        
 
  end

  def perform
    params_dump
    
    @commands << "#{HH}/hhfilter -i #{@infile} -o #{@a3mfile} -id #{@maxident} -qid #{@minident} -cov #{@mincov} -diff #{@extract} -M 30 &> #{job.statuslog_path}"
    @commands << "#{HHPERL}/reformat.pl a3m fas #{@a3mfile} #{@outfile} 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
  
end

