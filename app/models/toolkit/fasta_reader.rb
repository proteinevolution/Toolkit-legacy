class FastaReader

  def initialize(file)
    @file = File.open((file.class == File ? File.expand_path(file.path) : file), "r")
    @next_header = ""
    while @file.eof? == false
      @next_header = @file.readline.chop
      break if @next_header.length != 0 && @next_header[0] == ?>
      @next_header = ""
    end
  end 

  def eof?
    return @next_header.length == 0
  end

  def next
    header = @next_header
    @next_header = ""
    seq = ""
    while @file.eof? == false
      line = @file.readline.chop
      if line.length != 0
	if line[0] == ?>
	  @next_header = line
	  break
	else 
	  seq += line
	end
      end
    end
    @file.close if @next_header.length == 0
    if block_given?
      yield header, seq
    else
      return [header, seq]
    end
  end

  def each
    if block_given?
      while eof? == false
	self.next {|header, seq| yield header, seq}
      end
    else
      return enum_for(:each)
    end
  end

  def rewind
    initialize(@file)
  end

  def self.read(file)
    e = FastaReader.new(file).each
    if block_given?
      e.each {|header, seq| yield header, seq}
    else
      return e
    end
  end

end
