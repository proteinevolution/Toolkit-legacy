class SimshiftController < ToolController
  
  def index
    @outputformat_labels = ["Residues", "Full Alignment"]
    @outputformat_values = ["residue", "fasta"]
    @default_outputformat = @outputformat_values[0]
    searchpath = File.join(DATABASES, @tool['name'], "*")
    dbvalues_pre = Dir.glob(searchpath)
    @dbvalues = Array.new
    
    
    # Sort list of directories according to order given in sortlist                   
    
    sortlist = Array["\/scop"]
    sortlist.each do |el|
      dbvalues_pre.dup.each do |val|
        if (!val.index(/#{el}/).nil?  && !(val=~/\.fas/))
          @dbvalues.push(val)
          dbvalues_pre.delete(val)
          next;
        end
      end
    end
    
    @dblabels = @dbvalues.collect{|e| File.basename(e)}
    @default_db = @dbvalues[0]
    
  end

  def results
     @widescreen = true
  end

  def help_residue_output
    render(:layout => "help")
  end
  
end
