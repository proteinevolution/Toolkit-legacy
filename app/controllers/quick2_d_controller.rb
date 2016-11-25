class Quick2DController < ToolController

	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@max_iter_allowed = ['1','2','3','4','5','8']
        @msa_gen_values = ['input_only', 'psiblast', 'hhblits']
        @msa_gen_labels = ['Use custom MSA', 'PSI-BLAST', 'HHblits']

        suffix = '.cs219'

        searchpat = File.join(DATABASES, "hhblits", '*' + suffix)

        # Dir.glob seems to return totally unsorted lists
        dbvalues_pre = Dir.glob(searchpat).sort {|x,y| 
          bx = File.basename(x, suffix)
          by = File.basename(y, suffix)
          (bx == by) ? 0 : bx.starts_with?(by) ? 1 : by.starts_with?(bx) ? -1 : by <=> bx
        }
        
        @dbvalues = Array.new
        @dblabels = Array.new

        sortlist = Array["uniprot", "uniclust"]
        # First sort according to sortlist. Under the same sortlist element,
        # keep sorting of dbvalues_pre. The databases have to be named
        # accordingly, i.e. uniprot20_2013_03, when newer databases are to be
        # listed first. The labels can be changed using a *.name.* file.

        # Allow non-standard libraries only on internal server:
        if (ENV['RAILS_ENV'] == 'development') then sortlist.push("\\w+") end
        sortlist.each do |el|
          dbvalues_pre.dup.each do |val|
            if (!val.index(/#{el}/).nil?)
              dbvalues_pre.delete(val)
              base = File.basename(val, suffix)
              dir = File.dirname(val)
              @dbvalues.push(File.join(dir, base))
              name = Dir.glob(File.join(dir, base + ".name*"))
              if (name.empty?)
                @dblabels.push(base)
              else
                name[0].gsub!(/^\S+\.name\.(\S+)$/, '\1')
                #@dblabels.push(base + "_" + name[0])
                @dblabels.push(name[0])
              end
              next
            end
          end
          
          
        end

        @default_db = @dbvalues[0]
	   end
 
    
 
end
