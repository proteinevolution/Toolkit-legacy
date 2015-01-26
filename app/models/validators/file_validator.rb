require 'active_record'

module Toolkit
  module Validations
    module ValidatesFile

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validates_file(*attr_names)
          configuration = { :on => :create,
            :personal_dbs => nil,
            :genomes_dbs => nil,
            :message => "Please select a file!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          validates_each(attr_names, configuration) do | record, attr, value |

            ret = false
            
            if (!value.nil?)
              ret = true
            end
            if (!ret)
              record.errors.add(attr, configuration[:message])
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Toolkit::Validations::ValidatesFile
end
