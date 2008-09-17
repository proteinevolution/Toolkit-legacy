class RepperAction < Action
  REPPER = File.join(BIOPROGS, 'repper')
  PCOILS = File.join(BIOPROGS, 'pcoils')
  UTILS = File.join(BIOPROGS, 'perl')
  HH = File.join(BIOPROGS, 'hhpred')
  
  attr_accessor :sequence_input, :sequence_file, :informat, :mail, :jobid
  attr_accessor :windowsize, :minper, :maxper, :intthresh, :repperthresh
  attr_accessor :ile, :trp, :val, :tyr, :leu, :pro, :phe, :his, :cys, :glu, :met, :gln
  attr_accessor :ala, :asp, :gly, :asn, :thr, :lys, :ser, :arg

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 1000,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, {:on => :create})
  
  validates_format_of(:ile, :trp, :val, :tyr, :leu, :pro, :phe, :his, :cys, :glu, :met, :gln,
                      :ala, :asp, :gly, :asn, :thr, :lys, :ser, :arg,
                     {:with => /^\-?\d+\.?\d*$/, :on => :create, :message => 'Invalid value!' })
  
  validates_format_of(:windowsize, :minper, :maxper, :intthresh, :repperthresh, 
                     {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 
  
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"    
    @outfile = @basename+".results"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)
    @commands = []
    
    @flag = params['psipred'] ? 1 : 0
    @use_input = params['inputmode']
    @window_size = params['windowsize'] ? params['windowsize'] : "100"
    @perio_rg_low = params['minper'] ? params['minper'] : "2"
    @perio_rg_high = params['maxper'] ? params['maxper'] : "100"
    @cutoff = params['intthresh'] ? params['intthresh'] : "6"
    @threshold = params['repperthresh'] ? params['repperthresh'] : "2"
    @weighted = params['weighting']
    @matrix = params['matrix']
    
    @weight = ""
    if (@weighting == "0") 
      @weight = "-nw"
    end
    
    @value = 0 

    @ala = params['ala']
    @cys = params['cys']
    @phe = params['phe']
    @ile = params['ile']
    @leu = params['leu']
    @met = params['met']
    @pro = params['pro']
    @val = params['val']
    @trp = params['trp']
    @tyr = params['tyr']
    @asp = params['asp']
    @glu = params['glu']
    @lys = params['lys']
    @arg = params['arg']
    @ser = params['ser']
    @thr = params['thr']
    @his = params['his']
    @asn = params['asn']
    @gln = params['gln']
    @gly = params['gly']

    ### creating files ###
    @buffer           = @basename + ".buffer"
    @parfile          = @basename + ".ftwin_par"
    @plotfile         = @basename + ".ftwin_plot"    
    @ftwin            = @basename + ".ftwin"
    @overview         = @basename + ".ftwin_ov"
    @repper           = @basename + "_repper.dat"
    @psi              = @basename + ".alignment.psi"
    @a3m              = @basename + ".alignment.a3m"
    @a3m_unfiltered   = @basename + ".alignment_unfiltered.a3m" 
    @psitmplog        = @basename + ".psitmp.log"
    @hhmake_output    = @basename + ".hhmake.out"
    @myhmmmake_output = @basename + ".myhmmmake.out"
    @horizfile        = @basename + ".horiz"
    @hydro_data       = @basename + ".hydro_data"
    
    ### check given parameters
    #high end of periodicity range must not exceed window size
    if (@window_size < @perio_rg_high)
      @perio_rg_high = @window_size
    end
    #low end of periodicity range must be at least 2
    if (@perio_rg_low.to_i < 2)
      @perio_rg_low = "2"
    end
    
    File.open(@hydro_data, "w") do |file|
      file.write("A #{@ala}\n")
      file.write("C #{@cys}\n")
      file.write("F #{@phe}\n")
      file.write("I #{@ile}\n")
      file.write("L #{@leu}\n")
      file.write("M #{@met}\n")
      file.write("P #{@pro}\n")
      file.write("V #{@val}\n")
      file.write("W #{@trp}\n")
      file.write("Y #{@tyr}\n")
      file.write("D #{@asp}\n")
      file.write("E #{@glu}\n")
      file.write("K #{@lys}\n")
      file.write("R #{@arg}\n")
      file.write("S #{@ser}\n")
      file.write("T #{@thr}\n")
      file.write("H #{@his}\n")
      file.write("N #{@asn}\n")
      file.write("Q #{@gln}\n")
      file.write("G #{@gly}\n")
   end

    
  end

  def perform
    params_dump
    
    @commands << "#{HH}/reformat.pl fas fas #{@infile} #{@infile} -uc -r -M first"
    @commands << "#{REPPER}/deal_with_sequence.pl #{@basename} #{@window_size} #{@perio_rg_low} #{@perio_rg_high} #{@value} #{@cutoff} #{@parfile} #{@infile} #{@buffer}"

    # case run PSI-BLAST
    if (@use_input == "0")
      
      @commands << "#{PCOILS}/runpsipred_coils.pl #{@buffer}"
      @commands << "#{UTILS}/alignhits.pl -psi -b 1.0 -e 1E-4 -q #{@infile} #{@psitmplog} #{@psi}"
      @commands << "#{HH}/reformat.pl -uc -num #{@psi} #{@a3m_unfiltered}"
      @commands << "#{HH}/hhfilter -i #{@a3m_unfiltered} -qid 40 -cov 20 -o #{@a3m}"
      @commands << "#{HH}/reformat.pl -M first -r -uc -num a3m fas #{@a3m} #{@infile}"      
      @commands << "#{HH}/reformat.pl -M first -r -uc -num a3m psi #{@a3m} #{@psi}"
      
    end
    
    # running FTWin
    @commands << "#{REPPER}/complete_profile #{@infile} #{@parfile} #{@plotfile} #{@hydro_data}"
    
    # fragment for overview
    @commands << "#{REPPER}/sort_by_intensity.pl #{@window_size} #{@basename}"
    
    # calling psipred and ncoils
    @commands << "#{HH}/reformat.pl fas a3m #{@infile} #{@a3m} -uc -num -r -M first"
    @commands << "#{HH}/hhmake -i #{@a3m} -o #{@hhmake_output} -pcm 2 -pca 0.5 -pcb 2.5 -cov 20" 
    @commands << "#{REPPER}/deal_with_profile.pl #{@hhmake_output} #{@myhmmmake_output}"
      
    #non-intuitive definitions!!!
    #$coilsmatrix=0: MTIDK
    #$coilsmatrix=1: PDB
    @program_for_matrix = ['run_PCoils', 'run_PCoils_pdb']
    
    #run Coils over the sequence in the buffer file
    ['14', '21', '28'].each do |size|
      @commands << "cd #{job.job_dir}; #{PCOILS}/#{@program_for_matrix[@matrix.to_i]} #{@weight} -win #{size} -prof #{@myhmmmake_output.sub(/^.*\/(.*)$/, '\1')} < #{@buffer.sub(/^.*\/(.*)$/, '\1')} > #{@ftwin.sub(/^.*\/(.*)$/, '\1')}_n#{size}"
    end
    
    # calling repper
    @commands << "#{REPPER}/repper64 -i #{@buffer} -w #{@window_size} -thr #{@threshold} -dat #{@repper} -v 0"

    #calling psipred
    if (@flag == 1 && @use_input == "1")
      @commands << "#{PCOILS}/runpsipred.pl #{@buffer}"
    end
    
    # prepare for gnuplot
    @commands << "#{REPPER}/prepare_for_gnuplot.pl #{@basename} #{@overview} #{@repper} #{@flag} #{@use_input} #{@perio_rg_low} #{@perio_rg_high} #{@ftwin}_n14 #{@ftwin}_n21 #{@ftwin}_n28 #{@horizfile}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
  
end
