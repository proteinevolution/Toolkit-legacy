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
          configuration = { :on => :create ,
            :message => "Option Failure" }
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          logger.debug "#### ModellerOption Validation!"
          state = "" #check variable
          logger.debug attr_names[0].to_s
         # logger.debug  configuration[:pdb_file].to_s
          logger.debug "#####"
           logger.debug attr_names[1].to_s
          validates_each(attr_names, configuration) do | record, attr, value |
           # Upload file or input field?                                                                                                                                                            
          #  file = configuration[:pdb_file]
            logger.debug "#####"+attr.to_s
            logger.debug "€€€€€€"
            logger.debug "#####"+value.to_s
            
           # if (file.nil?)
           #   logger.debug "No file!!!"
           # end

            if (value.nil?) 
              state = state+"0"
              logger.debug "######"+state
              if state.length == 2
                if state.eql?("10")
                  error = "You must specify a pdb file!"
               # elsif state.eql?("01")
               #   error = "You must specify an identifier!"
                end
                if !(error.nil?)
                  record.errors.add(attr, error)
                end
              end
              logger.debug "next"
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
            # if state.eql?("10")
             #  error = "You must specify a pdb file!"
              if state.eql?("01")
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
  
