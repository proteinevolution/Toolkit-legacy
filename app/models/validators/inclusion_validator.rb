require 'active_record'

module Toolkit
	module Validations
		module ValidatesInclusion

			def self.append_features(base)
				super
				base.extend(ClassMethods)
			end

			module ClassMethods
				def validates_float_into_list (*attr_names)
					configuration = { :in => nil,
											:on => :create,
					                  :allow_nil => true,
					                  :message => "is not included in the list!" }

					configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

					validates_each(attr_names, configuration) do | record, attr, value |

						if (value.nil? && configuration[:allow_nil] == false)
							record.errors.add(attr, 'Please insert an value')
						else
							if (value !~ /\d/)
								record.errors.add(attr, configuration[:message])
							else
								value = value.to_f
								list = configuration[:in]
								if (!list.include?(value))
									record.errors.add(attr, configuration[:message])
								end
								record.params[attr] = value
							end
						end
					end
				end
				
				def validates_int_into_list (*attr_names)
					configuration = { :in => nil,
											:on => :create,
					                  :allow_nil => true,
					                  :message => "is not included in the list!" }

					configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

					validates_each(attr_names, configuration) do | record, attr, value |

						if (value.nil? && configuration[:allow_nil] == false)
							record.errors.add(attr, 'Please insert an value')
						else
							if (value !~ /\d/)
								record.errors.add(attr, configuration[:message])
							else
								value = value.to_i
								list = configuration[:in]
								if (!list.include?(value))
									record.errors.add(attr, configuration[:message])
								end
								record.params[attr] = value
							end
						end
					end
				end
			end
		end
	end
end

ActiveRecord::Base.class_eval do
	include Toolkit::Validations::ValidatesInclusion
end
