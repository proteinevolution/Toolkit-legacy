require 'active_record'

module Toolkit
  module Validations
    module ValidatesBlastid

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        def validates_blastid (*attr_names)
          configuration = { :on => :create,
            :input => nil,
            :file => nil,
            :message => "Wrong ID format!" }

          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

          validates_each(attr_names, configuration) do | record, attr, value |

            file = configuration[:file] ? configuration[:file] : nil
            input = configuration[:input] ? record.send(configuration[:input]) : nil
            if (value.nil? || value.empty?)
              if (file.nil?)
                if (input.nil? || (input.strip).empty?)
                  record.errors.add('sequence_input', "You must specify an input source!")
                end
              else
                file = record.send(file)
                if (input.nil? || (input.strip).empty?)
                  if file.instance_of?(ActionController::UploadedStringIO) || file.instance_of?(Tempfile) || file.instance_of?(ActionController::UploadedTempfile)
                    file.rewind
                    file_value = file.read
                    if (file_value.nil? || (file_value.strip).empty?)
                      record.errors.add('sequence_input', "You must specify an input source!")
                    end
                  else
                    if (!file.nil? && !file.empty?)
                      file_value = IO.readlines(file).join
                      if (file_value.empty?)
                        record.errors.add('sequence_input', "You must specify an input source!")
                      end
                    else
                      record.errors.add('sequence_input', "You must specify an input source!")
                    end
                  end
                else
                  if file.instance_of?(ActionController::UploadedStringIO) || file.instance_of?(Tempfile) || file.instance_of?(ActionController::UploadedTempfile)
                    file.rewind
                    file_value = file.read
                    if (!(file_value.nil? || (file_value.strip).empty?))
                      record.errors.add('sequence_input', "Please specify only one input source!")
                    end
                  end
                end
              end
            else # value not empty	
              if (!(input.nil? || (input.strip).empty?))
                record.errors.add('sequence_input', "Please specify only one input source!")
              end
              if (!file.nil?)
                file = record.send(file)
                if file.instance_of?(ActionController::UploadedStringIO) || file.instance_of?(Tempfile) || file.instance_of?(ActionController::UploadedTempfile)
                  file.rewind
                  file_value = file.read
                  if (!(file_value.nil? || (file_value.strip).empty?))
                    record.errors.add('sequence_input', "Please specify only one input source!")
                  end
                end
              end
              
              if (value.to_s !~ /^[_0-9a-zA-z]+$/)
                record.errors.add(attr, "Job-IDs may only contain alphanumeric characters and '_'!")
              elsif (value.to_s.length < 6 || value.to_s.length > 10)
                record.errors.add(attr, "Job-IDs must have between 6 and 10 characters!")
              else
                jobs = Job.find(:all, :conditions => [ "jobid = ?", value])
                if (jobs.empty? || jobs[0].tool !~ /blast/)
                  record.errors.add(attr, "There is no BLAST job with this ID!")
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
  include Toolkit::Validations::ValidatesBlastid
end
