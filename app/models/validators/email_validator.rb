require 'active_record'

module Toolkit
	module Validations
		module ValidatesEmail

			def self.append_features(base)
				super
				base.extend(ClassMethods)
			end

			module ClassMethods
				def validates_email (*attr_names)
					configuration = { :on => :create,
					                  :allow_nil => true,
					                  :message => "Wrong e-mail format!" }

					configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

					validates_each(attr_names, configuration) do | record, attr, value |

						if (value.nil? && configuration[:allow_nil] == false)
							record.errors.add(attr, 'Please insert an e-mail!')
						else
							if (!value.nil? && value !~ /^[-\w\.]+@[-\w\.]*[\w]+\.[A-Za-z]+$/)
								record.errors.add(attr, 'Input must be a valid e-mail!')
							end
						end
					end
				end
			end
		end
	end
end

ActiveRecord::Base.class_eval do
	include Toolkit::Validations::ValidatesEmail
end
