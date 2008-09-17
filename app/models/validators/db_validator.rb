require 'active_record'

module Toolkit
  module Validations
    module ValidatesDB

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validates_db (*attr_names)
          configuration = { :on => :create,
            :personal_dbs => nil,
            :genomes_dbs => nil,
            :message => "Database Error!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          validates_each(attr_names, configuration) do | record, attr, value |

            ret = false
            
            if (!value.nil?)
              ret = true
            else
              if (!configuration[:genomes_dbs].nil?)
                dbs = record.params[configuration[:genomes_dbs]]
                if (!dbs.nil?)
                  ret = true
                end
              end
              if (!configuration[:personal_dbs].nil?)
                dbs = record.send(configuration[:personal_dbs])
                if (!dbs.nil?)
                  ret = true
                end
              end
            end
            if (!ret)
              record.errors.add(attr, "Please select a database!")
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Toolkit::Validations::ValidatesDB
end
