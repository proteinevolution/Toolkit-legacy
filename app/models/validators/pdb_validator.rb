require 'active_record'

module Toolkit
  module Validations
    module ValidatesPdb

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validates_pdb (*attr_names)
          configuration = { :on => :create,
            :include => nil,
            :alternative => nil,
            :message => "Please insert a file in PDB Format!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          logger.debug "##### PDB Validation! *****************************+++++++++++++++"

          validates_each(attr_names, configuration) do | record, attr, value |

            # Upload file or input field?

            if (value.nil?) then next end
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

            # check, if an error at this field exists
            if (!record.errors.on(attr).nil?)
              next
            end

	    ### start validation
	    num_atoms = 0
	    lines = value.split()
	    lines.each do |line|
	      if (line =~ /^ATOM/)
                logger.debug "**************************Num_Atoms: #{num_atoms}"
		num_atoms+=1
	      else
                logger.debug "**************************Num_Atoms: #{num_atoms}"
	      end
	    end
            if (num_atoms == 0)
	      error = "Input file is not in pdb format!"
            end

            if (!error.nil?)
              if (attr.to_s.include?('_file'))
                attr = attr.to_s.sub!('_file', '_input').to_sym
                record.params[attr.to_s] = value
              end
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
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Toolkit::Validations::ValidatesPdb
end
