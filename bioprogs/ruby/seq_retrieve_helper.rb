#!usr/bin/ruby
# seq_retrieve_helper dbpath(s) id

class Seq_Retrieve_Helper

  @limit = 150
  @window = 15
  db = ARGV[0]
  id = ARGV[1]
  def Seq_Retrieve_Helper.breakline(line)
    newline = ""
    if line.length > @limit
      i = @limit
      while i < (line.length+@limit)
        j = 0
        broken = false
        while j < @window
          if line[i+j-1,1].eql?(" ")
            line = line[0,i+j-1]+"\n"+line[i+j,line.length-(i+j)]
            broken = true
            break
          end
          j = j+1
        end
        j = 0
        if !broken
          while j < @window
            if line[i-j-1,1].eql?(" ")
               line= line[0,i-j-1]+"\n"+line[i-j,line.length-(i-j)]
              break
            end
            j = j+1
          end
        end
        i = i+@limit
      end
    end
    return line
  end



  found = false
  seq = "###"
  dbfile = File.open(db, 'r') {|d|
    while d.gets
      line = $_
      if line =~/^>/ && line =~ /#{id.chomp}[\s_\|]/  #if line with matched id
        seq =  Seq_Retrieve_Helper.breakline(line)
        found = true
        next
      elsif found && !(line=~/^>/)
        seq = seq+line.chomp
      elsif found && line=~ /^>/
        break
      end
    end
  }
  puts seq
  
end
