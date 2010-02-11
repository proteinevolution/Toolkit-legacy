class ClubsubpController < ToolController

  def index
    getlinks
  end

  def genomes
    getlinks
  end

  def search
    getlinks
  end

  def getlinks
    @shortlinks = ["in", "ge", "se"]
    @links = ["index", "genomes", "search"]
    @link_names = ["Description", "Browse Genomes", "Search Genomes"]
    @link_text = ["Description", "Browse the genomes", "Search the genomes"]
  end

end
