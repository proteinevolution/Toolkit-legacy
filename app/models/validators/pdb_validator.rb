require 'active_record'

module Toolkit
  module Validations
    module ValidatesPDB
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def validates_pdb (*attr_names)
          configuration = { :max_length => 50000,
            :white_list => "()=_ABUCZDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwyzxbuX.,:;1234567890- ",
            :on => :create,
            :message => "Input data is not in PDB-format!"}
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
          
          logger.debug "#### PDB Validation!"
          error = "PDB"
          
          validates_each(attr_names, configuration) do | record, attr, value |
            # Upload file or input field?
            if (value.nil?) then  next end
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
            
            
            #start validation
            error = nil
            length = nil
            
            
            #validate size of the input data      
            if value.length > configuration[:max_length]
              error = "Input shift data contains #{value.length}  more tham #{configuration[:max_length]} characters" 
            else
              lines =[]                      
              lines = value.split("\n")
              atomcounter = 0
              for i in 0..lines.size
                
                #Count ATOM lines
                if lines[i] =~ /^\s*ATOM.+/
                  atomcounter = atomcounter+1
                end
                i = i+1  
              end
              if atomcounter < 2
                error = configuration[:message]
              end
            end  
            if !(error.nil?)
              #  if (attr.to_s.include?('_file'))
              #   attr = attr.to_s.sub!('_file', '_input').to_sym
              #  record.params[attr.to_s] = value
              # end
              record.errors.add(attr, error)
            else
              if (attr.to_s.include?('_file'))
                filename = File.join(record.job.job_dir, attr.to_s)
                File.open(filename, "w") do |f|
                  f.write(value)
                end
                record.params[attr.to_s] = filename
              else
                record.params[attr.to_s] = value
              end
            end
          end          
        end #end def
      end #end module                      
    end
  end
end

ActiveRecord::Base.class_eval do
              include Toolkit::Validations::ValidatesShiftX
end
