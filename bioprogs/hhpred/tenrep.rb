#!/usr/bin/ruby
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class Tenrep
  def initialize
    @infile = ""
    @hh = ""
    @outfile
    @prob = 90

    @fastafile = ""
    @hhpred = ""
  end

  def run(args=[])
    options.parse!(args)

    #check if infile exists
    if File.exist?(@infile) == false then
      puts "Infile doesn't exist!"
      return
    end

    #check if HHpred-File exists
    if File.exist?(@hh) == false then
      puts "Hhpred-File doesn't exist!"
      return
    end

    @infile= readFasta()
    @hhpred = parseHHpred()

    makeOutput()
  end


  def makeOutput()
    result= @infile+"\n"+@hhpred.to_s
    f = File.open(@outfile,"w")
    f.write result
    f.close
  end


  def parseHHpred()
    file = ""
    File.open(@hh,"r") do |f|
      file = f.read
    end

    #file is split at "No (Zahl)" and saved in the array entries
    entries = file.split(/No \d+/)
    entries.shift

    #array for the different pieces, that are parsed
    #query: saves the queries
    #title: the protein's titles in PDB
    #template: the associated template
    #posq: the query's start- and endposition
    #post: the template's start- and endposition
    query = Array.new
    title = Array.new
    template = Array.new
    posq = Array.new
    post = Array.new

    #length of the query (needed for filling with gaps)
    length=0

    #searches in the entries-array to find the queries/titles/templates/positions and puts them in the
    #corresponding arrays
    entries.each do |entry|
      qu = ""
      templ = ""
      startq = nil
      endeq = 0
      startt = nil
      endet = 0
      quName = nil
      templName = nil

      content = entry.split("\n")

      content.each do |line|

        #break, if probability is too low
        if(line =~ /Probab/) then
          line =~ /Probab=\s*(\d*.\d)/
          if($1.to_i<@prob) then
            #               title.pop
            break
            #       else
            #               title[title.length-1]=title[title.length-1]+"\n"+line
          end

          #looks for the title
        elsif(line =~ />/) then
          title.push(line)

          #looks for the query and its positions
        elsif(line =~ /^Q\s\w+/) then
          unless(line=~/^Q ss_pred/ || line=~/^Q ss_dssp/ || line=~ /^Q ss_conf/ || line=~/^Q Consensus/) then

            line =~ /Q\s+(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s+\((\d+)\)/

            if (quName == nil || quName == $1) then
              quName = $1

              if(startq==nil) then
                startq = $2
              end

              if(endeq.to_i<$4.to_i) then
                endeq = $4
                length = $5
              end

              qu += $3
            end
          end
          #looks for the template and ist positions
        elsif(line =~ /^T\s\w+/)
          unless(line=~/^T ss_pred/ || line=~ /^T ss_conf/ || line=~/^T ss_dssp/ || line=~/^T Consensus/) then

            line =~ /T\s+(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s+\((\d+)\)/
#            puts "Line: #{line}"

            if (templName == nil || templName == $1) then
              templName = $1

              if(startt==nil) then
                startt = $2
              end

              if(endet.to_i<$4.to_i) then
                endet = $4
              end

              templ += $3
            end

          end

        end
      end

      templ.gsub!(/\s+/,"")
      qu.gsub!(/\s+/,"")

      #the arrays are filled
      if(qu!="") then query.push(qu) end
      if(templ!="") then template.push(templ) end

      if(startq!=nil) then posq.push(startq) end
      if(endeq!=0) then posq.push(endeq) end

      if(startt!=nil) then post.push(startt) end
      if(endet!=0) then post.push(endet) end

    end

    # puts "Template:\n"
    # puts template.join.size
    # puts "\n"
    # puts "Query:\n"
    # puts query.join.size

    #removes the gaps in the query and the associated residues in the template
    0.upto(query.length-1){ |i|
      0.upto(query[i].length-1){ |j|
        if(query[i][j..j]=="-") then
          template[i][j..j]=""
          query[i][j..j]=""
          retry
        end
      }
    }

    #inserts additional gaps
    0.upto(template.length-1){ |i|
      st = posq[i*2]
      e = posq[i*2+1]
      (st.to_i-1).times { template[i].insert(0,'-')}
      (length.to_i-e.to_i).times  { template[i].insert(-1,'-')}
    }


    #inserts titles and newlines every 100 characters
    template.each do |templ|
      0.upto(templ.length/100){ |i|
        templ.insert(i*101,"\n")
      }
      templ.insert(0,"\n"+title[0])
      title.delete_at(0)
    end

    return template

  end


  def readFasta()
    fastafile = ""
    File.open(@infile,"r") do |f|
      fastafile = f.read
    end

    #removes paragraphs about secundary structure
    fastafile.sub!(/>ss_pred[^>]*/,"")
    fastafile.sub!(/>ss_conf[^>]*/,"")
    fastafile.sub!(/>ss_dssp[^>]*/,"")

    fastafile.gsub!(/>/,">Q_")

    return fastafile
  end



  def options
    OptionParser.new do |opts|
      opts.set_summary_indent('  ')
      opts.banner = "Usage: #{$0} [options]"
      opts.separator("Tenrep")
      opts.separator ""

      options = OpenStruct.new


      # Infile.
      opts.on("-i", "--infile [INFILE]",String,
              "Infile in FASTA format.") do |inf|
        options.infile = inf
        @infile = inf
      end

      # Hhpred-File
      opts.on("-hh", "--hh_in",String,
              "Hhpred-File with the templates") do |hh|
        options.hh_in = hh
        @hh = hh
      end

      # Outfile.
      opts.on("-o","--outfile [OUTFILE]", String,"Path for the outfile.") do |out|
        options.outfile = out
        @outfile = out
      end

      # Probability.
      opts.on("-p", "--prob [PROBABILITY]", Integer,
              "Probability cutoff. Default = 90") do |pr|
        options.prob = pr
        @prob = pr
      end

      # Help
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end


    end

  end

  h = Tenrep.new
  h.run(ARGV)

end
