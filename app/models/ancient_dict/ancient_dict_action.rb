class AncientDictAction < Action

#  require 'activerecord'

  DAP = File.join(BIOPROGS, 'DAP')

  attr_accessor :k_name, :k_desc, :k_upname, :k_updesc
  attr_accessor :f_name, :f_desc, :f_shortdesc, :f_cat, :f_ref, :f_figure

  # Put action initialisation code in here
  def before_perform

    figure_directory = File.join(IMAGES, 'ancient_dict')
  #set the variables that help to find out which function should be executed:
  #add an item, add a keyword, add a scop entry
  #update an item, update a keyword, update a scop entry
  #delete an item, delete a keyword, delete a scop entry

    # for the case of adding a keyword, an item or a scop entry
    @kname = params['k_name'] ? params['k_name'] : "NULL"
    @fname = params['f_name'] ? params['f_name'] : "NULL"
    @scopid =params['scop_id'] ? params['scop_id'] : "NULL"

    # for the case of updating a keyword, an item or a scop entry
    @kupname = params['k_upname'] ? params['k_upname'] : "NULL"
    @frag_name = params['f_upname'] ? params['f_upname'] : "NULL"
    @up_scopid = params['scop_upid'] ? params['scop_upid'] : "NULL"


  #input add keyword
    if (@kname != "NULL")
      @kdesc = params['k_desc'] ? params['k_desc'] : "NULL"
      #logger.debug "k_name: #{@kname}"
      #logger.debug "k_desc: #{@kdesc}"
    end

    # input add item (fragment or repeat)
    #figure_directory = File.join(IMAGES, 'ancient_dict')

    if (@fname != "NULL")
      @fitem = params['fitem'] ? params['fitem'] : "NULL"
      @fdesc = params['f_desc'] ? params['f_desc'] : "NULL"
      @fshortdesc = params['f_shortdesc'] ? params['f_shortdesc'] : "NULL"
      @fcategory = params['f_cat'] ? params['f_cat'] : "NULL"
      @fref = params['f_ref'] ? params['f_ref'] : "NULL"
      @fkeywords = params['f_keys'] ? params['f_keys'] : "NULL"
      @fscop = params['f_occ'] ? params['f_occ'] : "NULL"

      #logger.debug "f_name: #{@fname}"
      #@fkeywords.each do |ks|
       # logger.debug "f_key: #{ks}"
      #end

      @occ = @fscop.split('\n')

      @occ.each do |oc|
       # logger.debug "occ_line: #{oc}"
        occ = oc.split('\t') #occ_name: occ[0]; occ_desc: occ[1]
       # logger.debug "occ_name: #{occ[0]}"
       # logger.debug "occ_desc: #{occ[1]}"
      end

      @reference = @fref.split('\n')

      #@reference.each do |refs|
        #logger.debug "refs: #{refs}"
     # end

      @itemid = ''
    end

    # input add scop entry
    if (@scopid != "NULL")
      @scopdesc = params['scop_desc'] ? params['scop_desc'] : "NULL"
      #logger.debug "scopid: #{@scopid}"
      #logger.debug "scopdesc: #{@scopdesc}"
    end

   # input update keyword

    if (@kupname != "NULL")
      @kdesc = params['k_updesc'] ? params['k_updesc'] : "NULL"
      @kid = params['k_upid'] ? params['k_upid'] : "NULL"
      @id = params['upid'] ? params['upid'] : "NULL"

      #logger.debug "Update key_name: #{@kupname}"

    end


    # input update fragment (fragment/repeat)

    if (@frag_name != "NULL")

      @fid = params['upfrid'] ? params['upfrid'] : "NULL"
      @frag_id = params['f_upid'] ? params['f_upid'] : "NULL"
      @fdesc = params['f_updesc'] ? params['f_updesc'] : "NULL"
      @fshortdesc = params['f_upshortdesc'] ? params['f_upshortdesc'] : "NULL"
      @fscop = params['f_upocc'] ? params['f_upocc'] : "NULL"
      @fref = params['f_upref'] ? params['f_upref'] : "NULL"
      @fkeywords = params['f_upkeys'] ? params['f_upkeys'] : "NULL"
      @frag_fig = params['f_upfigure'] ? params['f_upfigure'] : "NULL"
      @frag_align = params['f_upali'] ? params['f_upali'] : "NULL"
      @fcategory = params['f_upcat'] ? params['f_upcat'] : "NULL"

      logger.debug "f_desc: #{@fdesc}"
      logger.debug ""

      if (@frag_fig != 'NULL')
        @figures = read_dir_entries(@frag_id)
        @len = @figures.length
        if (@len == 1)
          @frag_figure = 'ancient_dict/images/' + @frag_id + '_up.png'
        else
          @frag_figure = 'ancient_dict/images/' + @frag_id + '_up'+@figures.length.to_s()+'.png'
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
        @up_alignment=print_alignment(@frag_align)
      end

      @occ = @fscop.split('\n')

      @reference = @fref.split('\n')

      logger.debug "Update reference: #{@fref}"
      logger.debug "Update figure: #{@frag_figure}"
      logger.debug "Update alignment: #{@frag_align}"

    end

    # input update scop entry

    if (@up_scopid != "NULL")
      @sc_id = params['scupid'] ? params['scupid'] : "NULL"
      @scopdesc = params['scop_updesc'] ? params['scop_updesc'] : "NULL"
    end

    # input delete keyword

    @delid = params['delid'] ? params['delid'] : "NULL"
    @k_delid = params['k_delid'] ? params['k_delid'] : "NULL"

   # logger.debug "Delete ID: #{@delid}"
   # logger.debug "Delete K_id: #{@k_delid}"

    # input delete item (fragment/repeat)

    @del_f_id = params['del_f_id'] ? params['del_f_id'] : "NULL"
    @f_delid = params['f_delid'] ? params['f_delid'] : "NULL"

   # logger.debug "Delete ID: #{@del_f_id}"
   # logger.debug "Delete F_id: #{@f_delid}"

    # input delete scop entry
    @del_s_id = params['delsid'] ? params['delsid'] : "NULL"
    @del_scopid = params['s_delsid'] ? params['s_delsid'] : "NULL"

    #logger.debug "Delete ID (scop): #{@del_s_id}"
    #logger.debug "Delete Scop_ID: #{@del_scopid}"

  end



  # Put action code in here
  def perform

    # add new keyword

    if (@kname != 'NULL')
      @k_idnum=1
      @keys=Dapkey.find(:all)
      if @keys
        @k_idnum+=@keys.length
        logger.debug "@k_idnum #{@k_idnum}"
      end
      @startid = 0
      @keyid= convertID('KEY', @k_idnum, @startid)

      logger.debug "idnum: #{@k_idnum}"
      logger.debug "keyid: #{@keyid}"

      addkey=Dapkey.new(:k_id => @keyid, :k_name => @kname, :k_desc => @kdesc)
      addkey.save!
      logger.debug "Dapkey added! k_id: #{@keyid}, k_name: #{@kname}, k_desc #{@kdesc}"
    end

    # add new fragment

    if (@fname != 'NULL')

      @f_idnum=1
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
      @fig_in_mysql = 'ancient_dict/images/' + figure_file
      @figure_filename = File.join(DATABASES, @fig_in_mysql)
      logger.debug "figure_filename #{@figure_filename}"

      ali_file = @itemid + '.ali'
      @ali_in_mysql = 'ancient_dict/alignments/' + ali_file
      @ali_filename = File.join(DATABASES, @ali_in_mysql)
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
        logger.debug "ali_mysql: #{@ali_in_mysql}"
        @alignment=print_alignment(@ali_filename)
     end


      # #logger.debug "alignment information: #{@fali}"
      additem=Dapfragment.new(:f_id => @itemid, :f_name => @fname, :f_desc => @fdesc, :f_shortdesc => @fshortdesc, :f_category => @fcategory, :f_ref => @fref, :f_figure => @fig_in_mysql, :f_align => @alignment)#@ali_mysql)
      additem.save!
      logger.debug "Dapfragment added! f_id: #{@itemid}, f_name: #{@fname}, f_desc: #{@fdesc}, f_shortdesc: #{@fshortdesc}, f_category: #{@fcategory}, f_ref: #{@fref}, f_figure: #{@fig_in_mysql}, f_align #{@alignment}"
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

    # add scop entry

    if (@scopid != 'NULL')
      #@s_idnum=1
      #@scops=Dapkey.find(:all)
      #if @scops
      #  @s_idnum+=@scops.length
      #  logger.debug "@k_idnum #{@s_idnum}"
      #end
      #@startid = 0
      #@keyid= convertID('KEY', @k_idnum, @startid)

      #logger.debug "idnum: #{@k_idnum}"
      #logger.debug "keyid: #{@keyid}"

      addscop=Dapscop.new(:scop_id => @scopid, :scop_desc => @scopdesc)
      addscop.save!
      logger.debug "Dapscop added! scop_id: #{@scopid}, scop_desc #{@scopdesc}"
    end

    # update keyword

    if (@kupname != 'NULL')
      upkey=Dapkey.find(@id)
      upkey.update_attributes(:k_id => @kid, :k_name => @kupname, :k_desc => @kdesc)
      upkey.save!
      logger.debug "Dapkey updated! k_id: #{@kid},  k_name: #{@kupname}, k_desc: #{@kdesc}"
    end

    # update fragment

    if (@frag_name != 'NULL')
      logger.debug "Fragment ID: #{@fid}"
      upfrag=Dapfragment.find(@fid)
      if (@frag_fig != 'NULL')
        if (@frag_align != 'NULL')
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_figure => @frag_figure, :f_shortdesc => @fshortdesc, :f_desc => @fdesc, :f_align => @up_alignment)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_figure: #{@frag_figure}, f_shortdesc: #{@fshortdesc}, f_desc: #{@fdesc}, f_align: #{@up_alignment}"
        else
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_figure => @frag_figure, :f_shortdesc => @fshortdesc, :f_desc => @fdesc)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_figure: #{@frag_figure}, f_shortdesc: #{@fshortdesc}, f_desc: #{@fdesc}"
        end
      else
        if (@frag_align != 'NULL')
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_shortdesc => @fshortdesc, :f_desc => @fdesc, :f_align => @up_alignment)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_shortdesc: #{@fshortdesc}, f_desc: #{@fdesc}, f_align: #{@up_alignment}"
        else
          upfrag.update_attributes(:f_id => @frag_id, :f_name => @frag_name, :f_shortdesc => @fshortdesc, :f_desc => @fdesc)
          upfrag.save!
          logger.debug "Dapfragment updated! f_id: #{@frag_id}, f_name: #{@frag_name}, f_shortdesc: #{@fshortdesc}, f_desc: #{@fdesc}"
        end
      end

    @previous_cat = Dapfragment.find(@fid).f_category
    if (@fcategory != 'NULL' && @previous_cat != @fcategory)
      upcatfrag=Dapfragment.find(@fid)
      upcatfrag.update_attributes(:f_category => @fcategory)
      upcatfrag.save!
    end

    logger.debug "Reference: #{@fref}"
    if ( @fref != 'NULL\n' || @ref != 'NULL')
      logger.debug "Reference available!!!"
      Dapref.find(:all, :conditions => ["f_id=?", @frag_id]).each do |delref|
        Dapref.delete(delref.id)
      end

      @reference.each do |refup|
        logger.debug "Reference: #{refup}"
        uprefid = generateRefID(1)
        logger.debug "Ref ID; #{uprefid}"
        upref = Dapref.new(:r_id => uprefid, :r_reference => refup, :f_id => @frag_id)
        upref.save!
      end
    end

    logger.debug "Keyword: #{@fkeyword}"

    if (@fkeyword != 'NULL' || @fkeyword != '')

      DapfragmentDapkey.find(:all, :conditions => ["f_id=?", @frag_id]).each do |delkey|
        DapfragmentDapkey.delete(delkey.id)
      end

      @fkeyword.each do |frag_keys|
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

    # update scop entry

    if (@up_scopid != 'NULL')
      upscop=Dapscop.find(@sc_id)
      upscop.update_attributes(:scop_id => @up_scopid, :scop_desc => @scopdesc)
      upscop.save!
      logger.debug "Dapscop updated! scop_id: #{@up_scopid}, scop_desc: #{@scopdesc}"
    end

    # delete keyword

    if (@delid != "NULL")
      Dapkey.delete(@delid)

      logger.debug "Dapkey deleted! id: #{@delid}, k_id: #{@k_delid}"

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


    # delete scop

    if (@del_s_id != "NULL")
      Dapscop.delete(@del_s_id)

      logger.debug "Dapscop deleted! id: #{@del_s_id}, scop_id: #{@del_scopid}"

      if (Dapoccurrence.find(:first, :conditions => ["scop_id=?", @del_scopid]))
        Dapoccurrence.find(:all, :conditions => ["scop_id=?", @del_scopid]).each do |delscop|
          Dapoccurrence.delete(delscop.id)
          logger.debug "Dapoccurrence deleted! id: #{delscop.id}, f_id: #{delscop.f_id}, scop_id: #{delscop.scop_id}"
        end
      end
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


end




