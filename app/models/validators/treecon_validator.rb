require 'active_record'

module Toolkit
  module Validations
    module ValidatesTreecon
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        
        def validates_tre (*attr_names)
          configuration = { :max_seqs => 1,
            :min_seqs => 1,
            :max_length => 20000,					
            :white_list => "ABUCZDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwyzxbuX-\.",
            :informat_field => nil,
            :informat => nil,
            :inputmode => "alignment",
            :on => :create,
            :message => "Infile is not correct TREECON format!" }
          
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
          
          logger.debug "##### TREECON Validation!"
          
          validates_each(attr_names, configuration) do | record, attr, value |
            
            # check informat
            if (!configuration[:informat_field].nil?)
              format = record.send(configuration[:informat_field])
              if (!format.nil? && format != "tre")
                next
              end
              if (format.nil? && !configuration[:informat].nil? && configuration[:informat] != "tre")
                next
              end
            else
              if (!configuration[:informat].nil? && configuration[:informat] != "tre")
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
            
            seq_length = 0
            
            read_name_flag = true
            length_flag = false
            
            val_array = value.split("\n")
            
            for i in 0...val_array.size
              
              if (val_array[i] =~ /^\s*$/) then next end
              if (val_array[i] =~ /^\s*(\d+)\s*$/)
                seq_length = $1.to_i
                length_flag = true
              elsif (!length_flag)
                error = configuration[:message] + "1"
                break
              elsif (read_name_flag)
                names << val_array[i]
                seqs << ""
                read_name_flag = false
              else
                val_array[i].gsub!(/\s/, '')
                seqs[seqs.index(seqs.last)] += val_array[i]
                if (seqs.last.length == seq_length)
                  read_name_flag = true
                elsif (seqs.last.length > seq_length)
                  error = configuration[:message] + " Sequence is not as long as predicted!"
                  break
                end
              end 
            end
            
            if (!read_name_flag && error.nil?)
              error = configuration[:message] + "2"
            end						
            
            if (names.size > configuration[:max_seqs] && error.nil?)
              error = "Input contains more than #{configuration[:max_seqs]} sequences!"
            elsif (names.size < configuration[:min_seqs])
              error = "Input contains less than #{configuration[:min_seqs]} sequences!"
            end
            
            length = nil
            seqs.each do |seq|
              if (length.nil?)
                length = seq.length
              end
              if (length != seq.length && error.nil?)
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
                filename = File.join(record.job.job_dir, attr)
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
  include Toolkit::Validations::ValidatesTreecon
end
