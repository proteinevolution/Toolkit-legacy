require 'checked_hits'

class ProtBlastJob < Job
  include CheckedHits

  E_THRESH = 0.01
  
  attr_reader :header, :hits_better, :hits_worse, :alignments, :footer, :num_checkboxes

  @@export_ext = ".export"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end

  def evalue_threshold
    ProtBlastJob::E_THRESH
  end

  def hits_prev
    # see PsiBlastJob for comment
  end

  # Parse out the main components of the BLAST output file in preparation for result display
  def before_results(controller_params)
    @header, @alignments, @footer = show_hits(jobid + ".protblast", E_THRESH, "Expect", true)
    return true
  end

  def is_uniprot
    return uniprot?(@header)
  end
  
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end

end 





