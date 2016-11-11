class AlnvizAction < Action
  
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
  
    #Author: Seung-Zin Nam
    #this code is a hack to provide fake gi numbers for biojs msa to handle custom ids
    
    #out = File.new(@outfile, "w+")
    #delim = '>'    
    #File.readlines(sequence_file).each do |line|
      #if ((line.include? '>') && !(line.include? '>gi|') && !(line.include? '>db|') && !(line.include? '>sp|') && !(line.include? '>tr|'))
      #then
        #out.write(line.split(delim).join(delim + 'gi|'))  
      #else
        #out.write(line)
      #end
    #end
      #out.close

    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "clu", @outfile)

    @commands = []
  end

  def perform
    params_dump

    @commands << "source #{SETENV}"
    @commands << "reformat.pl clu fas #{@basename}.out #{@basename}.align"
    @commands << "reformat.pl clu a3m #{@basename}.out #{@basename}.a3m"
    @commands << "reformat.pl clu fas #{@basename}.out #{@basename}.ralign -M first -r"
    @commands << "hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50"
    @commands << "source #{UNSETENV}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
  
end

