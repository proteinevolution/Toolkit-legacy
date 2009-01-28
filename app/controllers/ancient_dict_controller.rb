class AncientDictController < ToolController

  def index
    @frag_values = ['all', 'dna', 'rna', 'zn']
    @frag_labels = ['All', 'DNA binding', 'RNA binding', 'Zn binding']
  end

  def search
    @motif = 'Helix-Strand-Helix motif'
    @keyword = 'DNA-binding; Alpha-Beta-Alpha; Helix-Strand-Helix'
    @descr = 'Dies ist die Beschreibung des Histons. Sie ist sehr interessant.'
    @occ = 'Das Histon kommt oft vor!!!!'
    @func = 'Es funktioniert auch sehr gut!!!!'
    @superpos = 'Tolle Position!'
    @seqali = 'Hier entsteht bald ein wunderschoenes buntes Alignment.'
    @ref = 'Ich habe dieses tolle Objekt erfunden und beschrieben.'
  end  
  
  def add
    @key_values = ['DNA', 'RNA', 'Zn', 'Beta']
    @key_labels = ['DNA binding', 'RNA binding', 'Zn binding', 'Beta-Strand-Beta']
  end 

end
