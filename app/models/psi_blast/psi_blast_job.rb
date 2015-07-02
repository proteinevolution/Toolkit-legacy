require 'checked_hits'

class PsiBlastJob < Job
  include CheckedHits
  
  @@export_ext = ".export"
  # no longer used, take user evalue for next iterations  
  #E_THRESH   = 0.01
  @@MAX_DBS    = 5
  
  attr_reader :header, :hits_better, :hits_prev, :hits_worse, :alignments, :footer, :searching, :num_checkboxes, :evalue_threshold

  def set_export_ext(val)
    @@export_ext = val  
  end
  
  def get_export_ext
    @@export_ext
  end

  # Check if one of the selected databases is a Uniprot database
  def is_uniprot
    uniprot?(@header)
  end
  
  # Parse out the main components of the BLAST output file in preparation for result display
  def before_results(controller_params=nil)
    @evalue_threshold  = params_main_action['evalfirstit'].to_f
    @header, @alignments, @footer, @searching =
      show_hits(jobid + ".psiblast", evalue_threshold, "Expect", true, @@MAX_DBS)
  end
  
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
end 

