require 'active_record'

module Toolkit
  module Validations
    module ValidatesA2M

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validates_a2m (*attr_names)
          configuration = { :max_seqs => 1,
            :min_seqs => 1,
            :max_length => 20000,					
            :white_list => "ABUCZDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwyzxbuX\.-",
            :informat_field => nil,
            :informat => nil,
            :inputmode => "sequence",
            :on => :create,
            :message => "Infile is not correct A2M format!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          logger.debug "##### A2M Validation!"

          validates_each(attr_names, configuration) do | record, attr, value |
            
            # check informat
            if (!configuration[:informat_field].nil?)
              format = record.send(configuration[:informat_field])
              if (!format.nil? && format != "a2m")
                next
              end
              if (format.nil? && !configuration[:informat].nil? && configuration[:informat] != "a2m")
                next
              end
            else
              if (!configuration[:informat].nil? && configuration[:informat] != "a2m")
                next
              end
            end

            # get inputmode
            inputmode = configuration[:inputmode].nil? ? "sequence" : configuration[:inputmode]
            if (record.respond_to?(inputmode))
              inputmode = record.send(inputmode)
            end
            if (inputmode == "sequence")
              configuration[:max_seqs] = 1
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
              error = "Input contains more than #{configuration[:max_seqs]} sequence#{1 == configuration[:max_seqs] ? "" : "s"}!"
            elsif (val_array.length < configuration[:min_seqs])
              error = "Input contains less than #{configuration[:min_seqs]} sequence#{1 == configuration[:min_seqs] ? "" : "s"}!"
            else
              lc = 0
              val_array.each do |val|
                lines = val.split(/\n/)
                header = lines.shift # header
                if( header =~ /^\s*$/ ) then 
                  lc = lc + 1
                  header = Time.now.to_s.gsub!(/ /, '_') + " #" + lc.to_s + "\n" 
                end
                seq = lines.join()
                seq.gsub!(/ /, '')
                changes = seq.tr!("^#{configuration[:white_list]}", "+")
                if (!changes.nil?)
                  if (error.nil?)
                    error = "Infile is not correct A2M format! Invalid character found in sequence(s) '#{header}'"
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
                newseq += ">#{header}\n#{seq}\n"
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
  include Toolkit::Validations::ValidatesA2M
end
