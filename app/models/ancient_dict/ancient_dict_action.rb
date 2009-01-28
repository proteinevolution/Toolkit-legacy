class AncientDictAction < Action

  attr_accessor :motif_text, :keywords, :motif_figure, :occurrence, :function_text, :function_figure, :function_legend, :structure_superposition, :sequence_ali, :references


  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @outfile = @basename+".out"

   
  end  
  

  def perform
  end

  def add
  end

  def show_entry
  end

end




