require 'active_record'

module Toolkit
	module Validations
		module ValidatesJobid

			def self.append_features(base)
				super
				base.extend(ClassMethods)
			end

			module ClassMethods
				def validates_jobid (*attr_names)
					configuration = { :on => :create,
					                  :allow_nil => true,
					                  :message => "Wrong ID format!" }

					configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

					validates_each(attr_names, configuration) do | record, attr, value |

						if (value.nil? && configuration[:allow_nil] == false)
							record.errors.add(attr, 'Please insert a jobid!')
						else
							if (!value.nil?)
                                                          @tools = YAML.load_file(::CONFIG + "/tools.yml")
                                                          if (!@tools.nil?)
                                                            @tools.each do |tool|
                                                              if (value.to_s =~ /^#{tool['name']}$/)
                                                                record.errors.add(attr, "Job-IDs must not match with a toolname!")
                                                                break
                                                              end
                                                            end
                                                          end
                                                          if (value.to_s !~ /^[_0-9a-zA-z]+$/)
                                                            record.errors.add(attr, "Job-IDs may only contain alphanumeric characters and '_'!")
                                                          elsif (value.to_s.length < 6 || value.to_s.length > 10)
                                                            if (!(value.to_s =~ /^(.*)_\d+$/ && $1.length <= 10))
                                                              record.errors.add(attr, "Job-IDs must have between 6 and 10 characters!")
                                                            end
                                                          else
                                                            jobs = Job.find(:all, :conditions => [ "jobid = ?", value])
                                                            if (jobs.length > 1)
                                                              record.errors.add(attr, "Job-ID is already used!")
                                                            end
                                                          end
							end
						end

					end
				end
			end
		end
	end
end

ActiveRecord::Base.class_eval do
	include Toolkit::Validations::ValidatesJobid
end
