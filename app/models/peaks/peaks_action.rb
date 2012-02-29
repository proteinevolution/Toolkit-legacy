class PeaksAction < Action
  
  PEAKS = File.join(BIOPROGS, 'ruby/peaks.rb')


  attr_accessor :jobid, :size, :string, :sequence_input, :sequence_file

  #validates_input(:sequence_input, :sequence_file, {:informat_field => :informat,
  #                                                  :informat => 'fas',
  #                                                  :inputmode => :inputmode,
  #                                                  :max_seqs => 9999,
  #                                                  :on => :create })

  validates_jobid(:jobid)

  validates_shell_params(:jobid, :size, :string,
                         {:on => :create})

  validates_length_of(:string, {:minimum => 1, :message => 'Invalid value! At least 1 character.', :on => :create})

  validates_format_of(:size, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'})


  # Put action initialisation code in here
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"
    @outfile = @basename+".png"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []
    @size = params['size']
    @string = params['string']
  end


  # Optional:
  # Put action initialization code that should be executed on forward here
  # def before_perform_on_forward
  # end
  
  
  # Put action code in here
  def perform
     params_dump
     @commands << "#{PEAKS} -f #{@infile} -s #{@size} -a #{@string} -o #{@outfile} &> #{job.statuslog_path}"
     logger.debug "Commands:\n"+@commands.join("\n")
     queue.submit(@commands)
  end

end




