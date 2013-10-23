class Aln2plotController < ToolController

	def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
	end
  
  def export_png_to_file
    pngnr = params[:pngnr]
    export_png_n_to_file(pngnr)
  end
  
  private

    def export_png_n_to_file(pngnr)
      @job.set_export_ext("-#{pngnr}.png")
      export_to_file
    end
  
end
