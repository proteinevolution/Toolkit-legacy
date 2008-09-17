require 'bioinf'
require 'fileutils'

class HhrepidJob < Job
  FAMIDS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L']
  QSCS   = [0.0, 0.2,0.3,0.4,0.5]

  # add your own data accessors for the result templates here! For example:
  attr_reader :qscs, :repfams, :plotfiles, :results, :mapfiles, :graphfiles

  @@export_ext = "hhrepid"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export
    ret = IO.readlines(File.join(job_dir, jobid + ".#{@@export_ext}")).join
  end

  # Overwrite before_results to fill you job object with result data before result display
  def before_results(controller_params)
    basename   = File.basename( Dir.glob(File.join(job_dir, '*.a3m')).sort.last, '.a3m' )   
    
    # preparation for export functionality
    resfile = File.join(job_dir, jobid+"."+(controller_params["qsc"] || '0.3')+".hhrepid")
    exportfile = File.join(job_dir, jobid+".hhrepid")
    FileUtils.rm_f(exportfile) if File.exists?(exportfile)
    FileUtils.cp(resfile, exportfile) if File.exists?(File.join(resfile))

    # parse results of HHrepID runs
    @qscs       = QSCS
    @repfams    = {}
    @plotfiles  = {}
    @graphfiles = {}
    @mapfiles   = {}
    @results    = {}
    @mode       = controller_params['mode'] || 'background'
    
    @qscs.each  do |qsc|
      basename_w_qsc = basename + "." + qsc.to_s
      resultfile     = basename_w_qsc + ".hhrepid"
      graphfile      = basename_w_qsc + ".png"
      mapfile        = basename_w_qsc + ".map"
      
      next unless File.exists?(File.join(job_dir, resultfile))

      @graphfiles[qsc] = graphfile
      @mapfiles[qsc]   = mapfile

      File.open(File.join(job_dir, resultfile), 'r' ) do |f|
        rp = Bioinf::Repeats::HHrepidParser.new.parse!(f)

        @repfams[qsc]   = rp.repeat_families
        @plotfiles[qsc] = {}

        rp.repeat_families.each do |repfam|
          plotfile = basename_w_qsc+"_#{repfam.famid}"+".png"
          if File.exists?(File.join(job_dir, plotfile))
            @plotfiles[qsc][repfam.famid] = plotfile
          end
        end
      end

      res = IO.readlines(File.join(job_dir, resultfile)).map {|line| colorize(line) }.join.split(/Results for repeats type \w:\S*\n/)
      res.shift
      @results[qsc] = {}
      res.each_index do |i| 
        @results[qsc][ @repfams[qsc].map {|repfam| repfam.famid }.sort[i] ] = res[i] 
      end

    end
  end

  def colorize(line)
    if (line =~ /^\s*\S+\s+\S+\s+\d+-\d+\s+\+\d+\s+(\S+)\s*$/)
      # Found a sequence line
      seq = $1
      old_seq = seq.clone
      if (@mode == "letters")
        seq.gsub!(/([a-z.-]+)/, '<span style="color: #808080;">\1</span>')
        seq.gsub!(/([WYF]+)/, '<span style="color: #00a000;">\1</span>') 
        seq.gsub!(/([LIVM]+)/, '<span style="color: #00ff00;">\1</span>') 
        seq.gsub!(/([AST]+)/, '<span style="color: #404040;">\1</span>') 
        seq.gsub!(/([KR]+)/, '<span style="color: red;">\1</span>') 
        seq.gsub!(/([DE]+)/, '<span style="color: blue;">\1</span>') 
        seq.gsub!(/([QN]+)/, '<span style="color: #d000a0;">\1</span>') 
        seq.gsub!(/(H+)/, '<span style="color: #e06000;">\1</span>') 
        seq.gsub!(/(C+)/, '<span style="color: #a08000;">\1</span>') 
        seq.gsub!(/(P+)/, '<span style="color: #000000;">\1</span>') 
        seq.gsub!(/(G+)/, '<span style="color: #404040;">\1</span>') 

        line.sub!(/#{old_seq}/, "#{seq}")
      elsif (@mode == "background")
        seq.gsub!(/([WYF]+)/, '<span style="background-color: #00c000;">\1</span>') 
        seq.gsub!(/(C+)/, '<span style="background-color: #ffff00;">\1</span>') 
        seq.gsub!(/([DE]+)/, '<span style="background-color: #6080ff;">\1</span>') 
        seq.gsub!(/([LIVM]+)/, '<span style="background-color: #02ff02;">\1</span>') 
        seq.gsub!(/([KR]+)/, '<span style="background-color: #ff0000;">\1</span>') 
        seq.gsub!(/([QN]+)/, '<span style="background-color: #e080ff;">\1</span>') 
        seq.gsub!(/(H+)/, '<span style="background-color: #ff8000;">\1</span>') 
        seq.gsub!(/(P+)/, '<span style="background-color: #a0a0a0;">\1</span>') 

        line.sub!(/#{old_seq}/, "#{seq}")
      end 
    end
    return line
  end
  
end
