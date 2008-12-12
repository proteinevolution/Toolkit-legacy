require 'active_record'

module Toolkit
  module Validations
    module ValidatesModellerOption
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def validates_modeller_option(*attr_names)
          configuration = {:on => :create,
            :message => "Option Failure"}
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          logger.debug "#### ModellerOption Validation!"

          state = "" #check variable
          validates_each(attr_names, configuration) do | record, attr, value |
           # Upload file or input field?                                                                                                                                                            

            if (value.nil?) 
              state = state+"0"
              if state.length == 2
                if state.eql?("10")
                  error = "You must specify a pdb file!"
                elsif state.eql?("01")
                  error = "You must specify an identifier!"
                end
                if !(error.nil?)
                  record.errors.add(attr, error)
                end
              end
              next 
            end
            state = state+"1"
            if (attr.to_s.include?('_file'))
              if value.instance_of?(ActionController::UploadedStringIO) || value.instance_of?(Tempfile) || value.instance_of?(ActionController::UploadedTempfile)
                value.rewind
                value = value.read
              else
                value = IO.readlines(value).join

              end
            end
            if (value.nil? || (value.strip).empty?)
              next
            end


            if (!record.errors.on(attr).nil?)
              next
            end
            #Validation
            if state.length == 2
              if state.eql?("10")
                error = "You must specify a pdb file!"
              elsif state.eql?("01")
                error = "You must specify an identifier!"
              end
             if !(error.nil?)
               record.errors.add(attr, error)
             end
            end
          end #each
        end
      end
    end
  end
end
  ActiveRecord::Base.class_eval do
    include Toolkit::Validations::ValidatesModellerOption
end
  
