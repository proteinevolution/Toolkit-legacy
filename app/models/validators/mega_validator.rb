require 'active_record'

module Toolkit
  module Validations
    module ValidatesMega

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        
        def validates_mega (*attr_names)
          configuration = { :max_seqs => 1,
            :min_seqs => 1,
            :max_length => 20000,					
            :white_list => "ABUCZDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwyzxbuX-",
            :informat_field => nil,
            :informat => nil,
            :inputmode => "alignment",
            :on => :create,
            :message => "Infile is not correct MEGA format!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          logger.debug "##### MEGA Validation!"

          validates_each(attr_names, configuration) do | record, attr, value |
            
            # check informat
            if (!configuration[:informat_field].nil?)
              format = record.send(configuration[:informat_field])
              if (!format.nil? && format != "meg")
                next
              end
              if (format.nil? && !configuration[:informat].nil? && configuration[:informat] != "meg")
                next
              end
            else
              if (!configuration[:informat].nil? && configuration[:informat] != "meg")
                next
              end
            end

            # get inputmode
            inputmode = configuration[:inputmode].nil? ? "alignment" : configuration[:inputmode]
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
            
            name = ""
            names = {}
            sequences = {}
            
            seqs = false
            interleave = true
            
            val_array = value.split("\n")
            if (val_array[0] !~ /^\s*\#mega.*/i) then error = "Missing keyword #MEGA in first line!" end
            if (val_array[1] !~ /^\s*TITLE.*/i) then error = "Missing keyword TITLE in second line!" end
            
            for i in 2...val_array.size
              
              val_array[i].gsub!(/\".*\"/, '')
              if (val_array[i] =~ /^\s*\#(\S+)\s+(.+)\s*$/)
                name = $1
                seq = $2
                seq.gsub!(/\s+/, '')
                seq.tr!('_~.*', '-')
                changes = seq.tr!("^#{configuration[:white_list]}", "+")
                if (!changes.nil?)
                  if (error.nil?)
                    error = "#{configuration[:message]} Invalid character found in sequence(s) '#{name}'"
                  else
                    error += ", '#{name}'"
                  end
                end
                
                seqs = true
                
                if (!names.has_key?(name))
                  names[name] = name
                  sequences[name] = seq
                else
                  if (!interleave)
                    error = "Input not in interleaved MEGA format!"
                    break
                  end
                  sequences[name] += seq
                end
                
              elsif (val_array[i] =~ /^\s*(\S+)\s*$/ && seqs)
                
                interleave = false
                seq = $1
                seq.gsub!(/\s+/, '')
                seq.tr!('_~.*', '-')
                changes = seq.tr!("^#{configuration[:white_list]}", "+")
                if (!changes.nil?)
                  if (error.nil?)
                    error = "#{configuration[:message]} Invalid character found in sequence(s) '#{name}'"
                  else
                    error += ", '#{name}'"
                  end
                end
                sequences[name] += seq
                
              end
              
            end
            
            if (names.size > configuration[:max_seqs])
              error = "Input contains more than #{configuration[:max_seqs]} sequence#{1 == configuration[:max_seqs] ? "" : "s"}!"
            elsif (error.nil? && names.size< configuration[:min_seqs])
              error = "Input contains less than #{configuration[:min_seqs]} sequence#{1 == configuration[:min_seqs] ? "" : "s"}!"
            end
            
            length = nil
            sequences.each_value do |seq|
              if (length.nil?)
                length = seq.length
              end
              if (length != seq.length)
                error = "All sequences must have the same length!"
                break
              end
              if (seq.length > configuration[:max_length])
                error = "The maximum sequence length is #{configuration[:max_length]}"
                break
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
                  f.write(value)
                end
                record.params[attr.to_s] = filename
              else
                record.params[attr.to_s] = value
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Toolkit::Validations::ValidatesMega
end
