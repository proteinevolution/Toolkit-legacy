require 'checked_hits'

class CsBlastJob < Job
  include CheckedHits

  E_THRESH = 0.01
  @@MAX_DBS = 5
  
  attr_reader :header, :hits_better, :hits_worse, :alignments, :footer, :num_checkboxes , :evalue_threshold, :searching

  attr_accessor  :evalfirstit

 

  @@export_ext = ".export"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end

  # Parse out the main components of the BLAST output file in preparation for result display
  def hits_prev
    # see PsiBlastJob for comment
  end

  def before_results(controller_params)
    
     
     @evalue_threshold = params['evalfirstit'].to_f
     
     if(@evalue_threshold == 0.0)
        @evalue_threshold = E_THRESH
      else
        @evalue_threshold = params['evalfirstit'].to_f
     end

    @header, @alignments, @footer, @searching =
      show_hits(jobid + ".csblast", @evalue_threshold, "Expect", true, @@MAX_DBS)
    return true
  end
  
  def is_uniprot
    return uniprot?(@header)
  end
  
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
end 
