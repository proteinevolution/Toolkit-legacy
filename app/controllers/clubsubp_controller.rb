class ClubsubpController < ToolController

  def index
    getlinks
  end

  def browse
    getlinks
  end

  def genomes
    getlinks
    @accession=params['accession']
  end

  def cluster
    getlinks
    @name=params['name']
  end

  def protein
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
    @link_names = ["Browse Genomes", "Search Genomes"]
    @link_text = ["Browse the genomes", "Search the genomes"]
  end

end
