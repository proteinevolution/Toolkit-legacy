class AncientDictController < ToolController

require 'rubygems'
require 'mysql'
require "activerecord"

before_filter :login_required, :only => [:update]
#before_filter :only =>[:update] #:login_required, :only => [:update]

# definitions of the different rhtml pages
  def browse
    getlinks
    getsubitems
    @color = params['color'] ? params['color'] : "br"
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
    getupdate_items
    @color = params['color'] ? params['color'] : "up"
    @category_values = ['frag_AA', 'frag_AB', 'frag_M', 'rep_AA', 'rep_AB', 'rep_M']
    @category_labels = ['frag_AA', 'frag_AB', 'frag_M', 'rep_AA', 'rep_AB', 'rep_M']
  end

  def fragments
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "fr"
  end

  def repeats
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "re"
  end

  def fragment
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "fr"
    @page = params['page']
    ali
    getsequencealignment
  end

  def repeat
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "re"
    @page = params['page']
    getsequencealignment
  end


  def keywords
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "ke"
  end

  def keyword
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "ke"
    @word = params['key']
  end

  def search
    getlinks
    @color = params['color'] ? params['color'] : "br"
    getsubitems
    @coloring = params['coloring'] ? params['coloring'] : "se"
  end

  def add
    getlinks
    getupdate_items
    @colors = params['colors'] ? params['colors'] : "aky"
    @color = params['color'] ? params['color'] : "up"
    @keyname="null"
  end

  def up
    getlinks
    getupdate_items
    @colors = params['colors'] ? params['colors'] : "uky"
    @color = params['color'] ? params['color'] : "up"
    @keypage = params['keypage'] ? params['keypage'] : ""

    if (@keypage == "")
      @tst = "kein Wert für keypage"
    else
      @tst = @keypage
    end

  end

  def delete
    getlinks
    getupdate_items
    @colors = params['colors'] ? params['colors'] : "dky"
    @color = params['color'] ? params['color'] : "up"
    @kpage = params['kpage'] ? params['kpage'] : ""
  end

  def addItem
    getlinks
    getupdate_items
    @colors = params['colors'] ? params['colors'] : "ait"
    @color = params['color'] ? params['color'] : "up"
    @entry = ['Fragment', 'Repeat']
    @item = params['item'] ? params['item'] : ""
    @cat_values = ['frag_AA', 'frag_AB', 'frag_M']
    @catrep_values = ['rep_AA', 'rep_AB', 'rep_M']
    @cat_labels = ['all alpha (Frag)', 'all beta (Frag)', 'mixed (Frag)']
    @catrep_labels = ['all alpha (Rep)', 'all beta (Rep)', 'mixed (Rep)']
    @key_values = Array.new()
    @key_labels = Array.new()
    @key_array = Dapkey.find(:all).each do |k_array|
      @key_values.push(k_array.k_id)
      @key_labels.push(k_array.k_name)
    end
  end

  def updateItem
    getlinks
    getupdate_items
    @colors = params['colors'] ? params['colors'] : "uit"
    @color = params['color'] ? params['color'] : "up"
    @itempage = params['itempage'] ? params['itempage'] : ""
    @cat_values = ['frag_AA', 'frag_AB', 'frag_M']
    @cat_labels = ['all alpha (Frag)', 'all beta (Frag)', 'mixed (Frag)']
    @key_val = Array.new()
    @key_lab = Array.new()
    @key_arr = Dapkey.find(:all).each do |k_arr|
      @key_val.push(k_arr.k_id)
      @key_lab.push(k_arr.k_name)
    end

  end

  def deleteItem
    getlinks
    getupdate_items
    @colors = params['colors'] ? params['colors'] : "del"
    @color = params['color'] ? params['color'] : "up"
    @ipage = params['ipage'] ? params['ipage'] : ""
  end

# links that are used in multiple pages

  def getlinks
    @shortlinks = ["in", "br"] #, "up"]
    @shortlinks_special = ["in", "br", "up"]
    @links = ["index", "browse", "update"]
    @link_names = ["Description", "Browse Database", "Update Database"]
    @link_text = ["Description", "Browse the database", "Update the database"]
  end

  def getsubitems
    @short_subitems = ["fr", "re", "ke"]#, "se"]
    @subitems = ["fragments", "repeats", "keywords"]#, "search"]
    @subitem_names = ["Fragments", "Repeats", "Keywords"]#, "Search"]
    @subitem_text = ["Display the fragments of the database", "Display the repeats of the database", "Display the keywords of the database"]#, "Search function of DAP"]
  end

  def getupdate_items
    @update_item = ["aky", "uky", "dky", "ait", "uit", "del"]
    @update_item_names = ["add", "up", "delete", "addItem", "updateItem", "deleteItem"]
    @update_item_text = ["Add Key", "Update Key", "Delete Key", "Add Item", "Update Item", "Delete Item"]
    @update_item_on_mouse = ["Add a new keyword", "Update an existing keyword", "Delete an existing keyword", "Add a new item (Fragment/Repeat)", "Update an existing item (Fragment/Repeat)", "Delete an existing item"]
  end


# functions

  def getsequencealignment
   @seq_id=["d1k6ka_", "d1kx5c_", "d1f1ea_", "d1n1ja_", "d1tafa_", "d1h3ob_", "d1tafb_", "d1kx5b_", "d1kx5d_", "d1kx5a_", "d1fnna2", "d1g8pa_", "d1lv7a_", "d1in4a2"]
   @seq_scopid=["a.174.1.1", "a.22.1.1", "a.22.1.2", "a.22.1.3", "a.22.1.3", "a.22.1.3", "a.22.1.3", "a.22.1.1", "a.22.1.1", "a.22.1.1", "c.37.1.20", "c.37.1.20", "c.37.1.20", "c.37.1.20"]
   @pos_beg=["83", "58", "112", "37", "34", "37", "39", "61", "66", "99", "241", "273", "220", "206"]
   @pos_end=["112", "87", "141", "66", "63", "66", "68", "90", "95", "128", "270", "302", "249", "235"]
   @sequence=["SFQRVLQRAVFHVQSSGRNEVTGANVLVAI", "LTAEILELAGNAARDNKKTRIIPRHLQLAV", "ATEELGEKAAEYADEDGRKTVQGEDVEKAI", "FISFITSEASERCHQEKRKTINGEDILFAM", "YVTSILDDAKVYANHARKKTIDLDDVRLAT", "FIESVVTAACQLARHRKSSTLEVKDVQLHL", "KLKRIVQDAAKFMNHAKRQKLSVRDIDMSL", "FLENVIRDAVTYTEHAKRKTVTAMDVVYAL", "VFERIAGEASRLAHYNKRSTITSREIQTAV", "YLVALFEDTNLCAIHAKRVTIMPKDIQLAR", "LAIDILYRSAYAAQQNGRKHIAPEDVRKSS", "GELTLLRSARALAALEGATAVGRDHLKRVA", "DLANLVNEAALFAARGNKRVVSMVEFEKAK", "IAIRLTKRVRDMLTVVKADRINTDIVLKTM"]
  end

  def ali
    @ali_file = File.join(IMAGES, "/alignmentHelixStrandHelix.ali")
    @test = false
    if (File.exists?(IMAGES + "/alignmentHelixStrandHelix.ali"))
        @test = true
    end
    @alignment ="\sd1k6ka_\e\sa.174.1.1\e&nbsp;83&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;112&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SFQR\aVL\qQR\aA\qVFHVQSSG\aR\qNE\qV\qTGA\aNV\qLVAI<br>\sd1kx5c_\e\s&nbsp;a.22.1.1\e&nbsp;58&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;87&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LTAE\aIL\qEL\aA\qGNAARDN\aKK\qTR\aI\qIPRH\aL\qQLAV<br>\sd1f1ea_\e\s&nbsp;a.22.1.2\e112&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;141&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ATEE\aL\qGEK\aA\qAEYADEDG\aR\qKT\aV\qQG\aEDV\qEKAI<br>\sd1n1ja_\e\s&nbsp;a.22.1.3\e&nbsp;37&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;66&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FISF\aI\qTSE\aA\qSERCHQE\aKR\qKT\aI\qNG\aEDI\qLFAM<br>\sd1tafa_\e\s&nbsp;a.22.1.3\e&nbsp;34&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;63&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;YVTS\aIL\qDD\aA\qKVYANHA\aRK\qKT\aI\qDL\aDDV\qRLAT<br>\sd1tafb_\e\s&nbsp;a.22.1.3\e&nbsp;39&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;68&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;KLKR\aIV\qQD\aA\qAKFMNHA\aKR\qQK\aL\qSVR\aDI\qDMSL<br>\sd1kx5b_\e\s&nbsp;a.22.1.1\e&nbsp;61&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;90&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FLEN\aVI\qRD\aA\qVTYTEHA\aKR\qKT\aV\qTAM\aDV\qVYAL<br>\sd1fnna2\e\sc.37.1.20\e241&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;270&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LAID\aIL\qYR\aS\qAYAAQQNG\aR\qKH\aI\qAP\aEDV\qRKSS<br>\sd1g8pa_\e\sc.37.1.20\e273&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;302&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GELT\aLL\qRS\aA\qRALAALEGATA\aV\qGR\aD\qH\aL\qKRVA<br>\sd1lv7a_\e\sc.37.1.20\e220&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;249&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DLAN\aLV\qNE\aA\qALFAARGN\aK\qRV\aV\qSMV\aEF\qEKAK<br>\sd1in4a2\e\sc.37.1.20\e206&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;235&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IAIR\aL\qTKRVRDMLTVV\aK\qADR\aI\qNT\aD\qI\aV\qLKTM"
        @alignment.gsub!(/(\s)/, '<a href="http://www.google.de">')
	@alignment.gsub!(/(\e)/, '</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;')
	@alignment.gsub!(/(\a)/, '<span style="background-color: #ffff00;">')
	@alignment.gsub!(/(\q)/, '</span>')
  end

end
