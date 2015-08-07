class ProtBlastpExportAction < Action

  HITLIST_LINE_PATTERN = /<a href\s*=\s*\#[^>]+>\s*[\deE\.+-]+<\/a>/
    
  attr_accessor :hits
	
  validates_checkboxes(:hits, {:on => :create})
	  
  def run
    @basename = File.join(job.job_dir, job.jobid)
    
    hits = params['hits']
    # Remove redundant hits
    hits.uniq!
    
    infile = @basename + ".protblastp"
    outfile = @basename + ".export"
    
    error if !File.readable?(infile) || !File.exists?(infile) || File.zero?(infile)
    res = IO.readlines(infile).map {|line| line.chomp}    
    hits_start = 1
    hits_end = 0
    res.each_index { |index|
      if (res[index]=~HITLIST_LINE_PATTERN)
        if (0 == hits_end)
          hits_start = index
        end
        hits_end = index
      elsif res[index]=~/^>/
        break
      elsif (hits_end > 0)
        break
      end
    }
    i = hits_start
    
    while (i < hits_end)
      if (res[i] =~ /#([^>]+)>\s*\S+?<\/a>\s+\S+\s*$/)
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
      line = res[i]
      if ((line=~/^\s*Database:/) || (line=~/^Lambda/)) then break end
      #><a name = 82736116><
      if (line =~ /^><a name =\s*([^>]+)>/ || line=~/^>.*?<a name=([^>]+)>/)
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

