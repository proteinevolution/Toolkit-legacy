require 'active_record'

module Toolkit
  module Validations
    module ValidatesFasta

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        
        def validates_fasta (*attr_names)
          configuration = { :max_seqs => 10000,
            :min_seqs => 1,
            :max_length => 20000,
            :white_list => "ABUCZDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwyzxbuX-",
            :informat_field => nil,
            :informat => nil,
            :inputmode => "sequence",
            :on => :create,
            :message => "Infile is not correct FASTA format!" }

          if attr_names.last.is_a?(Hash)
            configuration.update(attr_names.pop) 
          end
          
          validates_each(attr_names, configuration) do | record, attr, value |
            
            format = "fas"
            # check informat
            if (!configuration[:informat_field].nil?)
              #logger.debug "##### informat field not empty!"
              informat = record.send(configuration[:informat_field])
              if (!informat.nil? && informat != "fas")
                if (informat == "gfas")
                  format = "gfas"
                else
                  #logger.debug "##### informat field not fas! Exit Validator!"
                  next
                end
              end
              if (informat.nil? && !configuration[:informat].nil? && configuration[:informat] != "fas")
                if (configuration[:informat] == "gfas")
                  format = "gfas"
                else
                  #logger.debug "##### params[informat] nil and informat not fas! Exit Validator!"
                  next
                end
              end
            else
              if (!configuration[:informat].nil? && configuration[:informat] != "fas")
                if (configuration[:informat] == "gfas")
                  format = "gfas"
                else
                  #logger.debug "##### informat_field empty and informat not fas! Exit Validator!"
                  next
                end
              end
            end
            

            # get inputmode
            inputmode = configuration[:inputmode].nil? ? "sequence" : configuration[:inputmode]
            if (record.respond_to?(inputmode))
              inputmode = record.send(inputmode)
            end
            if (inputmode == "sequence")
              configuration[:max_seqs] = 1
            elsif( (inputmode!="sequence") && (configuration[:max_seqs]==1) )
              configuration[:max_seqs]=5000
            end
            
            # Upload file or input field?
            if (value.nil?) then next end
            if (attr.to_s.include?('_file'))
              if value.instance_of?(ActionController::UploadedStringIO) || value.instance_of?(Tempfile) || value.instance_of?(ActionController::UploadedTempfile)
                value.rewind
                value = value.read
              else
                value = IO.readlines(value).join
              end
            end
            if (value.nil? || (value.strip).empty?)
              next
            end
            
            # check, if an error at this field exists
            if (!record.errors.on(attr).nil?)
              next
            end
            
            # start validation						
            error = nil
            length = nil
            newseq = ""
            value.gsub!(/\r/, '')
            value.gsub!(/\xd\xa/, '\n')
            value.gsub!(/\xd/, '\n')
            value.gsub!(/\x1/, ' ')
            if (value !~ /^>/) then value = ">" + Time.now.to_s.gsub!(/ /, '_') + "\n" + value end
            
            val_array = "\n#{value}".split(/\n>/)
            val_array.shift
            if (val_array.length > configuration[:max_seqs])
              error = "Input contains more than #{configuration[:max_seqs]} sequences!"
            elsif (val_array.length < configuration[:min_seqs])							
              error = "Input contains less than #{configuration[:min_seqs]} sequences!"
            else
              lc = 0
              val_array.each do |val|
                lines = val.split(/\n/)
                header = lines.shift # header
                if( header =~ /^\s*$/ ) then 
                  lc = lc + 1
                  header = Time.now.to_s.gsub!(/ /, '_') + " #" + lc.to_s + "\n" 
                end
                # check for numbers at begin and/or end of line (GenBank)
                seq = ""								
                lines.each do |line|
                  if (line =~ /^\s*\d*(.*?)\d*\s*$/)
                    seq += $1
                  else
                    seq += line
                  end
                end
                # seq = lines.join()
                
                grouped_check = false								
                seq.gsub!(/ /, '')
                seq.tr!('_~.*', '-')
                
					 # for singe sequence
					 if (configuration[:max_seqs] == 1)
					 	seq.gsub!(/-/, '')
					 end          
                
                # for grouped fasta
                if (format == "gfas")
                  change = seq.gsub!(/\#$/, '')
                  if (!change.nil?)
                    grouped_check = true
                  end
                end
                
                seq.tr!("a-z","A-Z")								
                
                changes = seq.tr!("^#{configuration[:white_list]}", "+")
                if (!changes.nil?)
                  if (error.nil?)
                    error = "#{configuration[:message]} Invalid character found in sequence(s) '#{header}'"
                  else
                    error += ", '#{header}'"
                  end
                end
                if (seq =~ /^\s*$/)
                  error = "Sequence #{header} contains no characters!"
                  break
                end
                if (inputmode == "alignment")
                  if (length.nil?)
                    length = seq.length
                  else
                    if (length != seq.length)
                      error = "All sequences must have the same length!"
                      break
                    end
                  end
                end
                if (seq.length > configuration[:max_length])
                  error = "The maximum sequence length is #{configuration[:max_length]}"
                  break
                end
                if (grouped_check)
                  newseq += ">#{header}\n#{seq}\n#\n"
                  grouped_check = false
                else
                  newseq += ">#{header}\n#{seq}\n"
                end
              end
            end

            if (!error.nil?)
              if (attr.to_s.include?('_file'))
                attr = attr.to_s.sub!('_file', '_input').to_sym
                record.params[attr.to_s] = value
              end
              record.errors.add(attr, error)
            else
              if (attr.to_s.include?('_file'))
                filename = File.join(record.job.job_dir, attr.to_s)
                File.open(filename, "w") do |f|
                  f.write(newseq)
                end
                record.params[attr.to_s] = filename
              else
                record.params[attr.to_s] = newseq
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Toolkit::Validations::ValidatesFasta
end
