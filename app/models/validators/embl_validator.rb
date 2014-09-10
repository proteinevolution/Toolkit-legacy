require 'active_record'

module Toolkit
	module Validations
		module ValidatesEMBL

			def self.append_features(base)
				super
				base.extend(ClassMethods)
			end

			module ClassMethods
				def validates_embl (*attr_names)
					configuration = { :max_seqs => 1,
											:min_seqs => 1,
											:max_length => 20000,					
					                  :white_list => "ABUCZDEFGHIKLMNPQRSTVWYabcdefghiklmnpqrstvwyzxuX-",
					                  :informat_field => nil,
					                  :informat => nil,
					                  :inputmode => "sequence",
					                  :on => :create,
					                  :message => "Infile is not correct EMBL format!" }

					configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

					logger.debug "##### EMBL Validation!"

					validates_each(attr_names, configuration) do | record, attr, value |
					
						# check informat
						if (!configuration[:informat_field].nil?)
							format = record.send(configuration[:informat_field])
							if (!format.nil? && format != "emb")
								next
							end
							if (format.nil? && !configuration[:informat].nil? && configuration[:informat] != "emb")
								next
							end
						else
							if (!configuration[:informat].nil? && configuration[:informat] != "emb")
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
    					
						### start validation						
						error = nil
						length = nil
						seq_length = 0
						name = nil
						num_seqs = 0
						seq_flag = false
						name_flag = false
						
						value.gsub!(/\r/, '')
						value.gsub!(/\xd\xa/, '\n')
						value.gsub!(/\xd/, '\n')
						value.gsub!(/\x1/, ' ')
						
						lines = value.split(/\n/)
						lines.each do |line|
							
							if (line =~ /^ID\s+(.*)$/)
								if (name_flag)
									error = "No sequence data for '#{name}'"
									break
								else
									name = $1
									name_flag = true
									num_seqs += 1
								end
							elsif (line =~ /^SQ/)
								if (!name_flag)
									error = "Sequence without ID (identification) line!"
									break
								elsif (seq_flag)
									error = "Sequence line (SQ) without termination line (//)!"
									break
								else
									seq_flag = true
								end
							elsif (line =~ /^\/\//)
								if (!seq_flag)
									error = "Termination line (//) without sequence line (SQ) before!"						
									break
								else
									if (inputmode == "alignment")
										if (length.nil?)
											length = seq_length
										else
											if (length != seq_length)
												error = "All sequences must have the same length!"
												break
											end
										end
									end
									if (seq_length > configuration[:max_length])
										error = "The maximum sequence length is #{configuration[:max_length]}"
										break
									end
									name_flag = false
									seq_flag = false
									seq_length = 0
								end
							elsif (seq_flag)
								if
									if (line =~ /^\s+(.*?)\s*\d*\s*$/)
										seq = $1
										seq.gsub!(/ /, '')
										changes = seq.tr!("^#{configuration[:white_list]}", "+")
										if (!changes.nil?)
									  		error = "Invalid character found in sequence '#{name}'"
									  	end
										seq_length += seq.length
									end
								end
							end
							
						end # end of value.each
						
						if (name_flag)
							error = "Sequence must end with a termination line (//)!"
						end
						
						if (num_seqs > configuration[:max_seqs])
                                                        error = "Input contains more than #{configuration[:max_seqs]} sequence#{1 == configuration[:max_seqs] ? "" : "s"}!"
						elsif (error.nil? && num_seqs < configuration[:min_seqs])
                                                  error = "Input contains less than #{configuration[:min_seqs]} sequence#{1 == configuration[:min_seqs] ? "" : "s"}!"
						
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
	include Toolkit::Validations::ValidatesEMBL
end
