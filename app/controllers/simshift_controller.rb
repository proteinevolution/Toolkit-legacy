class SimshiftController < ToolController
  
  def index
    @outputformat_labels = ["Residues", "Full Alignment"]
    @outputformat_values = ["residue", "fasta"]
    @default_outputformat = @outputformat_values[0]
    searchpath = File.join(DATABASES, @tool['name'], "*")
    dbvalues_pre = Dir.glob(searchpath)
    @dbvalues = Array.new
    
    
    # Sort list of directories according to order given in sortlist                   
    
    sortlist = Array["\/pdb", "\/scop", "\/cdd", "\/interpro_", "\/pfamA_", "\/smart", "\/panther_", "\/tigrfam", "\/pirsf", "\/COG", "\/KOG", "\/CATH", "\/supfam", "\/pfam_", "\/pfamB_", "\/cd_", "\/test56", "\/test18", "\/Pfalciparum" ]
    sortlist.each do |el|
      dbvalues_pre.each do |val|
        if (!val.index(/#{el}/).nil?)
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
