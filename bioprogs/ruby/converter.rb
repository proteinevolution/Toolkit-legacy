#!usr/bin/ruby

class Converter
  @databases = "/cluster/databases/standard/"
  @formats = { "pdb" => "[>\s]\\d[A-Za-z0-9]{3}[A-Z]{0,1}\s+", "gi" => "gi\\s*\\|\\d+\\|" , "scop" => "[defgh](\\d[a-z0-9]{3})([a-z0-9_\\.])[a-z0-9_]", "pfam1" => "PF\\d{5}" , "pfam2"=> "pfam\\d{5}", "prodom" => "PD\\d{6}", "smart1" => "SM\\d{5}/", "smart2" => "smart\\d{5}", "cog" => "COG\\d{4}" , "kog" => "KOG\\d{4}",  "cd" => "cd\\d{5}", "panther" => "PTHR\\d{5}", "tigrfam" => "TIGR\\d{5}", "pirsg" => "PIR(SF\\d{6})", "supfam" => "SUPFAM\\d+", "cath1" => "\\d\\.\\d{2}\\.\\d{2}","cath2" => "\\d[a-z0-9]{3}_?[A-Za-z0-9]?[A-Z]\\d{2}" , "dali" => "(\\d[a-z0-9]{3})([A-Za-z0-9])?_\\d+" }

  @db = []
  db_dir = Dir.new(@databases)
  db_dir.each do |file|
    if file =~ /([\w\-_]+$)/ || file =~ /([\w\-_]+\.fasta$)/
      @db << $1
    end
  end

  # returns the format of an id
  def Converter.format(id)
    format = ""
    #pdb
    if id =~ /(#{@formats["pdb"]})/
        puts = "PDB"
      format = "pdb"
    #gi
    elsif id =~ /#{@formats["gi"]}/
        puts "GI"
      format = "gi"
    #scop
    elsif id =~ /#{@formats["scop"]}/
      format = "scop"
    #pfam
    elsif id =~/#{@formats["pfam1"]}/ || format =~/#{@formats["pfam2"]}/
      format = "pfam"
    #prodom
    elsif id =~ /#{@formats["prodom"]}/
      format = "prodom"
    #smart
    elsif id =~/#{@formats["smart1"]}/ || format =~/#{@formats["smart2"]}/
      format = "smart"
    #other cdd
    elsif id =~/#{@formats["cog"]}/ || format =~/#{@formats["kog"]}/ || format =~/#{@formats["cd"]}/
      format = "cdd"
    #panther
    elsif id =~/#{@formats["panther"]}/
      format = "panther"
    #tigrfam
    elsif id =~/#{@formats["tigrfam"]}/
      format = "tigrfam"
    #pirsf
    elsif id =~/#{@formats["pirsf"]}/
      format = "pirsf"
    #supfam
    elsif id =~ /#{@formats["supfam"]}/
      format = "supfam"
    #cath
    elsif id =~ /#{@formats["cath1"]}/ || id =~ /#{@formats["cath2"]}/
      format = "cath"
    #dali/pdb
    elsif id =~ /#{@formats["dali"]}/
      format = "dali"
    end
    return format
  end

  def Converter.found?(db,id)
    found = false
    File.open(@databases+db) { |file|
      while file.gets
        if $_ =~ /#{id}/
            found = true
          break
        end
        
      end
    }
    return found
  end

  # returns an array which contains  all the formats within database file 
  def Converter.getFormats(db)
    types = []
    dbfile = File.open(@databases+db, 'r') {|file|
      while file.gets
        line = $_
        headline = false
        @formats.each_key do |key| 
          headline = true
          if line =~ /(#{@formats[key]})/
              types << key
          end
        end
        if headline
          break
        end
      end
    }
    return types
  end
  
  # returns true, if "db" contains the id format "format"
  def Converter.foundFormat?(db , format)
    dbfile = File.open(@databases+db, 'r') {|file|
      while file.gets
        line = $_
        if line =~ /([\s>]#{@formats[format]}\s+)/
          return true
          break
        end
      end
    }
    return false
  end

  # returns the sequence that belongs to "id" in "db"
  def Converter.search(db,id)
    id.gsub!(/\|/,"\\|")
    seq = ""
    dbfile = File.open(@databases+db, 'r') {|file|
      while file.gets
        line = $_
        if line =~ /#{id}/
            found = true
          next
        elsif found && line=~/^\s*([A-Z]+)/
          seq = seq+$1
        elsif found 
          break
        end
      end
    }
    #lines = dbfile.readlines
    return seq 
  end

  # returns the id specified in "id" in the format "format" from "db"
  def Converter.getID(format,id,db)
    ident = ""
    dbfile = File.open(@databases+db, 'r'){|file|
      while file.gets
        line = $_
        if line =~ /#{id}/
            line =~ /(#{@formats[format]})/
            ident  = $1
        end
      end
    }
    return ident
  end
  
  # returns one format which both databases contain
  def Converter.sameFormat(db1_formats, db2_formats)
    format = ""
    db1_formats.each do |f1|
      db2_formats.each do |f2|
        if f1.eql?(f2)
          format = f1
          return format
        end
      end
    end
    return format
  end

  # returns true, if two databases contain at least one equal  format
  def Converter.sameFormat?(db1_formats ,db2_formats)
    db1_formats.each do |f1|
      db2_formats.each do |f2|
        if f1.eql?(f2)
          return true
        end
      end
    end
    return false
  end
  
  # returns the sequence from "db" specified by "id" if existant
  def Converter.findSequence(id,db)
    puts "start"
    found = false
    seq = ""
    if Converter.found?(db,id)
      puts "Fall1"
      seq = Converter.search(db,id)
      found = true
    elsif Converter.foundFormat?(db, Converter.format(id))
      puts Converter.getFormats(db)
      puts "Fall2"
      seq = "No sequence existant in #{db}"
    else
      db_formats = Converter.getFormats(db)
      db_formats.each {|a| puts a}
      puts "Fall3"
      @db.each do |d|
        if Converter.found?(d, id)
          d_formats = Converter.getFormats(d)
          if Converter.sameFormat?(d_formats, db_formats)
            return Converter.search(db ,Converter.getID(Converter.sameFormat(d_formats,db_formats),id,d))
          end
        end
      end 
    end
    return seq
  end

  infile  = ARGV[0]
  #aus infile ids saugen und dann in einer schleife den rest anwenden
  id = String.new(i)
  id.gsub!(/\|/, "\\|")
  db = ARGV[1]
  outfile = ARGV[2]
  
 # @db.each {|a| puts a}
  s = Converter.findSequence(id,db)
  out = File.open(outfile, 'w')
  out.write(s)
  out.close
end
