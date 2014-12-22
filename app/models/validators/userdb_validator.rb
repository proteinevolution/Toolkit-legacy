require 'active_record'

module Toolkit
	module Validations
		module ValidatesUserdb

			def self.append_features(base)
				super
				base.extend(ClassMethods)
			end

			module ClassMethods
				def validates_userdb (*attr_names)
					configuration = { :max_seqs => 100000,
					                  :white_list => "ABUCZDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwyzxbuX-",
					                  :on => :create,
					                  :message => "Infile is not correct FASTA format!" }

					configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

					validates_each(attr_names, configuration) do | record, attr, value |

                                                if value.is_a?(String) && value.empty?
                                                  record.errors.add(attr, "Please select a file.")
                                                  next
                                                end
						
						if value.eof
							next
						end
						
						header = {}
						out = Tempfile.new("dbfile")
						
						while (line = value.gets) 
							if (line =~ /^>(.*)$/)
								if header.has_key?($1)
									record.errors.add("dbfile", "Same header for multiple sequences!")
									break
								else
									header[$1] = true
								end
							else
								line.gsub!(/ /, '')
								line.gsub!(/\n/, '')
								line.gsub!(/\r/, '')
								line.tr!('_~.*', '-')
								changes = line.tr!("^#{configuration[:white_list]}", "+")
								if (!changes.nil?)
						    		record.errors.add("dbfile",  "Infile is not correct FASTA format! Invalid character found in sequence '#{header}'")
									break
								end
							end
							if (line !~ /^\s*$/)
								out.puts(line)	
							end
						end
						out.close
						
						record.setTempfile(out.path)
					end
				end
			end
		end
	end
end

ActiveRecord::Base.class_eval do
	include Toolkit::Validations::ValidatesUserdb
end
