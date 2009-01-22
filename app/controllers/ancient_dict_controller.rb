class AncientDictController < ToolController

# definitions of the different rhtml pages
  def browse
    createfragments
    getlinks
    getsubitems
    @color = params['color'] ? params['color'] : "br"
    @coloring = params['coloring'] ? params['coloring'] : "fr"
    @fragment_description ="Fragments similar in structure and sequence, which are present
in at least two folds."
    @struct_fragment_description="Fragments found in domains with internal repeats"
  end

  def index
    getlinks
    @color = params['color'] ? params['color'] : "in"
  end

  def update
    getlinks
    @color = params['color'] ? params['color'] : "up"
  end

  def fragments
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "fr"
    getfragments
  end

  def repeats
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "re"
    getstructfragments
  end

  def fragment
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "fr"
    getfragments
    getkeywords
    getoccurrences
    @superpos = ["http://www.pdb.org/pdb/explore.do?structureId=1GW3", "Download PDB file"]
    getsequencealignment
    @refs = ["Alva V, Ammelburg M, Soeding J, Lupas AN. (2007) On the origin of the histone fold.  BMC Struct Biol 7: 17."]
    @pdb_url = "http://www.tuebingen.mpg.de"
  end

  def repeat
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "re"
    getfragments
    getkeywords
    getoccurrences
    @superpos = ["http://www.pdb.org/pdb/explore.do?structureId=1GW3", "Download PDB file"]
    getsequencealignment
    @refs = ["Alva V, Ammelburg M, Soeding J, Lupas AN. (2007) On the origin of the histone fold.  BMC Struct Biol 7: 17."]
    @pdb_url = "http://www.tuebingen.mpg.de"
  end


  def keywords
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "ke"
    getkeywords
  end

  def keyword
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "ke"
    getfragments
  end

  def search
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "se"
  end

# functions

  def createfragments
    mysql_frag = DAP_fragments.new
    mysql_frag.fragment_name = "Helix-Strand-Helix fragment"
    mysql_frag.save
    mysql_frag.fragment_name = "EF-Tu binding fragment"
    mysql_frag.save
  end

  def getlinks
    @shortlinks = ["in", "br", "up"]
    @links = ["index", "browse", "update"]
    @link_names = ["Description", "Browse Database", "Update Database"]
    @link_text = ["Description", "Browse the database", "Update the database"]
  end

  def getsubitems
    @subitem = ["fr", "re", "ke", "se"]
    @subitem_names = ["fragments", "repeats", "keywords", "search"]
    @subitem_text = ["Fragments", "Repeats", "Keywords", "Search"]
  end

  def getfragments
      @fragment_names = DAP_fragments.find(:all)
#    @fragment_names = ["Helix-Strand-Helix fragment","EF-Tu binding fragment"]
    @short_descriptions = ["A helix-strand-helix fragment common to three folds", "EF-Tu binding alpha-hairpin"]
    @descriptions = ["The Histone fold, the N-terminal substrate recognition domain of Clp/Hsp100 proteins and the helical part of the extended AAA+ ATPase domain contain a homologous helix-strand-helix motif (HSH). The HSH motif  probably gave rise to a domain in both Hsp100 and AAA+ proteins. The histone fold arose subsequently from the latter through a 3D domain-swapping event.", "Elongation Factor Ts and Ribosomal Protein L7/12 contain a common EF-Tu binding helix-turn-helix motif. The motif is remarkably similar with respect to fold, bulkiness, and charge distribution."]
    @pics= ["Helix-Strand-Helix","EF-Tu_binding"]
  end

  def getstructfragments
    @fragment_names = ["Ankyrin repeat","Beta-propeller blade"]
    @short_descriptions = ["33-residue alpha-hairpin fragment", "4-stranded beta-sheet fragment"]
    @descriptions = ["Fehlt noch", "Fehlt noch"]
    @pics= ["Bild2","Bild1"]
  end


  def getkeywords
    @keywords = ["DNA-binding", "Alpha-Beta-Alpha", "Helix-Strand-Helix", "Protein-Protein interaction", "Helix-Turn-Helix", "Structural Repeat"]
    @keywd_description = ["Binds SS/DS DNA in specific or non-specific way", "", "", "", "", "", ""]
  end

  def getoccurrences
    @scop_id = ["a.174.1.1", "c.37.1.20", "a.22.1.1","a.22.1.2", "a.22.1.3", "a.22.1.4"]
    @superfam = ["Double Clp-N fragment", "Extended AAA-ATPase domain", "Nucleosome core histones", "Archaeal histone", "TBP-associated factors, TAFs", "Bacterial histone-fold protein"]
    @pdb_applet= ["appleta.174.1", "appletc.37.1", "appleta.22.1", "appleta.22.1", "appleta.22.1", "appleta.22.1", "appleta.22.1"]
  end

  def getsequencealignment
    @seq_id=["d1k6ka_", "d1kx5c_", "d1f1ea_", "d1n1ja_", "d1tafa_", "d1h3ob_", "d1tafb_", "d1kx5b_", "d1kx5d_", "d1kx5a_", "d1fnna2", "d1g8pa_", "d1lv7a_", "d1in4a2"]
    @seq_scopid=["a.174.1.1", "a.22.1.1", "a.22.1.2", "a.22.1.3", "a.22.1.3", "a.22.1.3", "a.22.1.3", "a.22.1.1", "a.22.1.1", "a.22.1.1", "c.37.1.20", "c.37.1.20", "c.37.1.20", "c.37.1.20"]
    @pos_beg=["83", "58", "112", "37", "34", "37", "39", "61", "66", "99", "241", "273", "220", "206"]
    @pos_end=["112", "87", "141", "66", "63", "66", "68", "90", "95", "128", "270", "302", "249", "235"]
    @sequence=["SFQRVLQRAVFHVQSSGRNEVTGANVLVAI", "LTAEILELAGNAARDNKKTRIIPRHLQLAV", "ATEELGEKAAEYADEDGRKTVQGEDVEKAI", "FISFITSEASERCHQEKRKTINGEDILFAM", "YVTSILDDAKVYANHARKKTIDLDDVRLAT", "FIESVVTAACQLARHRKSSTLEVKDVQLHL", "KLKRIVQDAAKFMNHAKRQKLSVRDIDMSL", "FLENVIRDAVTYTEHAKRKTVTAMDVVYAL", "VFERIAGEASRLAHYNKRSTITSREIQTAV", "YLVALFEDTNLCAIHAKRVTIMPKDIQLAR", "LAIDILYRSAYAAQQNGRKHIAPEDVRKSS", "GELTLLRSARALAALEGATAVGRDHLKRVA", "DLANLVNEAALFAARGNKRVVSMVEFEKAK", "IAIRLTKRVRDMLTVVKADRINTDIVLKTM"]
  end

  def pdb_applet
    @file = params['file'] ? params['file'] : ""
    render(:layout => 'plain')
  end

  def keyword
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "ke"
    getfragments
  end

end
