class PsiBlastpExportAction < Action
  
  attr_accessor :hits
  
  validates_checkboxes(:hits, {:on => :create})
  
  def run
    @basename = File.join(job.job_dir, job.jobid)
    
    hits = params['hits']
    # Remove redundant hits
    hits.uniq!
    
    logger.error "Hits: #{hits.inspect}"    
    
    infile = @basename + ".psiblastp"
    outfile = @basename + ".export"
    job.before_results
    
    res = job.header
    res << job.searching
    job.hits_better.each do |h|
      if( hits.include?(h[:id]) )
        res << h[:content]
      end
    end
    if( job.hits_prev.length>0 )
      res << "Sequences not found previously or not previously below threshold:\n"
    end
    job.hits_prev.each do |h|
      if( hits.include?(h[:id]) )
        res << h[:content]
      end
    end
    job.hits_worse.each do |h|
      if( hits.include?(h[:id]) )
        res << h[:content]
      end
    end
    res << "</PRE>" 
    res << ""
    job.alignments.each do |h|
      if( hits.include?(h[:id]) )
        res << "<PRE>"
        res << h[:content]
        res << "</PRE>"
      end
    end
    res << "<PRE>" 
    res << job.footer
    res << "</PRE>"

    out = File.new(outfile, "w+")
    out.write("<PRE>\n")
    out.write(res.join("\n"))
    out.write("</PRE>\n")
    out.close
    
    self.status = STATUS_DONE
    self.save!
    job.update_status
    @job.set_export_ext(".export")
  end
  
  def error
    self.status = STATUS_ERROR
    self.save!
    job.update_status
  end
  
end

