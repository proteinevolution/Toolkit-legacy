class ClubsubpController < ToolController

  def index
    getlinks
  end

  def browse
    getlinks
  end

  def description
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
    @shortlinks = ["de", "br", "in"]
    @links = ["description", "browse", "index"]
    @link_names = ["Description", "Browse Genomes", "Search Genomes"]
    @link_text = ["Description", "Browse the genomes", "Search the genomes"]
  end

end
