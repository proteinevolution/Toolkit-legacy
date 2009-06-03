class AncientDictAction < Action
  DAP = File.join(BIOPROGS, 'DAP')

  #attr_accessor :f_name, :f_id, :f_category
  attr_accessor :k_name, :k_desc, :k_upname, :k_updesc
  attr_accessor :f_name, :f_desc, :f_shortdesc, :f_cat, :f_ref, :f_figure

  #validates_presence_of(:f_name,
	#		:message => "The field should not be empty. Please add a name.",
	#		:on => :create)

  #validates_presence_of(:f_id,
	#		:message => "The field should not be empty. Please specify an ID.",
	#		:on => :create)


  # Put action initialisation code in here
  def before_perform
    #input add keyword
    @kname = params['k_name'] ? params['k_name'] : "NULL"
    @kdesc = params['k_desc'] ? params['k_desc'] : "NULL"

    logger.debug "k_name: #{@kname}"
    logger.debug "k_desc: #{@kdesc}"


    if (@kname != 'NULL')
      #@k_idnum=
      #logger.debug "num: #{@k_idnum}"
      @keys = Dapkey.find(:all)
      #@keys.each do |key|
       # if(@k_idnum<=key.id)
      @k_idnum=@keys.length
       # end
      #end
      @startid = 0
      @keyid= convertID('KEY', @k_idnum, @startid)

      logger.debug "idnum: #{@k_idnum}"
      #logger.debug "numstring: #{@idnumstring}"
      logger.debug "keyid: #{@keyid}"
    end

    # input add item (fragment or repeat)
    figure_directory = File.join(IMAGES, 'ancient_dict')

    @fitem = params['fitem'] ? params['fitem'] : "NULL"
    @fname = params['f_name'] ? params['f_name'] : "NULL"
    @fdesc = params['f_desc'] ? params['f_desc'] : "NULL"
    @fshortdesc = params['f_shortdesc'] ? params['f_shortdesc'] : "NULL"
    @fcategory = params['f_cat'] ? params['f_cat'] : "NULL"
    @fref = params['f_ref'] ? params['f_ref'] : "NULL"
    @fkeywords = params['f_keys'] ? params['f_keys'] : "NULL"
    @fscop = params['f_occ'] ? params['f_occ'] : "NULL"

    logger.debug "fitem: #{@fitem}"
    logger.debug "f_name: #{@fname}"
    logger.debug "f_desc: #{@fdesc}"
    logger.debug "f_shortdesc: #{@fshortdesc}"
    logger.debug "f_cat: #{@fcategory}"
    logger.debug "f_ref: #{@fref}"
    @fkeywords.each do |ks|
      logger.debug "f_key: #{ks}"
    end

    @occ = @fscop.split('\n')

    logger.debug "f_occ: #{@fscop}"

    @occ.each do |oc|
      logger.debug "occ_line: #{oc}"
      occ = oc.split('\t')
      logger.debug "occ_name: #{occ[0]}"
      logger.debug "occ_desc: #{occ[1]}"
    end


    @reference = @fref.split('\n')

    @reference.each do |refs|
      logger.debug "refs: #{refs}"
    end

    @itemid = ''

    if (@fname != 'NULL')
      @f_idnum=1
      logger.debug "f_num: #{@f_idnum}"
      if (@fitem == 'Fragment')
       fragaa = Dapfragment.find(:all, :conditions => "f_category = 'frag_AA'")
       @f_idnum+=fragaa.length
       fragab = Dapfragment.find(:all, :conditions => "f_category = 'frag_AB'")
       @f_idnum+=fragab.length
       fragm = Dapfragment.find(:all, :conditions => "f_category = 'frag_M'")
       @f_idnum+=fragm.length
       logger.debug "Amout of fragments: #{@f_idnum}"
       @itemid = convertID('FRAG', @f_idnum, 0)
       logger.debug "Converted ID: #{@itemid}"
       #@itemid = "FRAG"+@id_numstring
      else
       logger.debug "f_num: #{@f_idnum}"
       repaa = Dapfragment.find(:all, :conditions => "f_category = 'rep_AA'")
       @f_idnum+=repaa.length
       repab = Dapfragment.find(:all, :conditions => "f_category = 'rep_AB'")
       @f_idnum+=repab.length
       repm = Dapfragment.find(:all, :conditions => "f_category = 'rep_M'")
       @f_idnum+=repm.length
       logger.debug "Amout of repeats: #{@f_idnum}"
       @itemid = convertID('REP', @f_idnum, 0)
       #@itemid = "REP"+@id_numstring
      end

    end

    figure_file = @itemid + '.jpg'
    @figure_mysql = 'ancient_dict/images/' + figure_file
    @figure_filename = File.join(DATABASES, @figure_mysql)
    logger.debug "figure_filename #{@figure_filename}"

    #params_to_file(@infile, 'sequence_input', 'sequence_file')

    ali_file = @itemid + '.ali'
    ali_mysql = 'ancient_dict/' + ali_file
    ali_filename = File.join(figure_directory, ali_file)
    logger.debug "ali_filename #{ali_filename}"

    params['f_ali'] = ali_filename
    @fali = params['f_ali'] ? params['f_ali'] : "NULL"
    #params['f_figure'] = figure_filename
    @ffigure = params['f_figure'] ? params['f_figure'] : "NULL"


    if (@ffigure != 'NULL')
      params_to_file(@figure_filename, 'f_figure')
      logger.debug "figure_mysql: worked!"
    end

#    logger.debug "figure_mysql: #{figure_mysql}"
    logger.debug "ali_mysql: #{ali_mysql}"


    # input update keyword

    @kupname = params['k_upname'] ? params['k_upname'] : "NULL"
    @kupdesc = params['k_updesc'] ? params['k_updesc'] : "NULL"
    @kid = params['k_upid'] ? params['k_upid'] : "NULL"
    @id = params['upid'] ? params['upid'] : "NULL"


    logger.debug "Update key_name: #{@kupname}"
    logger.debug "Update key_desc: #{@kupdesc}"
    logger.debug "Keyword ID: #{@kid}"
    logger.debug "Mysql ID: #{@id}"


    # input update fragment (fragment/repeat)

    @fid = params['upfrid'] ? params['upfrid'] : "NULL"
    @frag_id = params['f_upid'] ? params['f_upid'] : "NULL"
    @frag_name = params['f_upname'] ? params['f_upname'] : "NULL"
    @frag_desc = params['f_updesc'] ? params['f_updesc'] : "NULL"
    @frag_shortdesc = params['f_upshortdesc'] ? params['f_upshortdesc'] : "NULL"
    @frag_occ = params['f_upocc'] ? params['f_upocc'] : "NULL"
    @frag_ref = params['f_upref'] ? params['f_upref'] : "NULL"
    @frag_key = params['f_upkeys'] ? params['f_upkeys'] : "NULL"
    @frag_fig = params['f_upfigure'] ? params['f_upfigure'] : "NULL"
    @frag_align = params['f_upali'] ? params['f_upali'] : "NULL"

    if (@frag_fig != 'NULL')
      @frag_figure = 'ancient_dict/images/' + @frag_id + '.jpg'
      @figure_name = File.join(DATABASES, @frag_figure)
      params_to_file(@figure_name, 'frag_fig')
    end

    if (@frag_ali != 'NULL')
      @frag_align = 'ancient_dict/alignments/' + @frag_id + '.ali'
      @ali_name = File.join(DATABASES, @frag_align)
      params_to_file(@ali_name, 'frag_align')
    end

    @upreference = @frag_ref.split('\n')

    logger.debug "Mysql frag ID: #{@fid}"
    logger.debug "Fragment ID: #{@frag_id}"
    logger.debug "Update frag_name: #{@frag_name}"
    logger.debug "Update frag_desc: #{@frag_desc}"
    logger.debug "Update frag_shortdesc: #{@frag_shortdesc}"
    logger.debug "Update frag_occ: #{@frag_occ}"
    logger.debug "Update frag_ref: #{@frag_ref}"
    logger.debug "Update frag_figure: #{@frag_figure}"
    logger.debug "Update frag_align: #{@frag_align}"


    # input delete keyword

    @delid = params['delid'] ? params['delid'] : "NULL"
    @k_delid = params['k_delid'] ? params['k_delid'] : "NULL"

    logger.debug "Delete ID: #{@delid}"
    logger.debug "Delete K_id: #{@k_delid}"

    # input delete item (fragment/repeat)

    @del_f_id = params['del_f_id'] ? params['del_f_id'] : "NULL"
    @f_delid = params['f_delid'] ? params['f_delid'] : "NULL"

    logger.debug "Delete ID: #{@del_f_id}"
    logger.debug "Delete F_id: #{@f_delid}"

  end



  # Put action code in here
  def perform

    # add new keyword

    if (@kname != 'NULL')
      addkey=Dapkey.new(:k_id => @keyid, :k_name => @kname, :k_desc => @kdesc)
      addkey.save!
      logger.debug "Dapkey added! k_id: #{@keyid}, k_name: #{@kname}, k_desc #{@kdesc}"
    end

    # add new fragment

    if (@fname != 'NULL')
      additem=Dapfragment.new(:f_id => @itemid, :f_name => @fname, :f_desc => @fdesc, :f_shortdesc => @fshortdesc, :f_category => @fcategory, :f_ref => @fref, :f_figure => @figure_mysql, :f_align => @ali)
      additem.save!
      logger.debug "Dapfragment added! f_id: #{@itemid}, f_name: #{@fname}, f_desc: #{@fdesc}, f_shortdesc: #{@fshortdesc}, f_category: #{@fcategory}, f_ref: #{@fref}, f_figure: #{@figure_mysql}, f_align #{@fali}"
      @fkeywords.each do |ky|
        addfragkey=DapfragmentDapkey.new(:f_id => @itemid, :k_id => ky)
        addfragkey.save!
        logger.debug "DapfragmentDapkey added: f_id: #{@itemid}, k_id: #{ky}"
      end

      @reference.each do |ref|
        refid = generateRefID(1)
        addref = Dapref.new(:r_id => refid, :r_reference => ref, :f_id => @itemid)
        addref.save!
        logger.debug "Dapref added: r_id: #{refid}, r_reference:  #{ref}, f_id: #{@itemid}"
      end

      @occ.each do |scop|
        occ = scop.split('\t')
        scop_id=occ[0]
        scop_desc=occ[1]
        if (!Dapscop.find(:first, :conditions => ["scop_id=?", scop_id]))
          addscop = Dapscop.new(:scop_id => scop_id, :scop_desc => scop_desc)
          addscop.save!
          logger.debug "Dapscop added: scop_id: #{occ[0]}, scop_desc: #{occ[1]}"
        end
        addocc = Dapoccurrence.new(:f_id => @itemid, :scop_id => occ[0])
        addocc.save!
        logger.debug "Dapoccurrence added: f_id: #{@itemid}, scop_id: #{occ[0]}"
      end

    end


    # update keyword

    if (@kupname != 'NULL')
      upkey=Dapkey.find(@id)
      upkey.update_attributes(:k_id => @kid, :k_name => @kupname, :k_desc => @kupdesc)
      upkey.save!
      logger.debug "Dapkey updated! k_id: #{@kid},  k_name: #{@kupname}, k_desc: #{@kupdesc}"
    end

    # update fragment

    if (@frag_name != 'NULL')
      logger.debug "Fragment ID: #{@fid}"
      upfrag=Dapfragment.find(@fid)
      if (@frag_fig != 'NULL')
        if (@frag_align != 'NULL')
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_figure => @frag_figure, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc, :f_align => @frag_align)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_figure: #{@frag_figure}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}, f_align: #{@frag_align}"
        else
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_figure => @frag_figure, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_figure: #{@frag_figure}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}"
        end
      else
        if (@frag_align != 'NULL')
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc, :f_align => @frag_align)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}, f_align: #{@frag_align}"
        else
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}"
        end
      end


      Dapref.find(:all, :conditions => ["f_id=?", @frag_id]).each do |delref|
        Dapref.delete(delref.id)
      end

      @upreference.each do |refup|
        uprefid = generateRefID(1)
        upref = Dapref.new(:r_id => uprefid, :r_reference => refup, :f_id => @frag_id)
        upref.save!
        logger.debug "Dapref added: r_id: #{uprefid}, r_reference:  #{refup}, f_id #{@frag_id}"
      end

    if (@frag_key != 'NULL')
      @frag_key.each do |frag_keys|
        addfragkey=DapfragmentDapkey.new(:f_id => @frag_id, :k_id => frag_keys)
        addfragkey.save!
        logger.debug "DapfragmentDapkey added: f_id: #{@frag_id}, k_id: #{frag_keys}"
      end
    end

    Dapoccurrence.find(:all, :conditions => ["f_id=?", @frag_id]).each do |delocc|
        Dapref.delete(delocc.id)
    end

    @frag_occ.each do |occup|
      occ = occup.split('\t')
      scop_id=occ[0]
      upocc = Dapocc.new(:scop_id => scop_id, :f_id => @frag_id)
      upocc.save!
      logger.debug "Dapocc added: scop_id: #{scop_id}, f_id #{@frag_id}"
    end
  end  

    # delete keyword

    if (@delid != "NULL")
      Dapkey.delete(@delid)

      logger.debug "Dapkey deleted! id: #{@delid}, k_id: #{@k_delid}"

      #DapfragmentDapkey.find(:all, :conditions => ["k_id=?", @k_delid]).each do |delkey|
      if (DapfragmentDapkey.find(:first, :conditions => ["k_id=?", @k_delid]))
        DapfragmentDapkey.find(:all, :conditions => ["k_id=?", @k_delid]).each do |delkey|
          DapfragmentDapkey.delete(delkey.id)
          logger.debug "DapfragmentDapkey deleted! id: #{delkey.id}, f_id: #{delkey.f_id}, k_id: #{delkey.k_id}"
        end
      end
    end

    # delete fragment

    if (@del_f_id != "NULL")
      #Dapfragment.delete(@del_f_id)

      #logger.debug "Dapfragment deleted! id: #{@del_f_id}, f_id: #{@f_delid}"

      #DapfragmentDapkey.find(:all, :conditions => ["f_id=?", @f_delid]).each do |delfrag|
      if (DapfragmentDapkey.find(:first, :conditions => ["f_id=?",@f_delid]))
        logger.debug "Eintrag existiert!"
        DapfragmentDapkey.find(:all, :conditions => ["f_id=?",@f_delid]).each do |delfrag|
          logger.debug "Delfrag: #{delfrag.f_id}, #{delfrag.k_id}"
          DapfragmentDapkey.delete(delfrag.id)
          logger.debug "DapfragmentDapkey deleted! id: #{delfrag.id}, f_id: #{delfrag.f_id}, k_id: #{delfrag.k_id}"
        end
      end

      logger.debug "DapfragmentDapkey gelöscht!"

      if (Dapoccurrence.find(:first, :conditions => ["f_id=?", @f_delid]))
        logger.debug "Eintrag vorhanden!"
        Dapoccurrence.find(:all, :conditions => ["f_id=?", @f_delid]).each do |delocc|
          Dapoccurrence.delete(delocc.id)
          logger.debug "Dapoccurrence deleted! id: #{delocc.id}, f_id: #{delocc.f_id}, scop_id: #{delocc.scop_id}"
        end
      end

      Dapfragment.delete(@del_f_id)

      logger.debug "Dapfragment deleted! id: #{@del_f_id}, f_id: #{@f_delid}"

    end
  end

  def convertID(string, length, start_num)
    length+=start_num
    finid=''
    if (length < 10)
      num = "00"+length.to_s()
      finid=string+num
    elsif (length <100 && length >= 10)
      num = "0"+length.to_s()
      finid=string+num
    else
      finid=string+length.to_s()
    end
    logger.debug "ID: #{finid}"
    if (string == 'KEY')
      if (Dapkey.find(:first, :conditions => ["k_id=?", finid]))
        finid=convertID(string, length, start_num+1)
      end
    else
      if (Dapfragment.find(:first, :conditions => ["f_id=?", finid]))
        finid=convertID(string, length, start_num+1)
      end
    end
    return finid
  end

  def generateRefID(refnum)
    startnum = refnum
    findref = Dapref.find(:all)
    refnum+=findref.length
    @refstring=convertID('REF', refnum, startnum)
    #@refid="REF"+@refstring
    #if (Dapref.find(:first, :conditions => ["r_id=?", @refid]))
    #  @refid=generateRefID(startnum+1)
    #end
    return @refid
  end

  def create_entry_file
    file = File.new(@file, "w")
    file.puts "#name-begin"
    file.puts @name
    file.puts "#name-end"
    file.puts "#id-begin"
    file.puts @id
    file.puts "#id-end"
    file.puts "#category-begin"
    file.puts @category
    file.puts "#category-end"
    file.puts "#keywords-begin"
    file.puts @keywords
    file.puts "#keywords-end"
    file.puts "#relatedto-begin"
    file.puts @related
    file.puts "#relatedto-end"
    file.puts "#shortdescription-begin"
    file.puts @shortdesc
    file.puts "#shortdescription-end"
    file.puts "#description-begin"
    file.puts @desc
    file.puts "#description-end"
    file.puts "#occurrence-begin"
    file.puts @occ
    file.puts "#occurrence-end"
    file.puts "#sequencealignment-begin"
    file.puts @ali
    file.puts "#sequencealignment-end"
    file.puts "#references-begin"
    file.puts @ref
    file.puts "#references-end"
    file.puts "#image-begin"
    file.puts @image
    file.puts "#image-end"
    file.closed?
    file.close
  end


end




