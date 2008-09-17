require 'active_record'

module Toolkit
  module Validations
    module ValidatesCheckboxes

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validates_checkboxes (*attr_names)
          configuration = { :on => :create,
            :include => nil,
            :alternative => nil,
            :message => "Please select at least one checkbox!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          validates_each(attr_names, configuration) do | record, attr, value |

            if (value.nil? || value.empty?)
              if (configuration[:alternative].nil? || 
                  (record.respond_to?(configuration[:alternative]) && record.send(configuration[:alternative]).nil?))
                if (configuration[:include].nil?)
                  record.errors.add(attr, configuration[:message])
                else
                  if (record.params[configuration[:include]].nil? || record.params[configuration[:include]] != "byevalue")
                    record.errors.add(attr, configuration[:message])	
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
  include Toolkit::Validations::ValidatesCheckboxes
end
