require 'active_record'

module Toolkit
  module Validations
    module ValidatesClustal

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validates_clustal (*attr_names)
          configuration = { :max_seqs => 1000,
            :min_seqs => 1,
            :max_length => 20000,					
            :white_list => "ABUCZDEFGHIKLMNPQRSTVWYabcdefghiklmnpqrstvwyzxuX-",
            :informat_field => nil,
            :informat => nil,
            :inputmode => "alignment",
            :on => :create,
            :message => "Infile is not correct CLUSTAL format!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          logger.debug "##### CLUSTAL Validation!"

          validates_each(attr_names, configuration) do | record, attr, value |
            
            # check informat
            if (!configuration[:informat_field].nil?)
              format = record.send(configuration[:informat_field])
              if (!format.nil? && format != "clu")
                next
              end
              if (format.nil? && !configuration[:informat].nil? && configuration[:informat] != "clu")
                next
              end
            else
              if (!configuration[:informat].nil? && configuration[:informat] != "clu")
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
            
            ### start validation						
            error = nil
            length = 0
            num_seqs = 0
            seq_length = 0
            n = 0
            names = []
            all_names = []
            flag = false
            
            value.gsub!(/\r/, '')
            value.gsub!(/\xd\xa/, '\n')
            value.gsub!(/\xd/, '\n')
            value.gsub!(/\x1/, ' ')
            

            lines = value.split(/\n/)
            lines.each do |line|
              
              if (line =~ /^\s*$/ && !flag) then next end
              if (line =~ /^\s*clustal/i)
                flag = true
              elsif (flag)
                if (line =~ /^\s*$/)
                  if (n > 0)
                    if (num_seqs > 0)
                      if (n != num_seqs)
                        error = "Infile is not correct CLUSTAL format! Number of sequences in each block must be equal."
                        break
                      end
                    else
                      num_seqs = n
                      all_names = Array.new(names)
                    end
                    n = 0
                    seq_length += length
                    length = 0
                    names.clear
                  end
                elsif (line =~ /^[:\.\*\s]*$/)
                  next
                elsif (line =~ /\s*(\S+?)\s+(\S*)\s*$/)
                  n += 1
                  name = $1
                  seq = $2
                  changes = seq.tr!("^#{configuration[:white_list]}", "+")
                  if (!changes.nil?)
                    if (error.nil?)
                      error = "Infile is not correct CLUSTAL format! Invalid character found in sequence(s) '#{name}'"
                    else
                      error += ", '#{name}'"
                    end
                  end
                  if (names.include?(name))
                    error = "Sequence #{name} appears more than once per block!"
                    break
                  else
                    names.push(name)
                  end
                  if (!all_names.empty? && !all_names.include?(name))
                    error = "Sequence #{name} does not appear in all blocks!"
                    break
                  end
                  if (length == 0)
                    length = seq.length
                  else
                    if (length != seq.length)
                      error = "All sequences in one block must have the same length!"
                      break
                    end
                  end
                else
                  error = "Infile is not correct CLUSTAL format!"
                  break
                end

              else
                error = "Infile is not correct CLUSTAL format! (The first non-empty line must begin with CLUSTAL)."
                break
              end
              
            end # end of value.each
            
            if (seq_length > configuration[:max_length])
              error = "The maximum sequence length is #{configuration[:max_length]}"
            end
            
            if (n > 0 && num_seqs > 0 && error.nil?)
              if (n != num_seqs)
                error = "Infile is not correct CLUSTAL format! Number of sequences per block is different."
              end
            end

            if (n > 0 && num_seqs == 0)
              num_seqs = n
            end
            
            if (num_seqs > configuration[:max_seqs])
              error = "Input contains more than #{configuration[:max_seqs]} sequences!"
            elsif(num_seqs < configuration[:min_seqs])
              error = "Input contains less than #{configuration[:min_seqs]} sequences!"	
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
  include Toolkit::Validations::ValidatesClustal
end
