class AncientDictController < ToolController

require 'rubygems'
require 'mysql'
require "activerecord"

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
    @color = params['color'] ? params['color'] : "up"
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

# functions

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
    @alignment ="\sd1k6ka_\e\sa.174.1.1\e&nbsp;83&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;112&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SFQRVLQRAVFHVQSSGRNEVTGANVLVAI<br>\sd1kx5c_\e\s&nbsp;a.22.1.1\e&nbsp;58&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;87&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LTAEILELAGNAARDNKKTRIIPRHLQLAV<br>\sd1f1ea_\e\s&nbsp;a.22.1.2\e112&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;141&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ATEELGEKAAEYADEDGRKTVQGEDVEKAI<br>\sd1n1ja_\e\s&nbsp;a.22.1.3\e&nbsp;37&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;66&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FISFITSEASERCHQEKRKTINGEDILFAM<br>\sd1tafa_\e\s&nbsp;a.22.1.3\e&nbsp;34&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;63&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;YVTSILDDAKVYANHARKKTIDLDDVRLAT<br>\sd1h3ob_\e\s&nbsp;a.22.1.3\e&nbsp;37&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;66&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FIESVVTAACQLARHRKSSTLEVKDVQLHL<br>\sd1tafb_\e\s&nbsp;a.22.1.3\e&nbsp;39&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;68&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;KLKRIVQDAAKFMNHAKRQKLSVRDIDMSL<br>\sd1kx5b_\e\s&nbsp;a.22.1.1\e&nbsp;61&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;90&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FLENVIRDAVTYTEHAKRKTVTAMDVVYAL<br>\sd1kx5d_\e\s&nbsp;a.22.1.1\e&nbsp;66&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;95&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VFERIAGEASRLAHYNKRSTITSREIQTAV<br>\sd1kx5a_\e\s&nbsp;a.22.1.1\e&nbsp;99&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;128&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;YLVALFEDTNLCAIHAKRVTIMPKDIQLAR<br>\sd1fnna2\e\sc.37.1.20\e241&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;270&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LAIDILYRSAYAAQQNGRKHIAPEDVRKSS<br>\sd1g8pa_\e\sc.37.1.20\e273&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;302&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GELTLLRSARALAALEGATAVGRDHLKRVA<br>\sd1lv7a_\e\sc.37.1.20\e220&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;249&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DLANLVNEAALFAARGNKRVVSMVEFEKAK<br>\sd1in4a2\e\sc.37.1.20\e206&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;235&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IAIRLTKRVRDMLTVVKADRINTDIVLKTM"
        @alignment.gsub!(/(\s)/, '<a href="http://www.google.de">')
	@alignment.gsub!(/(\e)/, '</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;')
        @alignment.gsub!(/([WYF]+)/, '<span style="background-color: #00a000;">\1</span>')
        @alignment.gsub!(/(C+)/, '<span style="background-color: #ffff00;">\1</span>')
        @alignment.gsub!(/([DE]+)/, '<span style="background-color: #c080ff;">\1</span>')
        @alignment.gsub!(/([LIVM]+)/, '<span style="background-color: #00ff00;">\1</span>')
        @alignment.gsub!(/([KR]+)/, '<span style="background-color: #ff0000;">\1</span>')
        @alignment.gsub!(/([QN]+)/, '<span style="background-color: #ffc0ff;">\1</span>')
        @alignment.gsub!(/(H+)/, '<span style="background-color: #d00000;">\1</span>')
        @alignment.gsub!(/(P+)/, '<span style="background-color: #808080;">\1</span>')
        @alignment.gsub!(/(G+)/, '<span style="background-color: #ffd070;">\1</span>')
  end

end
