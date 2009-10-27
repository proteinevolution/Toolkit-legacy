class AncientDictAction < Action

#  require 'activerecord'

  DAP = File.join(BIOPROGS, 'DAP')

  attr_accessor :k_name, :k_desc, :k_upname, :k_updesc
  attr_accessor :f_name, :f_desc, :f_shortdesc, :f_cat, :f_ref, :f_figure

  # Put action initialisation code in here
  def before_perform
    #input add keyword
    @kname = params['k_name'] ? params['k_name'] : "NULL"
    @kdesc = params['k_desc'] ? params['k_desc'] : "NULL"

    logger.debug "k_name: #{@kname}"
    logger.debug "k_desc: #{@kdesc}"




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

    logger.debug "f_name: #{@fname}"
    @fkeywords.each do |ks|
     # logger.debug "f_key: #{ks}"
    end

    @occ = @fscop.split('\n')

    @occ.each do |oc|
     # logger.debug "occ_line: #{oc}"
      occ = oc.split('\t')
     # logger.debug "occ_name: #{occ[0]}"
     # logger.debug "occ_desc: #{occ[1]}"
    end


    @reference = @fref.split('\n')

    @reference.each do |refs|
      #logger.debug "refs: #{refs}"
    end

    @itemid = ''



   # input update keyword

    @kupname = params['k_upname'] ? params['k_upname'] : "NULL"
    @kupdesc = params['k_updesc'] ? params['k_updesc'] : "NULL"
    @kid = params['k_upid'] ? params['k_upid'] : "NULL"
    @id = params['upid'] ? params['upid'] : "NULL"


    logger.debug "Update key_name: #{@kupname}"
#    logger.debug "Update key_desc: #{@kupdesc}"
#    logger.debug "Keyword ID: #{@kid}"
#    logger.debug "Mysql ID: #{@id}"


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
    @frag_cat = params['f_upcat'] ? params['f_upcat'] : "NULL"

    if (@frag_fig != 'NULL')
      @figures = read_dir_entries(@frag_id)
      @len = @figures.length
      if (@len == 1)
        @frag_figure = 'ancient_dict/images/' + @frag_id + '_up.png'
        #@frag_figure = 'ancient_dict/images/' + @frag_id + '_up.jpg'
      else
        @frag_figure = 'ancient_dict/images/' + @frag_id + '_up'+@figures.length.to_s()+'.png'
        #@frag_figure = 'ancient_dict/images/' + @frag_id + '_up'+@figures.length.to_s()+'.jpg'
      end
      logger.debug "frag_figure: #{@frag_figure}"
      @figure_name = File.join(DATABASES, @frag_figure)
      params_to_file(@figure_name, 'f_upfigure')
    end

    @up_alignment = ''
    if (@frag_align != 'NULL')
      @frag_ali = 'ancient_dict/alignments/' + @frag_id + '.ali'
      @ali_name = File.join(DATABASES, @frag_ali)
      params_to_file(@ali_name, 'frag_align')
     # logger.debug "ali_mysql: #{@ali_name}"
      @up_alignment=print_alignment(@frag_align)#(@ali_name)
     # logger.debug "Alignment update: #{@up_alignment}"
    end

    @up_occ = @frag_occ.split('\n')

    @upreference = @frag_ref.split('\n')

   # logger.debug "Mysql frag ID: #{@fid}"
   # logger.debug "Fragment ID: #{@frag_id}"
   # logger.debug "Update frag_name: #{@frag_name}"
   # logger.debug "Update frag_desc: #{@frag_desc}"
   # logger.debug "Update frag_shortdesc: #{@frag_shortdesc}"
   # logger.debug "Update frag_occ: #{@frag_occ}"
    logger.debug "Update frag_ref: #{@frag_ref}"
    logger.debug "Update frag_figure: #{@frag_figure}"
    logger.debug "Update frag_align: #{@frag_align}"


    # input delete keyword

    @delid = params['delid'] ? params['deilid'] : "NULL"
    @k_delid = params['k_delid'] ? params['k_delid'] : "NULL"

   # logger.debug "Delete ID: #{@delid}"
   # logger.debug "Delete K_id: #{@k_delid}"

    # input delete item (fragment/repeat)

    @del_f_id = params['del_f_id'] ? params['del_f_id'] : "NULL"
    @f_delid = params['f_delid'] ? params['f_delid'] : "NULL"

   # logger.debug "Delete ID: #{@del_f_id}"
   # logger.debug "Delete F_id: #{@f_delid}"

  end



  # Put action code in here
  def perform

    # add new keyword

    if (@kname != 'NULL')
      @k_idnum=1
      logger.debug "vor Dapkey.find"
      @keys=Dapkey.find(:all)
      logger.debug "nach Dapkey.find"
      if @keys
        @k_idnum+=@keys.length
        logger.debug "@k_idnum #{@k_idnum}"
      end
      @startid = 0
      @keyid= convertID('KEY', @k_idnum, @startid)
#
      logger.debug "idnum: #{@k_idnum}"
      logger.debug "keyid: #{@keyid}"
#
      addkey=Dapkey.new(:k_id => @keyid, :k_name => @kname, :k_desc => @kdesc)
      addkey.save!
      logger.debug "Dapkey added! k_id: #{@keyid}, k_name: #{@kname}, k_desc #{@kdesc}"
    end

    # add new fragment

    if (@fname != 'NULL')

      @f_idnum=1
      # logger.debug "f_num: #{@f_idnum}"
      if (@fitem == 'Fragment')
       fragaa = Dapfragment.find(:all, :conditions => "f_category = 'frag_AA'")
       logger.debug "Amount AA: #{fragaa.length}"
       @f_idnum+=fragaa.length
       fragab = Dapfragment.find(:all, :conditions => "f_category = 'frag_AB'")
       logger.debug "Amount AB #{fragab.length}"
       @f_idnum+=fragab.length
       fragm = Dapfragment.find(:all, :conditions => "f_category = 'frag_M'")
       logger.debug "Amount M #{fragm.length}"
       @f_idnum+=fragm.length
       logger.debug "Amount of fragments: #{@f_idnum}"
       @itemid = convertID('FRAG', @f_idnum, 0)
      # logger.debug "Converted ID: #{@itemid}"
      else
      # logger.debug "f_num: #{@f_idnum}"
       repaa = Dapfragment.find(:all, :conditions => "f_category = 'rep_AA'")
       @f_idnum+=repaa.length
       repab = Dapfragment.find(:all, :conditions => "f_category = 'rep_AB'")
       @f_idnum+=repab.length
       repm = Dapfragment.find(:all, :conditions => "f_category = 'rep_M'")
       @f_idnum+=repm.length
      # logger.debug "Amout of repeats: #{@f_idnum}"
       @itemid = convertID('REP', @f_idnum, 0)
      end

      figure_file = @itemid + '.png'
      @figure_mysql = 'ancient_dict/images/' + figure_file
      @figure_filename = File.join(DATABASES, @figure_mysql)
      logger.debug "figure_filename #{@figure_filename}"

      ali_file = @itemid + '.ali'
      @ali_mysql = 'ancient_dict/alignments/' + ali_file
      @ali_filename = File.join(DATABASES, @ali_mysql)
      logger.debug "ali_filename #{@ali_filename}"

      @fali = params['f_ali'] ? params['f_ali'] : "NULL"

      @ffigure = params['f_figure'] ? params['f_figure'] : "NULL"

      if (@ffigure != 'NULL')
        params_to_file(@figure_filename, 'f_figure')
#        logger.debug "figure_mysql: worked!"
      end

      @alignment = ''
      if (@fali != "NULL")
        params_to_file(@ali_filename, 'f_ali')
        logger.debug "ali_mysql: #{@ali_mysql}"
        @alignment=print_alignment(@ali_filename)
     end


      # #logger.debug "alignment information: #{@fali}"
      additem=Dapfragment.new(:f_id => @itemid, :f_name => @fname, :f_desc => @fdesc, :f_shortdesc => @fshortdesc, :f_category => @fcategory, :f_ref => @fref, :f_figure => @figure_mysql, :f_align => @alignment)#@ali_mysql)
      additem.save!
      logger.debug "Dapfragment added! f_id: #{@itemid}, f_name: #{@fname}, f_desc: #{@fdesc}, f_shortdesc: #{@fshortdesc}, f_category: #{@fcategory}, f_ref: #{@fref}, f_figure: #{@figure_mysql}, f_align #{@alignment}"
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
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_figure => @frag_figure, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc, :f_align => @up_alignment)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_figure: #{@frag_figure}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}, f_align: #{@up_alignment}"
        else
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_figure => @frag_figure, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_figure: #{@frag_figure}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}"
        end
      else
        if (@frag_align != 'NULL')
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc, :f_align => @up_alignment)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}, f_align: #{@up_alignment}"
        else
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_shortdesc => @frag_shortdesc, :f_desc => @frag_desc)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_shortdesc: #{@frag_shortdesc}, f_desc: #{@frag_desc}"
        end
      end

    @previous_cat = Dapfragment.find(@fid).f_category
    if (@frag_cat != 'NULL' && @previous_cat != @frag_cat)
      upcatfrag=Dapfragment.find(@fid)
      upcatfrag.update_attributes(:f_category => @frag_cat)
      upcatfrag.save!
    end

    if ( @frag_ref != 'NULL')
      logger.debug "Reference available!!!"
      Dapref.find(:all, :conditions => ["f_id=?", @frag_id]).each do |delref|
        Dapref.delete(delref.id)
      end

      @upreference.each do |refup|
        logger.debug "Reference: #{refup}"
        uprefid = generateRefID(1)
        logger.debug "Ref ID; #{uprefid}"
        upref = Dapref.new(:r_id => uprefid, :r_reference => refup, :f_id => @frag_id)
        upref.save!
       # hlogger.debug "Dapref added: r_id: #{uprefid}, r_reference:  #{refup}, f_id #{@frag_id}"
      end
    end

    if (@frag_key != 'NULL')

      DapfragmentDapkey.find(:all, :conditions => ["f_id=?", @frag_id]).each do |delkey|
        DapfragmentDapkey.delete(delkey.id)
      end

      @frag_key.each do |frag_keys|
        addfragkey=DapfragmentDapkey.new(:f_id => @frag_id, :k_id => frag_keys)
        addfragkey.save!
       # logger.debug "DapfragmentDapkey added: f_id: #{@frag_id}, k_id: #{frag_keys}"
      end
    end

    if ( @frag_occ!= 'NULL')
      Dapoccurrence.find(:all, :conditions => ["f_id=?", @frag_id]).each do |delocc|
        Dapoccurrence.delete(delocc.id)
      end

      @up_occ.each do |occup|
        occ = occup.split('\t')
        scop_id=occ[0]
        scop_desc=occ[1]
        upocc = Dapoccurrence.new(:scop_id => scop_id, :f_id => @frag_id)
        upocc.save!
        #logger.debug "Dapocc added: scop_id: #{scop_id}, f_id #{@frag_id}"
        if (!Dapscop.find(:first, :conditions => ["scop_id=?", scop_id]))
          upscop = Dapscop.new(:scop_id => scop_id, :scop_desc => scop_desc)
          upscop.save!
         # logger.debug "Dapscop added: scop_id: #{scop_id}, scop_desc #{scop_desc}"
        end
      end
    end
  end

    # delete keyword

    if (@delid != "NULL")
      Dapkey.delete(@delid)

     # logger.debug "Dapkey deleted! id: #{@delid}, k_id: #{@k_delid}"

      if (DapfragmentDapkey.find(:first, :conditions => ["k_id=?", @k_delid]))
        DapfragmentDapkey.find(:all, :conditions => ["k_id=?", @k_delid]).each do |delkey|
          DapfragmentDapkey.delete(delkey.id)
          logger.debug "DapfragmentDapkey deleted! id: #{delkey.id}, f_id: #{delkey.f_id}, k_id: #{delkey.k_id}"
        end
      end
    end

    # delete fragment

    if (@del_f_id != "NULL")

      #logger.debug "Dapfragment deleted! id: #{@del_f_id}, f_id: #{@f_delid}"

      #DapfragmentDapkey.find(:all, :conditions => ["f_id=?", @f_delid]).each do |delfrag|
      if (DapfragmentDapkey.find(:first, :conditions => ["f_id=?",@f_delid]))
      #  logger.debug "Eintrag existiert!"
        DapfragmentDapkey.find(:all, :conditions => ["f_id=?",@f_delid]).each do |delfrag|
          logger.debug "Delfrag: #{delfrag.f_id}, #{delfrag.k_id}"
          DapfragmentDapkey.delete(delfrag.id)
          logger.debug "DapfragmentDapkey deleted! id: #{delfrag.id}, f_id: #{delfrag.f_id}, k_id: #{delfrag.k_id}"
        end
      end

      #logger.debug "DapfragmentDapkey gelöscht!"

      if (Dapoccurrence.find(:first, :conditions => ["f_id=?", @f_delid]))
       # logger.debug "Eintrag vorhanden!"
        Dapoccurrence.find(:all, :conditions => ["f_id=?", @f_delid]).each do |delocc|
          Dapoccurrence.delete(delocc.id)
          logger.debug "Dapoccurrence deleted! id: #{delocc.id}, f_id: #{delocc.f_id}, scop_id: #{delocc.scop_id}"
        end
      end

      if (Dapref.find(:first, :conditions => ["f_id=?", @f_delid]))
        Dapref.find(:all, :conditions => ["f_id=?", @f_delid]).each do |delref|
          Dapref.delete(delref.id)
        #  logger.debug "Dapref deleted! id #{delref.id}, f_id: #{delref.f_id}"
        end
      end

      Dapfragment.delete(@del_f_id)

      #logger.debug "Dapfragment deleted! id: #{@del_f_id}, f_id: #{@f_delid}"

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
        logger.debug "found ID: #{finid}"
      end
    end
    return finid
  end

  def generateRefID(refnum)
    startnum = refnum
    findref = Dapref.find(:all)
    refnum+=findref.length
    @refstring=convertID('REF', refnum, startnum)
    return @refid
  end

  #Function to format the alignment file
  def print_alignment(path)
    a_line = IO.readlines(path)
    alignm = ''
    a_line.each do |aprint|
      align_line=aprint.chop+'\n'
      alignm += align_line
     # logger.debug "#{align_line}"
    end
    #logger.debug "#{alignm}"
    return alignm
  end

  def read_dir_entries(fragment_id)
    filepath = File.join(IMAGES, "ancient_dict/images/")
    logger.debug "filepath: #{filepath}"
    direntry = Dir.entries(filepath)
    matches = Array.new()
    expression = fragment_id
    #logger.debug "Expression: #{expression}"
    for i in 0..direntry.length-1
      logger.debug "Entry #{i}: #{direntry[i]}"
      if(direntry[i].match(expression))
        logger.debug "Matching entry: #{direntry[i]}"
        matches.push(direntry[i])
      end
    end
    return matches
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




