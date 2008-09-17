require 'active_record'

module Toolkit
  module Validations
    module ValidatesInputFields
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def validates_input_fields (*attr_names)
          configuration = { :message => "Input ERROR!", :on => :create, :input_file => nil,
            :allow_nil => false }
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
          
          validates_each(attr_names, configuration) do | record, attr, value |
            file = configuration[:input_file]
            if (file.nil?)
              if ((value.nil? || (value.strip).empty?) && !configuration[:allow_nil])
                record.errors.add(attr, "You must specify an input source!")
              end
            else
              file = record.send(file)
              if (value.nil? || (value.strip).empty?)
                if file.instance_of?(ActionController::UploadedStringIO) || file.instance_of?(Tempfile) || file.instance_of?(ActionController::UploadedTempfile)
                  file.rewind
                  value = file.read
                  #logger.debug "##### File: #{file}  value: #{value}!"
                  if ((value.nil? || (value.strip).empty?) && !configuration[:allow_nil])
                    record.errors.add(attr, "You must specify an input source!")
                  end
                elsif (!file.nil? && File.exists?(file) && File.readable?(file))
                  value = IO.readlines(file).join
                  if ((value.nil? || (value.strip).empty?) && !configuration[:allow_nil])
                    record.errors.add(attr, "You must specify an input source!")
                  end
                else
                  if (!configuration[:allow_nil])
                    record.errors.add(attr, "You must specify an input source!")
                  end
                end
              else
                if file.instance_of?(ActionController::UploadedStringIO) || file.instance_of?(Tempfile) || file.instance_of?(ActionController::UploadedTempfile)
                  file.rewind
                  value = file.read
                  if (!(value.nil? || (value.strip).empty?))
                    record.errors.add(attr, "Please specify only one input source!")
                  end
                elsif (!file.nil? && File.exists?(file) && File.readable?(file))
                  value = IO.readlines(file).join
                  if (!(value.nil? || (value.strip).empty?))
                    record.errors.add(attr, "Please specify only one input source!")
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
	include Toolkit::Validations::ValidatesInputFields
end
