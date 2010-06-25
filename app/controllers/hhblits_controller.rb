class HhblitsController < ToolController

  def index
    @inputmode_values = ["sequence", "alignment"]
    @inputmode_labels = ["single FASTA sequence", "alignment"]
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @maxit = ['1','2','3','4','5','6','8','10']
    @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
    @epsiblastval = ['10', '100', '1000']
    @EvalHHblits  = ['1e-4', '1e-3', '1e-2', '0.1']
    @mactval = ['0.0', '0.01', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '0.95']
    @ss_scoring_values = ['2', '0', '4']
    @ss_scoring_labels = ['yes', 'no', 'predicted vs predicted only']
    @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']    
    
    @dbvalues = [File.join(DATABASES, 'standard', 'nr20cons'),File.join(DATABASES, 'standard', 'nr30cons')]
    @dbhhms = [File.join(DATABASES, 'nr20'),File.join(DATABASES, 'nr30')]
    @dblabels = ['NR20','NR30']

    @default_db = @dbvalues[0]
    @default_dbhhm = @dbhhms[0]
    
    # do we need to show output options part of the form?
    @show_more_options = (@error_params['more_options_on'] == "true")
  end
  
  def results
    @widescreen = true
    @mode = params[:mode] ? params[:mode] : 'letters'
    @fw_values = [fw_to_tool_url('hhblits', 'aln2plot') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'alnviz') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'blastclust') + "&fw_mode=forward",
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

    @fw_labels = [tool_title('aln2plot'), tool_title('alnviz'), tool_title('blastclust'), tool_title('seq2gi'), tool_title('hhblits'), tool_title('hhfilter'),
                  tool_title('hhomp'), tool_title('hhpred'), tool_title('hhrep'), tool_title('hhrepid'), tool_title('hhsenser'),
                  tool_title('psi_blast'), tool_title('quick2_d'), tool_title('reformat'), tool_title('repper')]
  end
  
  def histograms
    @widescreen = true
    @job.before_results(params)
    @fw_values = [fw_to_tool_url('hhblits', 'aln2plot') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'alnviz') + "&fw_mode=forward",
                  fw_to_tool_url('hhblits', 'blastclust') + "&fw_mode=forward",
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

    @fw_labels = [tool_title('aln2plot'), tool_title('alnviz'), tool_title('blastclust'), tool_title('seq2gi'), tool_title('hhblits'), tool_title('hhfilter'),
                  tool_title('hhomp'), tool_title('hhpred'), tool_title('hhrep'), tool_title('hhrepid'), tool_title('hhsenser'),
                  tool_title('psi_blast'), tool_title('quick2_d'), tool_title('reformat'), tool_title('repper')]
  end
  
  def showalign
    @widescreen = true
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
    ali = FastaReader.new(File.join(@job.job_dir, @job.jobid + '.fasta'))
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