class ClubsubpController < ToolController

  def index
    getlinks
  end

  def browse
    getlinks
  end

  def genomes
    getlinks
    @fullscreen = true
    @accession=params['accession']
  end

  def cluster
    getlinks
    @name=params['name']
  end

  def cluster_arch
    getlinks
    @name=params['name']
  end

  def protein
    getlinks
    @gi=params['gi']
  end

  def protein_arch
    getlinks
    @gi=params['gi']
  end

  def search
    getlinks
    @key=params['key']
  end

  def getlinks
    @shortlinks = ["br", "in"]
    @links = ["browse", "index"]
    @link_names = ["Browse Proteomes", "Search Proteomes"]
    @link_text = ["Browse the proteomes", "Search the proteomes"]
  end

  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('clubsubp', 'seq2gi') ,fw_to_tool_url('clubsubp', 'gi2seq')]
    @fw_labels = [tool_title('seq2gi'), tool_title('gi2seq')]
  end

end
