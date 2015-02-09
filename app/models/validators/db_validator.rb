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
            :max_dbs => nil,
            :message => "Database Error!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          validates_each(attr_names, configuration) do | record, attr, value |

            db_count = 0
            proteome_count = 0
            max_dbs_p = !configuration[:max_dbs].nil?
            
            if (!value.nil?)
              db_count = value.length
            end
            if (!configuration[:genomes_dbs].nil?)
              dbs = record.params[configuration[:genomes_dbs]]
              if (!dbs.nil?)
                if (max_dbs_p)
                  proteome_count += dbs.split.length
                else
                  proteome_count += 1
                end
              end
            end
            if (!configuration[:personal_dbs].nil?)
              dbs = record.send(configuration[:personal_dbs])
              if (!dbs.nil?)
                db_count += dbs.length
              end
            end

            if (0 == (db_count + proteome_count))
              record.errors.add(attr, "Please select a database!")
            elsif (max_dbs_p and ((db_count + proteome_count) > configuration[:max_dbs]))
              if (proteome_count > 0)
                if (db_count > 0)
                  if (1 == configuration[:max_dbs])
                    # record.errors.add(attr, "You selected #{db_count} database(s) and #{proteome_count} proteome(s). Please select altogether either one database or one proteome.")
                    # Because of the placement of the error message, the error message should be very short.
                    record.errors.add(attr, "Please select only one target.")
                  else
                    # record.errors.add(attr, "You selected #{db_count} database(s) and #{proteome_count} proteome(s). Please select altogether only at most #{configuration[:max_dbs]} databases/proteomes.")
                    record.errors.add(attr, "Please select only at most #{configuration[:max_dbs]} targets.")
                  end
                elsif
                  if (1 == configuration[:max_dbs])
                    # record.errors.add(attr, "You selected #{proteome_count} proteomes. Please select only one.")
                    record.errors.add(attr, "Please select only one proteome.")
                  else
                    # record.errors.add(attr, "You selected #{proteome_count} proteomes. Please select altogether only at most #{configuration[:max_dbs]} databases/proteomes.")
                    record.errors.add(attr, "Please select only at most #{configuration[:max_dbs]} proteomes")
                  end
                end
              elsif (1 == configuration[:max_dbs])
                # record.errors.add(attr, "You selected #{db_count} databases. Please select only one database.")
                record.errors.add(attr, "Please select only one database.")
              else
                # record.errors.add(attr, "You selected #{db_count} databases. Please select only at most #{configuration[:max_dbs]} databases.")
                record.errors.add(attr, "Please select only at most #{configuration[:max_dbs]} databases.")
              end
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
