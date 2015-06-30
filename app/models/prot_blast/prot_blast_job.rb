require 'checked_hits'

class ProtBlastJob < Job
  include CheckedHits

  E_THRESH = 0.01
  @@MAX_DBS = 5
  
  attr_reader :header, :hits_better, :hits_worse, :hits_prev, :alignments, :footer, :num_checkboxes

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

  # Parse out the main components of the BLAST output file in preparation for result display
  def before_results(controller_params)
    @header, @alignments, @footer = show_hits(jobid + ".protblast", E_THRESH, "Expect", true, @@MAX_DBS)
    return true
  end

  def is_uniprot
    return uniprot?(@header)
  end
  
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end

end 





