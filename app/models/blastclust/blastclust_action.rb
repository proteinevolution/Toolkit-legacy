class BlastclustAction < Action

  def before_perform_on_forward
  end  

  BLAST = File.join(BIOPROGS, 'blast')  

  attr_accessor :jobid, :mail, :sequence_input, :sequence_file, :pvalue, :svalue, :lvalue, :informat
  
  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => 'sequences',
                                                    :min_seqs => 2,
                                                    :max_seqs => 10000,
                                                    :on => :create })
  
  validates_jobid(:jobid)  
  
  validates_email(:mail)
  
  validates_int_into_list(:lvalue, {:in => 1..100, :on => :create,:allow_nil => false})
  
  validates_int_into_list(:pvalue, {:in => 4..100, :on => :create, :message => "Value must be between 4% and 100%"})  
  
  validates_float_into_list(:svalue , {:in => 0..3, :on => :create, :message => "Value must be between 0 and 3"})


    def before_perform
      @basename = File.join(job.job_dir,job.jobid)
      @infile =  @basename+".fasta"
      @outfile = @basename+".out"
      params_to_file(@infile,'sequence_input','sequence_file')
      @informat=params['informat'] ? params['informat'] : 'fas'
      reformat(@informat,"fas",@infile)
      @commands = []

      @norp = params['itnp']

      @sdtpit= params['sdtpit']   
      if @sdtpit=="T" then
      	@value = params['pvalue']
      else
      	@value = params['svalue']
      end
      if !@value then @value=1.75 end

      @lvalue = (params['lvalue'].to_f)/100
    end
	
    def perform
      @commands << "#{BLAST}/blastclust -i #{@infile} -o #{@outfile} -p #{@norp} -L #{@lvalue} -b T -S #{@value}"
      queue.submit(@commands)
    end

end




