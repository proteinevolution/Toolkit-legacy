class AncientDictController < ToolController

  def browse
    @subitem = ["mo", "ke"]
    @subitem_names = ["motifs", "keywords"]
    @coloring = params['coloring'] ? params['coloring'] : "mo"
    getmotifs
    getkeywords
    getoccurrences
    @superpos = ["http://www.pdb.org/pdb/explore.do?structureId=1GW3", "Download PDB file"]
    getsequencealignment
    @refs = ["Alva V, Ammelburg M, Soding J, Lupas AN. (2007) On the origin of the histone fold.  BMC Struct Biol 7: 17."]
  end

  def index
    @subitem = ["mo", "ke"]
    @subitem_names = ["motifs", "keywords"]
    @coloring = params['coloring'] ? params['coloring'] : "mo"
  end

  def update
    @subitem = ["mo", "ke"]
    @subitem_names = ["motifs", "keywords"]
    @coloring = params['coloring'] ? params['coloring'] : "mo"
  end

  def motifs
    getmotifs
    @subitem = ["mo", "ke"]
    @subitem_names = ["motifs", "keywords"]
    @coloring = params['coloring'] ? params['coloring'] : "mo"
  end

  def motif
    @subitem = ["mo", "ke"]
    @subitem_names = ["motifs", "keywords"]
    @coloring = params['coloring'] ? params['coloring'] : "mo"
    getmotifs
    getkeywords
    getoccurrences
    @superpos = ["http://www.pdb.org/pdb/explore.do?structureId=1GW3", "Download PDB file"]
    getsequencealignment
    @refs = ["Alva V, Ammelburg M, Soding J, Lupas AN. (2007) On the origin of the histone fold.  BMC Struct Biol 7: 17."]
    @pdb_url = "http://www.google.de"
  end

  def keywords
    getkeywords
    @subitem = ["mo", "ke"]
    @subitem_names = ["motifs", "keywords"]
    @coloring = params['coloring'] ? params['coloring'] : "ke"
  end

  def getmotifs
    @motif_names = ["Helix-Strand-Helix motif","EF-Tu binding motif"]
    @short_descriptions = ["The Histone fold, the N-terminal substrate recognition domain of Clp/Hsp100 proteins.", "The motif is remarkably similar with respect to fold, bulkiness, and charge distribution."]
    @descriptions = ["The Histone fold, the N-terminal substrate recognition domain of Clp/Hsp100 proteins and the helical part of the extended AAA+ ATPase domain contain a homologous helix-strand-helix motif (HSH). The HSH motif  probably gave rise to a domain in both Hsp100 and AAA+ proteins. The histone fold arose subsequently from the latter through a 3D domain-swapping event.", "Elongation Factor Ts and Ribosomal Protein L7/12 contain a common EF-Tu binding helix-turn-helix motif. The motif is remarkably similar with respect to fold, bulkiness, and charge distribution."]
    @pics= ["Helix-Strand-Helix","EF-Tu_binding"]
  end

  def getkeywords
    @keywords = ["DNA-binding", "Alpha-Beta-Alpha", "Helix-Strand-Helix"," Protein-Binding", "Protein-Protein interaction", "Helix-Turn-Helix", "Structural Repeat"]
    @keywd_description = ["DNA-binding domains and thus have a specific or general affinity for either single or double stranded DNA.", "", "", "", "", "", ""]
  end

  def generatemotif
  end

  def getoccurrences
    @scop_id = ["a.174.1", "c.37.1", "a.22.1","a.22.1", "a.22.1", "a.22.1"]
    @superfam = ["Double Clp-N motif", "Extended AAA-ATPase domain", "Nucleosome core histones", "Archaeal histone", "TBP-associated factors, TAFs", "Bacterial histone-fold protein"]
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
    @subitem = ["mo", "ke"]
    @subitem_names = ["motifs", "keywords"]
    @coloring = params['coloring'] ? params['coloring'] : "ke"
    getmotifs
  end

end
