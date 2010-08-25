#!/usr/bin/ruby  
require File.join(File.dirname(__FILE__), '../config/environment')

#######################################################################################################################################################################
## Create an HHpred toolkit job (HH_name)
#######################################################################################################################################################################

PDB = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pdb70_*'))[0]
SCOP = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'scop70_*'))[0]
PFAM = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pfamA_*'))[0]

def create_hh_id ( name )
  id = "HH_#{name}"
  if (Job.find(:first, :conditions => [ "jobid = ?", id]))
    return 0
  else
    return id
  end
end

def create_toolkit_job( infilename )

  name = infilename.sub(/^\S+\/(\S+?)\.a3m/, '\1')
  jobid = create_hh_id(name)
  if (jobid == 0)
    STDOUT.write("\nERROR! Job with id HH_#{name} exists!\n")
    return
  end

  job = Job.new
  job.jobid = jobid
  job.tool = 'hhpred'
  job.status = 'i'
  job.type = 'HhpredJob'
  job.save_with_validation(false)
  
  parameters = {"jobid" => job.jobid, "reviewing" => 'true', "sequence_file" => "#{TMP}/#{job.id}/sequence_file", "mail_transmitted" => 'false' }
  parameters["informat"] = "a3m"
  parameters["hhpred_dbs"] = "#{PDB} #{SCOP} #{PFAM}"
  parameters["maxpsiblastit"] = 0
  parameters["alignmode"] = "local"
  parameters["ss_scoring"] = 2
  parameters["realign"] = 1
  parameters["mapt"] = "0.3"

  if !File.exist?(job.job_dir)
    Dir.mkdir(job.job_dir, 0755)
  end
  
  filename = File.join(TMP,"#{job.id}", 'sequence_file')
  system("cp #{infilename} #{filename}")
  
  newaction = HhpredAction.new( 
                               :params => parameters, 
                               :job => job, 
                               :status => 'i', 
                               :forward_controller => 'hhpred', 
                               :forward_action => 'results'
                               )
  
  newaction.sequence_file = filename
  parameters.each do |key,value|
    if (key != "controller" && key != "action" && key != "job" && key != "parent" && key != "method" && key != "forward_controller" && key != "forward_action" && newaction.respond_to?(key))
      eval "newaction."+key+" = value"
    end
  end
  newaction.jobid = job.jobid
  newaction.save_with_validation(false)
  
  newaction.run
  
  job.save!
  STDOUT.write("\nToolkit HHpred Job ID: #{job.jobid} created!\n")
end
  

#########################################################################################################################################################################################
#Main function that chooses which kind of operation particular execution requires
def main

  if ARGV[0].nil?
    STDOUT.write("\nERROR! Missing input file!\nUsage: create_HHpred_job.rb A3M-FILE\n")
    return
  end
  
  infilename = ARGV[0]
  # chec
  if !File.exist?(File.join(infilename))
    STDOUT.write("\nERROR! No inputfile #{infilename}!\n")    
    return
  end

  create_toolkit_job( infilename )

end

main

#########################################################################################################################################################################################
