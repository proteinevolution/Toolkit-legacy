# \chris
require 'active_record'

module Toolkit
  module Validations
    module ValidatesShellParams

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        # *attr_names contains attribute accessors
        # which  are getters and setters for instancevariables
        def validates_shell_params (*attr_names)


          configuration = {
            :on => :create,
            :allow_nil => true,
            :message => "Forbidden character found!"
          }
          # if the last arguments in *attr_names can be interpreted as a hash
          # pop this hash and merge it with the 'configuration' hash
          # that means replace existing values with those of
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
          validates_each(attr_names, configuration) do | record, attr, value |

            if (value.nil? && configuration[:allow_nil] == false)
              record.errors.add(attr, 'These field is mandatory!')
            else
              if (!value.nil? && value.to_s !~ /^([A-Za-z0-9_+=@\. -]*)$/)
                record.errors.add(attr, 'Please remove special characters and newlines in input!')
              end
            end

          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Toolkit::Validations::ValidatesShellParams
end
