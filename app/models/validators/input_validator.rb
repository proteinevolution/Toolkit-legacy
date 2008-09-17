# weitere parameter-felder auslesen...
#						with_value = record.send(configuration[:with])

require 'active_record'

module Toolkit
	module Validations
		module ValidatesInput

			def self.append_features(base)
				super
				base.extend(ClassMethods)
			end

			module ClassMethods
				def validates_input (*attr_names)
					configuration = { :informat_field => nil,
					                  :informat => "fas",
					                  :inputmode => nil,
					                  :max_seqs => nil,
					                  :min_seqs => 1,
					                  :max_length => 20000,
					                  :allow_nil => false,
					                  :on => :create,
					                  :message => "Input ERROR!" }
					configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

					# check input fields
					if (attr_names[1].nil?)
						validates_input_fields(attr_names[0], {:allow_nil => configuration[:allow_nil]})
					else
						if (attr_names[0].to_s =~ /_file$/ && attr_names[1].to_s =~ /_input$/)
							validates_input_fields(attr_names[1], {:on => :create, :input_file => attr_names[0], :allow_nil => configuration[:allow_nil]})
						elsif (attr_names[0].to_s =~ /_input$/ && attr_names[1].to_s =~ /_file$/)
							validates_input_fields(attr_names[0], {:on => :create, :input_file => attr_names[1], :allow_nil => configuration[:allow_nil]})
						end
					end
					
					# run format validators
					if (!configuration[:informat_field].nil?)
						if configuration[:max_seqs].nil?
							validates_fasta(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
							validates_clustal(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
							validates_stockholm(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
							validates_embl(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})														
							validates_a2m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
							validates_a3m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})														
							validates_mega(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})														
							validates_msf(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})														
							validates_pir(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})														
							validates_tre(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})														
						else
							validates_fasta(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_clustal(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_stockholm(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_embl(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_a2m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_a3m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_mega(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_msf(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_pir(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
							validates_tre(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :max_seqs => configuration[:max_seqs], :informat => configuration[:informat], :informat_field => configuration[:informat_field], :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})						
						end
					else
						case configuration[:informat]
							when "fas"
								logger.debug "##### FASTA!"
								if configuration[:max_seqs].nil?
									validates_fasta(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_fasta(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "nucfas"
								logger.debug "##### Nucleotide FASTA!"
								if configuration[:max_seqs].nil?
									validates_fasta(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :white_list => "ATGCIUXRYWNatgciurnyw-", :message => "Infile is not correct Nucleotide-FASTA format!", :max_length => configuration[:max_length]})
								else
									validates_fasta(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :white_list => "ATGCIUXRYWNatgciurnyw-", :message => "Infile is not correct Nucleotide-FASTA format!", :max_length => configuration[:max_length]})						
								end
							when "clu"
								logger.debug "##### CLUSTAL!"
								if configuration[:max_seqs].nil?
									validates_clustal(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_clustal(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "sto"
								logger.debug "##### STOCKHOLM!"
								if configuration[:max_seqs].nil?
									validates_stockholm(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_stockholm(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "embl"
								logger.debug "##### EMBL!"
								if configuration[:max_seqs].nil?
									validates_embl(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_embl(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "a2m"
								logger.debug "##### A2M!"
								if configuration[:max_seqs].nil?
									validates_a2m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_a2m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "a3m"
								logger.debug "##### A3M!"
								if configuration[:max_seqs].nil?
									validates_a3m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_a3m(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "meg"
								logger.debug "##### MEGA!"
								if configuration[:max_seqs].nil?
									validates_mega(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_mega(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "msf"
								logger.debug "##### MSF!"
								if configuration[:max_seqs].nil?
									validates_msf(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_msf(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "pir"
								logger.debug "##### PIR!"
								if configuration[:max_seqs].nil?
									validates_pir(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_pir(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							when "tre"
								logger.debug "##### TREECON!"
								if configuration[:max_seqs].nil?
									validates_tre(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_length => configuration[:max_length]})
								else
									validates_tre(attr_names, {:min_seqs => configuration[:min_seqs], :on => :create, :inputmode => configuration[:inputmode], :max_seqs => configuration[:max_seqs], :max_length => configuration[:max_length]})						
								end
							else
								logger.debug "##### Wrong format!"
							end
					end
											
				end
			end
		end
	end
end

ActiveRecord::Base.class_eval do
	include Toolkit::Validations::ValidatesInput
end
