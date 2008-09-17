class TCoffeeAction < Action
  TCOFFEE  = File.join(BIOPROGS, 'TCoffee', 'current', 'bin', 't_coffee')   
  CLUSTALW = File.join(BIOPROGS, 'clustal', 'clustalw')  
  #Validation
  attr_accessor :sequence_input, :sequence_file, :jobid, :mail, :otheradvanced

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
                    :on => :create, 
                    :max_seqs => 5000,
                    :min_seqs => 2,
                    :max_length => 2000,
                    :inputmode => 'sequences'})  
  validates_shell_params(:jobid, :mail, :otheradvanced, {:on => :create})                                                
  validates_jobid(:jobid)  
  validates_email(:mail) 
  
  def before_perform
    @basename         = File.join(job.job_dir, job.jobid)
    @infile           = @basename+".in"
    @outfile          = @basename+".aln"   
    @tclog            = @basename+"_tcoffee.log" 
    @mlalign_id_pair  = params['mlalign_id_pair'] ? "-in mlalign_id_pair" : "" 
    @mfast_pair       = params['mfast_pair']      ? "-in mfast_pair"      : ""
    @mslow_pair       = params['mslow_pair']      ? "-in mslow_pair"      : ""
    @mclustalw_pair   = params['mclustalw_pair']  ? "-in mclustalw_pair"  : ""
    @output           = "-output clustalw_aln score_pdf score_html"
    @charcase         = params['case']
    @numbering        = params['residue_number']  ? "-seqnos on"          : "-seqnos off"
    @outorder         = params['order']           ? "-outorder align"     : "-outorder input"
    @otheradvanced = params['otheradvanced'] ? params['otheradvanced'] : ""
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    params_dump
  end	

  def perform
    cmd = "cd #{job.job_dir.to_s}; export PATH=$PATH:#{CLUSTALW}; export DIR_4_TCOFFEE=.; export TMP_4_TCOFFEE=.; export CACHE_4_TCOFFEE=.; "
    cmd += "#{TCOFFEE} -in #{@infile} #{@mlalign_id_pair} #{@mfast_pair} #{@mslow_pair} #{@mclustalw_pair} "
    cmd += "#{@output} #{@charcase} #{@numbering} #{@outorder} #{@otheradvanced}"
    cmd += "-run_name=#{job.jobid.to_s} -cache=no -quiet=stdout "
    cmd += "&> #{@tclog}"		
    @commands = [cmd]
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
end




