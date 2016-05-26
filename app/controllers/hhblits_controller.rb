class HhblitsController < ToolController

  def index
    

    @inputmode_values = ["sequence", "alignment"]
    @inputmode_labels = ["single FASTA sequence", "alignment"]
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @match_mode_values = ['first','0','10','20','30','40','50','60', '70', '80', '90', '100']
    @match_mode_labels = ['residues of first sequence',
                          'no gaps',
                          'fraction of gaps <10%',
                          'fraction of gaps <20%',
                          'fraction of gaps <30%',
                          'fraction of gaps <40%',
                          'fraction of gaps <50%',
                          'fraction of gaps <60%',
                          'fraction of gaps <70%',
                          'fraction of gaps <80%',
                          'fraction of gaps <90%',
                          'assigning all columns to match states']
    @maxit = ['1','2','3','4','5','6','7','8']
    @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
    @EvalHHblits  = ['1e-4', '1e-3', '0.01','0.02','0.05', '0.1']
    @mactval = ['0.0', '0.01', '0.1', '0.2', '0.3','0.35', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '0.95']
    @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']

    suffix = '.cs219'

    searchpat = File.join(DATABASES, @tool['name'], '*' + suffix)

    # Dir.glob seems to return totally unsorted lists
    dbvalues_pre = Dir.glob(searchpat).sort {|x,y| 
      bx = File.basename(x, suffix)
      by = File.basename(y, suffix)
      (bx == by) ? 0 : bx.starts_with?(by) ? 1 : by.starts_with?(bx) ? -1 : by <=> bx
    }
    
    @dbvalues = Array.new
    @dblabels = Array.new

    sortlist = Array["uniprot", "nr"]
    # First sort according to sortlist. Under the same sortlist element,
    # keep sorting of dbvalues_pre. The databases have to be named
    # accordingly, i.e. uniprot20_2013_03, when newer databases are to be
    # listed first. The labels can be changed using a *.name.* file.

    # Allow non-standard libraries only on internal server:
    if (ENV['RAILS_ENV'] == 'development') then sortlist.push("\\w+") end
    sortlist.each do |el|
      dbvalues_pre.dup.each do |val|
        if (!val.index(/#{el}/).nil?)
          dbvalues_pre.delete(val)
          base = File.basename(val, suffix)
          dir = File.dirname(val)
          @dbvalues.push(File.join(dir, base))
          name = Dir.glob(File.join(dir, base + ".name*"))
          if (name.empty?)
            @dblabels.push(base)
          else
            name[0].gsub!(/^\S+\.name\.(\S+)$/, '\1')
            #@dblabels.push(base + "_" + name[0])
            @dblabels.push(name[0])
          end
          next
        end
      end
      
      
    end

    @default_db = @dbvalues[0]
    @realign = !(params[:realign].nil?)
    logger.debug "realign: #{params[:realign]}"
    
    # do we need to show output options part of the form?
    # @show_more_options = (@error_params['more_options_on'] == "true")
    more_options_param = !params['more_options_on'].nil? && params['more_options_on'] != "false"
    @show_more_options =  (more_options_param || @error_params['more_options_on']) ? true : nil
    logger.debug "params more opt: #{params['more_options_on']}"
    logger.debug "error params: #{@error_params['more_options_on']}"
    logger.debug "show_more_options: #{@show_more_options}"

    # handle dependencies
    @js_onload="adjustMatchModeValues();"
  end
  
  def results
    @widescreen = true
    @mode = params[:mode] ? params[:mode] : 'letters'
    @fw_values = [fw_to_tool_url('hhblits', 'aln2plot') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'alnviz') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'blastclust') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'cs_blast') + "&fw_mode=forward",
		              fw_to_tool_url('hhblits', 'seq2gi') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhblits') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhfilter') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhomp') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhpred') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhrep') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhrepid') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhsenser') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'psi_blast') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'quick2_d') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'reformat') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'repper') + "&fw_mode=forward"]
    # 15 Tools
    @fw_labels = [tool_title('aln2plot'), 
                  tool_title('alnviz'), 
                  tool_title('blastclust'), 
                  tool_title('cs_blast'), 
                  tool_title('seq2gi'), 
                  tool_title('hhblits'), 
                  tool_title('hhfilter'), 
                  tool_title('hhomp'), 
                  tool_title('hhpred'), 
                  tool_title('hhrep'), 
                  tool_title('hhrepid'), 
                  tool_title('hhsenser'),
                  tool_title('psi_blast'), 
                  tool_title('quick2_d'), 
                  tool_title('reformat'), 
                  tool_title('repper')]
                  
                   
                  
                  
                  
                  
                  
    @fw_values_msa = [fw_msa_to_tool_url('hhblits', 'hhblits')+ "&mode=querymsa",
                      fw_msa_to_tool_url('hhblits', 'hhpred')+ "&mode=querymsa",
                      fw_msa_to_tool_url('hhblits', 'hhrep')+ "&mode=querymsa",
                      fw_msa_to_tool_url('hhblits', 'hhrepid')+ "&mode=querymsa"]
                       
    @fw_labels_msa = [tool_title('hhblits'), tool_title('hhpred'), tool_title('hhrep'), tool_title('hhrepid')]
  end
  
  def histograms
    @widescreen = true
    @job.before_results(params)
    @fw_values = [fw_to_tool_url('hhblits', 'aln2plot') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'alnviz') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'blastclust') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'cs_blast') + "&fw_mode=forward",
		              fw_to_tool_url('hhblits', 'seq2gi') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhblits') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhfilter') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhomp') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhpred') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhrep') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhrepid') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'hhsenser') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'psi_blast') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'quick2_d') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'reformat') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'repper') + "&fw_mode=forward"]

    @fw_labels = [tool_title('aln2plot'), tool_title('alnviz'), tool_title('blastclust'), tool_title('cs_blast'), tool_title('seq2gi'), tool_title('hhblits'), 
                  tool_title('hhfilter'), tool_title('hhomp'), tool_title('hhpred'), tool_title('hhrep'), tool_title('hhrepid'), tool_title('hhsenser'),
                  tool_title('psi_blast'), tool_title('quick2_d'), tool_title('reformat'), tool_title('repper')]
  end
  
  def showalign
    @widescreen = true
    @resfile = @job.jobid+".fas"
    @mode = params['mode'] ? params['mode'] : "a3m"
    if (@mode == "a3m")
      @resfile = @job.jobid+"_out.a3m"
    end
  end

  def fullalign
    @widescreen = true
    @resfile = @job.jobid+".full.fas"
    @mode = params['mode'] ? params['mode'] : "a3m"
    if (@mode == "a3m")
      @resfile = @job.jobid+"_out.a3m"
    end
  end

  def reducedalign
    calculate_forwardings(@tool)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list
    #add_parameters_to_all_forwardings("&fw_mode=alignment")
    @widescreen = true
    @resfile = @job.jobid+".reduced.fas"
  end

  def representativealign
    @widescreen = true
    @resfile = @job.jobid+".fas"
  end

  def results_showtemplalign
    @job.actions.last.active = false
    @job.actions.last.save!
    @widescreen = true
  end
  
  def export_align_to_browser
    @job.set_export_ext(".fas")
    export_to_browser
  end
  
  def export_align_to_file
    @job.set_export_ext(".fas")
    export_to_file
  end
  
    def export_fullalign_to_browser
    @job.set_export_ext(".full.fas")
    export_to_browser
  end
  
  def export_fullalign_to_file
    @job.set_export_ext(".full.fas")
    export_to_file
  end
  
  def export_reducedalign_to_browser
    @job.set_export_ext(".reduced.fas")
    export_to_browser
  end
  
  def export_reducedalign_to_file
    @job.set_export_ext(".reduced.fas")
    export_to_file
  end
  
  
  
  def help_histograms
    render(:layout => "help")
  end
  
   def help_results
    render(:layout => "help")
  end

  def help_faq
    render(:layout => "help")
  end

  def resubmit_domain
    job_params = @job.actions.first.params
    job_params.each_key do |key|
      if (key =~ /^(\S+)_file$/) 
        if !job_params[key].nil? && File.exists?(job_params[key]) && File.readable?(job_params[key]) && !File.zero?(job_params[key])
          params[$1+'_input'] = IO.readlines(job_params[key]).join
        end
      else
        params[key] = job_params[key]
      end
    end

    start_seq = params[:domain_start].to_i
    end_seq = params[:domain_end].to_i - start_seq
    start_ali = -1
    end_ali = 0
    ali = FastaReader.new(File.join(@job.job_dir, @job.jobid + '.in'))
    ali.next do |h, s|
      while start_seq > 0
	start_ali = start_ali + 1
	start_seq = start_seq - 1 if s[start_ali] != ?-
      end
      end_ali = start_ali
      while end_seq > 0
	end_ali = end_ali + 1
	end_seq = end_seq - 1 if s[end_ali] != ?-
      end
    end
    ali.rewind
    domain = ''
    ali.each do |h, s|
      domain = domain + h + "\n"
      domain = domain + s[start_ali..end_ali] + "\n"
    end
    params[:sequence_input] = domain
    params[:jobid] = ''
    index
    render(:action => 'index')
  end
  
end
