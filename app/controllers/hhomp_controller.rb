class HhompController < ToolController

  require 'open3'
  
  def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @maxpsiblastit = ['0','1','2','3','4','5','6','8','10']
    @epsiblastval = ['1E-3', '1E-4', '1E-6', '1E-8', '1E-10', '1E-15', '1E-20', '1E-30', '1E-40', '1E-50']
    @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
    @qid_minval = ['0', '20', '25', '30', '35', '40', '45', '50']
    @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']    
    searchpat = File.join(DATABASES, @tool['name'], 'db', '*.hhm')
    @dbvalues = (Dir.glob(searchpat)).sort
    @dblabels = @dbvalues.collect{ |e| (File.basename(e)).gsub!(/\.hhm/, '') }
    @default_db = @dbvalues[0]
  end
  
  def browse
    @id = params['jobid'] ? params['jobid'] : ""		
    @gi = params['gi'] ? params['gi'] : ""
    @page = params['page'] ? params['page'] : ""
    @tree = params['tree'] ? params['tree'] : ""
    @widescreen = true
    @map = ""
    @wza_map = ""
    @tolc_map = ""
    @search_results = []
    if (@job && @job.type.to_s == "HhompdbJob")
      @search_results = IO.readlines(File.join(@job.job_dir, @job.jobid + ".cluster"))
      @search_results.sort!
      @search_results.collect!{ |e| get_Name(e.chomp) }
    end 	
    
    @gi_seq = ""
    if (@gi != "")
      command = "#{File.join(BIOPROGS, 'blast32', 'fastacmd')} -d #{File.join(DATABASES, 'standard', 'nre')} -s '#{@gi}'"
      Open3.popen3(command) do |stdin, stdout, stderr|
        @gi_seq = stdout.readlines
      end
      if (!@gi_seq[0].nil?)
        @gi_seq[0].gsub!(/(.{70,100}\S\s)/, '\1'+"\n") 
      end
    end			
    
    if (@page == "")
      
      @mapfile = "#{IMAGES}/hhomp/all_small.map"
      if File.exist?(@mapfile) && File.size?(@mapfile)
        @map = IO.readlines(@mapfile).join
      end
      @mapfile = "#{IMAGES}/hhomp/wza_small.map"
      if File.exist?(@mapfile) && File.size?(@mapfile)
        @wza_map = IO.readlines(@mapfile).join
      end
      @mapfile = "#{IMAGES}/hhomp/tolc_small.map"
      if File.exist?(@mapfile) && File.size?(@mapfile)
        @tolc_map = IO.readlines(@mapfile).join
      end
      
    elsif (@page == "bigmap")
      
      @mapfile = "#{IMAGES}/hhomp/all.map"
      if File.exist?(@mapfile) && File.size?(@mapfile)
        @map = IO.readlines(@mapfile).join
      end
      @mapfile = "#{IMAGES}/hhomp/wza.map"
      if File.exist?(@mapfile) && File.size?(@mapfile)
        @wza_map = IO.readlines(@mapfile).join
      end
      @mapfile = "#{IMAGES}/hhomp/tolc.map"
      if File.exist?(@mapfile) && File.size?(@mapfile)
        @tolc_map = IO.readlines(@mapfile).join
      end
      
      
    elsif (@page == "table")
      # get all HMMs
      @OMP8 = ['Please select HMM']
      @OMP10 = ['Please select HMM']
      @OMP12 = ['Please select HMM']
      @OMP14 = ['Please select HMM']
      @OMP16 = ['Please select HMM']
      @OMP18 = ['Please select HMM']
      @OMP22 = ['Please select HMM']
      @OMP34 = ['Please select HMM']
      @OMP82 = ['Please select HMM']
      @OMPnn = ['Please select HMM']
      @nothom = ['Please select HMM']
      @hypo = ['Please select HMM']
      @cluster = ['Please select HMM']
      
      searchpat = File.join(DATABASES, @tool['name'], '*.hhm')
      hmms = Dir.glob(searchpat).collect { |e| (File.basename(e)).gsub!(/\.hhm/, '') }
      hmms.sort!			
      hmms.each do |hmm|
        if (hmm =~ /OMP\.8\./)
          @OMP8 << hmm
        elsif (hmm =~ /OMP\.10\./)
          @OMP10 << hmm
        elsif (hmm =~ /OMP\.12\./)
          @OMP12 << hmm
        elsif (hmm =~ /OMP\.14\./)
          @OMP14 << hmm
        elsif (hmm =~ /OMP\.16\./)
          @OMP16 << hmm
        elsif (hmm =~ /OMP\.18\./)
          @OMP18 << hmm
        elsif (hmm =~ /OMP\.22\./)
          @OMP22 << hmm
        elsif (hmm =~ /OMP\.nn\.1\./)
          @OMP82 << hmm
        elsif (hmm =~ /OMP\.nn\.8\./)
          @OMP34 << hmm
        elsif (hmm =~ /OMP\.nn\./)
          @OMPnn << hmm
        elsif (hmm =~ /OMP\.hypo\./)
          @hypo << hmm
        elsif (hmm =~ /cluster/)
          @cluster << hmm
        else
          @nothom << hmm
        end
      end
    else
      #get Cluster '@page'
      @name = ""
      @fullname = ""
      @length = ""
      @bbdom = ""
      @desc = ""
      @pdb = ""
      @pdb_url = ""
      res = []			
      
      # coloring alignment
      IO.readlines(File.join(DATABASES, @tool['name'], 'alignments', @page + ".reduced.clu")).each do |line|
        if (line =~ /^ss_pred\s+(\S+)/)
          seq = $1
          old_seq = $1
          seq.gsub!(/(H+)/, '<span style="background-color: #ffb0b0;">\1</span>')
          seq.gsub!(/(E+)/, '<span style="background-color: #b0b0ff;">\1</span>')
          line.sub!(/#{old_seq}/, "#{seq}")
        elsif (line =~ /^bb_pred\s+(\S+)/)
          seq = $1
          old_seq = $1
          seq.gsub!(/(D+)/, '<span style="background-color: #74e25f;">\1</span>')
          seq.gsub!(/(U+)/, '<span style="background-color: #f5c34a;">\1</span>')
          line.sub!(/#{old_seq}/, "#{seq}")
        elsif (line =~ /^\S+\s+(\S+)/)
          seq = $1
          old_seq = $1
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
        res << line
      end
      @ali = res.join			
      
      descfile = File.join(DATABASES, @tool['name'], @page + ".desc")			
      if (File.exists?(descfile)	&& File.readable?(descfile) && !File.zero?(descfile))
        @desc = IO.readlines(descfile).join
      end		
      
      pdbfile = File.join(DATABASES, @tool['name'], 'pdb', @page + ".pdb")			
      if (File.exists?(pdbfile)	&& File.readable?(pdbfile) && !File.zero?(pdbfile))
        @pdb = IO.readlines(pdbfile).join
        @pdb_url = url_for(:action => 'save_pdb', 'file' => pdbfile)
      end		
      
      
      res = []
      file = File.join(DATABASES, @tool['name'], @page + ".hhm")
      if File.exists?(file) && File.readable?(file) && !File.zero?(file)
        res = IO.readlines(file)
      end
      res.each do |line|
        if (line =~ /^NAME\s+(.*)$/)
          @fullname = $1
          if (@fullname =~ /^(.*?)\-\-\-/)
            @name = $1
            @fullname.sub!(/^cluster\d+\s+\-\-\-\s+/, '')
            # add links for super cluster
            @array = @fullname.split(/\-\-\-/)
            @array.map! do |tmp_hit|
              tmp_hit =~ /^\s*(\S+)\s+/;
              tmp_hit = "<a href='/hhomp/browse?page=#{$1}'>" + tmp_hit + "</a>"
            end
            @fullname = @array.join("---")
          else
            @name = @fullname
          end
          
        end
        if (line =~ /^LENG\s+(\d+)/)
          @length = $1
        end
        if (line =~ /^BBDOM\s(.*)$/)
          @bbdom = $1
        end
      end
    end
    
  end
  
  def get_Name(cluster)
    logger.debug "Cluster: #{cluster}"
    tempfile = File.join(DATABASES, 'hhomp', cluster + ".hhm")
    return "" if !File.readable?(tempfile) || !File.exists?(tempfile) || File.zero?(tempfile)
    lines = IO.readlines(tempfile)
    lines.each do |line|
      if (line =~ /^NAME\s+(\S.*?)\s*$/)
        return $1
      end
    end
    return ""
  end
  
  def save_pdb
    file = params['file']
    ret = IO.readlines(file).join
    filename = File.basename(file)
    send_data(ret, :filename => filename, :type => 'application/octet-stream')
    #redirect_to :back
  end
  
  def applet
    @tree = params['tree'] ? params['tree'] : ""
    render(:layout => 'plain')
  end	
	
  def results
    @fullscreen = true
    @mode = params[:mode] ? params[:mode] : 'onlySS'
  end
  
  def results_hhomp3d_templ
    render(:layout => 'plain')
  end
  
  def results_hhomp3d_querytempl
    @method_values = ['sup3d', 'tmalign', 'fast']
    @method_labels = ['HHomp', 'TMalign', 'FAST']
    render(:layout => 'plain')
  end
  
  def results_histograms
    @fullscreen = true
  end
  
  def showalign
    @fullscreen = true
  end
  
  def results_export
    super
    @fullscreen = true
  end
  
  def export_queryalign_to_browser
    @job.set_export_ext(".fas")
    export_to_browser
  end
  
  def export_queryalign_to_file
    @job.set_export_ext(".fas")
    export_to_file
  end
  
  def hhomp_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def hhomp_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def help_histograms
    render(:layout => "help")
  end

  def pdb_applet
    @file = params['file'] ? params['file'] : ""
    render(:layout => 'plain')
  end
  
  def help_results
    render(:layout => "help")
  end
  

end
