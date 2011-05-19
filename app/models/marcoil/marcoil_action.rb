class MarcoilAction < Action
  PCOILS = File.join(BIOPROGS, 'pcoils')
  MARCOIL = File.join(BIOPROGS, 'marcoil')
  UTILS = File.join(BIOPROGS, 'perl')
  HH = File.join(BIOPROGS, 'hhpred')
  COILSDIR = "COILSDIR=#{PCOILS}"
  attr_accessor :sequence_input, :sequence_file, :informat, :mail, :jobid

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 1000,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, {:on => :create})
  
  def before_perform
    @outdir  = job.job_dir.to_s
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"    
    @outfile = @basename+".results"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)
    @commands = []
    
    @transprob = params['transprob']
    @algorithm = params['algo']
    @inputmode = params['inputmode']
    @weighting = params['weighting']
    @matrix = params['matrix']
    @psipred = params['psipred'] ? "T" : "F"     
     


    @weight = ""
    if (@weighting == "0") 
      @weight = "-nw"
    end
 
    ### creating files ###
    @buffer           = @basename + ".buffer"
    @coils            = @basename + ".coils"
    @psi              = @basename + ".alignment.psi"
    @a3m              = @basename + ".alignment.a3m"
    @a3m_unfiltered   = @basename + ".alignment_unfiltered.a3m" 
    @psitmplog        = @basename + ".psitmp.log"
    @hhmake_output    = @basename + ".hhmake.out"
    @myhmmmake_output = @basename + ".myhmmmake.out" 
    @horizfile        = @basename + ".horiz"
     
  end

  def perform
    params_dump

    # case run COILS (no Alignment)
  
      @program_for_matrix = ['run_Coils_iterated', 'run_Coils_pdb', 'run_Coils', 'run_Coils_old']

      #@commands << "#{HH}/reformat.pl fas fas #{@infile} #{@infile} -uc -r -M first"
      #@commands << "#{PCOILS}/deal_with_sequence.pl #{@basename} #{@infile} #{@buffer}"

      #@commands << "export #{COILSDIR}"

      #['14', '21', '28'].each do |size|
       # @commands << "#{PCOILS}/#{@program_for_matrix[@matrix.to_i]} -win #{size} < #{@buffer} > #{@coils.sub(/^.*\/(.*)$/, '\1')}_n#{size}"

       @commands << "#{MARCOIL}/marcoil #{@algorithm}  #{@matrix} #{@transprob}  +dssSl -I #{MARCOIL}/Inputs/ -O #{@outdir}/ #{@infile} "
   
      # @commands << "#{MARCOIL}/marcoil #{@algorithm}  #{@matrix} +dssSl -I #{MARCOIL}/Inputs/ -O #{@outdir}/ #{@infile} "
 
      if(@algorithm =="-P" )
      	@commands << "#{MARCOIL}/prepare_marcoil_gnuplot.pl #{@basename} #{@outdir}/ProbListPSSM #{@algorithm} "
      else
	@commands << "#{MARCOIL}/prepare_marcoil_gnuplot.pl #{@basename} #{@outdir}/ProbList "
      end
      
      @commands << "#{MARCOIL}/create_numerical_marcoil.rb #{@outdir}/ "
      # generate numerical output
      #@commands << "#{PCOILS}/create_numerical.rb -i #{@basename} -m #{@matrix.to_s} -s #{@infile.to_s} -w #{@weighting.to_i} "

   
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
  
end

