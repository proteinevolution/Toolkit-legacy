require 'active_record'

module Toolkit
  module Validations
    module ValidatesPir

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        
        def validates_pir (*attr_names)
          configuration = { :max_seqs => 1,
            :min_seqs => 1,
            :max_length => 20000,					
            :white_list => "ABUCZDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwyzxbuX-\.",
            :informat_field => nil,
            :informat => nil,
            :inputmode => "alignment",
            :on => :create,
            :message => "Infile is not correct PIR format!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          logger.debug "##### PIR Validation!"

          validates_each(attr_names, configuration) do | record, attr, value |
            
            # check informat
            if (!configuration[:informat_field].nil?)
              format = record.send(configuration[:informat_field])
              if (!format.nil? && format != "pir")
                next
              end
              if (format.nil? && !configuration[:informat].nil? && configuration[:informat] != "pir")
                next
              end
            else
              if (!configuration[:informat].nil? && configuration[:informat] != "pir")
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
            
            names = []
            seqs = []
            counter = -1
            
            seq_end_flag = true
            
            val_array = value.split("\n")
            
            i = 0
            while (i < val_array.size)
              
              val_array[i].gsub!(/\s/, '')
              if (val_array[i] =~ /^\s*$/)
                i += 1
                next
              end
              if (val_array[i] =~ /^>.{2};(.*)$/)
                if (!seq_end_flag)
                  error = configuration[:message]
                  break
                end
                counter += 1
                names[counter] = $1
                seqs[counter] = ""
                i += 1
                if (i < val_array.size && val_array[i] =~ /^.*?:.*?:.*?:(\S+):/)
                  names[counter] += "_" + $1
                end
                if (!seq_end_flag)
                  error = configuration[:message]
                  break
                end
                seq_end_flag = false
              elsif (val_array[i] =~ /^(.*)\*\s*$/)
                if (counter < 0)
                  error = configuration[:message]
                  break
                end
                seqs[counter] += $1
                seq_end_flag = true
              else
                if (counter < 0)
                  error = configuration[:message]
                  break
                end
                seqs[counter] += val_array[i]
                seq_end_flag = false
              end
              i += 1 
            end
            
            if (!seq_end_flag)
              error = configuration[:message] + " Missing '*' (asterisk) character at the end of the sequence."
            end						
            
            if (names.size > configuration[:max_seqs])
              error = "Input contains more than #{configuration[:max_seqs]} sequence#{1 == configuration[:max_seqs] ? "" : "s"}!"
            elsif (error.nil? && names.size < configuration[:min_seqs])
              error = "Input contains less than #{configuration[:min_seqs]} sequence#{1 == configuration[:min_seqs] ? "" : "s"}!"
            end
            
            length = nil
            seqs.each do |seq|
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
  include Toolkit::Validations::ValidatesPir
end
