class ProtBlastExportAction < Action
    
  attr_accessor :hits
	
  validates_checkboxes(:hits, {:on => :create})
	  
  def run
    @basename = File.join(job.job_dir, job.jobid)
    
    hits = params['hits']
    # Remove redundant hits
    hits.uniq!
    
    infile = @basename + ".protblast"
    outfile = @basename + ".export"
    
    error if !File.readable?(infile) || !File.exists?(infile) || File.zero?(infile)
    res = IO.readlines(infile).map {|line| line.chomp}    
    i = res.index('Sequences producing significant alignments:                      (bits) Value')
    
    while (i < res.size)
      if (res[i] =~ /<\/PRE>/i) then break end
      if (res[i] =~ /#(\d+)>\s*\S+<\/a>\s+\S+\s*$/)
        if hits.include?($1)
          i += 1
        else
          res.delete_at(i)
        end
      else
        i += 1
      end        
    end

    check = true
    while (i < res.size)
      if (res[i] =~ /^\s*Database:/) then break end
      #><a name = 82736116><
      if (res[i] =~ /^\s*><a name = (\d+)>/)
        if hits.include?($1)
          check = true
          i += 1
        else
          check = false
          res.delete_at(i)
        end
      else
        if check
          i += 1
        else
          res.delete_at(i)
        end
      end
    end

    out = File.new(outfile, "w+")
    out.write(res.join("\n"))
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

