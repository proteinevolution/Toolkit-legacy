#!/usr/bin/ruby  
require File.join(File.dirname(__FILE__), '../config/environment')

#######################################################################################################################################################################
## PDBalert script - runs weekly to find homologous sequences to user's watchlist
## Usage: (run as user toolkit)
##	For builiding HMM and perform HHsearch for one sequence(at the time of sequence upload): ./pdb_alert.rb <Watchlist ID in database> (e.g. ./pdb_alert.rb 174)
##	For performing HHsearch every week: ./pdb_alert.rb
##	For running when previous run was missed due to some reason: ./pdb_alert.rb 0 <Name of database of missed date (in /cluster/databases/pdbwatchlist/archives/ folder)> (e.g. ./pdb_alert.rb 0 pdb70_19Jul08)
#######################################################################################################################################################################

RSUB_PATH = TOOLKIT_ROOT+"/script/rsub"
RSUB_OPTS = "--logfile #{TMP}/rsub/pdb_alert.log --jobspath #{TMP}/rsub -a '-o #{TMP}/rsub -wd #{TMP}/rsub'"
PDB_ALERT_TMP = TMP+"/pdbalert"
HHPRED = BIOPROGS+"/hhpred"
CAL_DATABASE = DATABASES+"/hhpred/cal.hhm"
PDB_WATCHLIST = DATABASES+"/pdbwatchlist"
NEW_ON_HOLD_SEQUENCE_DATABASE = PDB_WATCHLIST+"/pdb_on_hold_new.hhm"
ALL_PDB = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pdb70_*'))[0]
ALL_PDB_ON_HOLD = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pdb_on_hold_*'))[0]
ALL_PDB_DATABASES = ALL_PDB + '/db/pdb.hhm'
ALL_PDB_ON_HOLD_DATABASES = ALL_PDB_ON_HOLD + '/db/pdb.hhm'
NEW_PDB_DATABASES = PDB_WATCHLIST+"/pdb_new.hhm"
if !ARGV[1].nil?
  ARCHIVE_DATABASES = File.join(PDB_WATCHLIST, "archives", "#{ARGV[1]}.hhm")
end

MAX_DAYS_TO_CHECK_RESULT = 90
MAX_DAYS_INACTIVITY = 365 
MAX_DAYS_AFTER_WARNING = 90

#######################################################################################################################################################################
# Checking for the presence of HMMs and creating for new ones

def create_hmm ( subdir,file,params )
  if !File.exist?(File.join(PDB_ALERT_TMP,'hhm'))
    Dir.mkdir(File.join(PDB_ALERT_TMP,'hhm'))
  end

  infile   = File.join(PDB_WATCHLIST,subdir,file)
  a3m_file = File.join(PDB_WATCHLIST,subdir,file.gsub(/\.fas/,'.a3m'))
  hhm_file = File.join(PDB_ALERT_TMP,'hhm',"#{subdir}:,#{file.gsub(/\.fas/,'.hhm')}")
  if !File.exists?(hhm_file)
    STDOUT.write("\n#{Time.now} - Building Alignment for #{file}.......\n")
    system("#{QUEUE_SETTINGS}; #{RSUB_PATH} #{RSUB_OPTS} --interval 60 -c \"export TK_ROOT=#{TOOLKIT_ROOT}; #{HHPRED}/buildali.pl -nodssp -cpu 4 -v 1 -n #{params['maxpsiblastit']} -diff 1000 -e #{params['Epsiblastval']} -cov #{params['cov_min']} -fas #{infile}\"")
    STDOUT.write("\n#{Time.now} - Creating HHM for #{file}..........\n")
    system("#{QUEUE_SETTINGS}; #{RSUB_PATH} #{RSUB_OPTS} --interval 60 -c \"export TK_ROOT=#{TOOLKIT_ROOT}; #{HHPRED}/hhmake -v 1 -cov #{params['cov_min']} -qid #{params['qid_min']} -diff 100 -i #{a3m_file} -o #{hhm_file}\"")
    system("rm #{a3m_file}")
  end
  hhm_file
end

#######################################################################################################################################################################
#Performing HHsearch

def perform_hhsearch ( hmm_file=nil )
  if !File.exist?(File.join(PDB_ALERT_TMP,'hhr'))
    Dir.mkdir(File.join(PDB_ALERT_TMP,'hhr'))
  end
 
  @hmm_files = Array.new
  if hmm_file.nil?
    Dir.foreach(File.join(PDB_ALERT_TMP,'hhm')) do |file|
      if file =~ /\.hhm$/ 
        @hmm_files.push(file)
      end
    end
    if(ARGV[0].nil?)
      pdb_database = NEW_PDB_DATABASES
    else
      pdb_database = ARCHIVE_DATABASES
    end
  else
    @hmm_files.push(hmm_file)
    pdb_database = ALL_PDB_DATABASES
  end

  if !@hmm_files[0].nil?
    @hmm_files.each do |file|
      hhm_file = File.join(PDB_ALERT_TMP,'hhm',file)
      out_file = File.join(PDB_ALERT_TMP,'hhr',file.gsub(/\.hhm/,'.hhr'))
      path = File.join(PDB_WATCHLIST,file.gsub(/\.hhm/,'.fas').gsub(/:,/,'/'))
      userdb = Watchlist.find( :first, :conditions =>  [ "path = ?", path ])
							  
      if userdb.nil?
        system("rm #{path}")
        system("rm #{hhm_file}")
      else
        params = userdb.params
        @mapt = ''
        @realign = params["realign"] ? "-realign" : "-norealign"
        if @realign == '-realign'
          if @ali_mode == 'global'
            @mapt = '-mapt 0.0'
          else
            @mapt = params["mapt"].nil? ? '' : '-mapt '+params["mapt"]
          end
        end
#        STDOUT.write("\n#{Time.now} - Calibrating #{hhm_file}......\n")
#        system("#{QUEUE_SETTINGS}; #{RSUB_PATH} #{RSUB_OPTS} --interval 60 -c \"export TK_ROOT=#{TOOLKIT_ROOT}; #{HHPRED}/hhsearch -cpu 4 -v 1 -i #{hhm_file} -d #{CAL_DATABASE} -cal -#{params['alignmode']} -ssm #{params['ss_scoring']} -sc #{params['compbiascorr']} -norealign 1\"")
        STDOUT.write("\n#{Time.now} - Performing HHsearch for #{hhm_file}......\n")
        system("#{QUEUE_SETTINGS}; #{RSUB_PATH} #{RSUB_OPTS} --interval 60 -c \"export TK_ROOT=#{TOOLKIT_ROOT}; #{HHPRED}/hhsearch -cpu 4 -v 1 -i #{hhm_file} -d #{pdb_database} -o #{out_file} -p #{params['Pmin']} -P #{params['Pmin']} -Z #{params['maxlines']} -B #{params['maxlines']} -seq #{params['maxseq']} -aliw #{params['width']} -#{params['alignmode']} -ssm #{params['ss_scoring']} #{@realign} #{@mapt} -sc #{params['compbiascorr']} \"")
#        system("rm #{PDB_ALERT_TMP}/hhm/#{file.gsub(/\.hhm/,'.hhr')}")
      end
    end
  end
end

#######################################################################################################################################################################
#Analysis results for significant hits and extract required parts (such as alignment)
def analyse_result  
  if !File.exist?(File.join(PDB_ALERT_TMP,'alignment'))
    Dir.mkdir(File.join(PDB_ALERT_TMP,'alignment'))
  end
	
  @matches = []
  @results = []
  @alignments = []
  Dir.foreach(File.join(PDB_ALERT_TMP,'hhr')) do |file|
    unless ( file =~ /\.$/ )
      path = File.join(PDB_WATCHLIST,file.gsub(/\.hhr/,'.fas').gsub(/:,/,'/'))
      userdb = Watchlist.find( :first, :conditions =>  [ "path = ?", path ])
      if userdb.nil?
        system("rm #{path}")
        system("rm #{PDB_ALERT_TMP}/hhm/#{file.gsub(/\.hhr/,'.hhm')}")
        system("rm #{PDB_ALERT_TMP}/hhr/#{file}")
      elsif ( ARGV[0].nil? || ( !ARGV[0].nil? && ( ARGV[0].to_i == userdb.id || ARGV[0].to_i == 0 ) ) )
        present_prob = userdb.probability
	if !userdb.params['Emax'].nil?
	  present_Emax = userdb.params['Emax'].to_f
	else
	  present_Emax = 1
	end
	if !userdb.params['Imin'].nil?
          present_Imin = userdb.params['Imin'].to_f
	else
	  present_Imin = 20
        end
			  
        hhr = File.new(File.join(PDB_ALERT_TMP,'hhr',file))
        @lines = hhr.readlines
        @line = @lines[9]
        prob = @line[35..39].to_f
	emax = @line[44..47].to_f
	cut = 0
	@lines.each_index do |i|
	  if @lines[i]=~/^No 1\s*$/
	    cut = i
	  end
	end
	@name = @lines[cut+1].gsub(/>/,'')
	imin = @lines[cut+2].gsub(/^.*Identities=(.*)\%.*$/,'\1').to_f
        if(prob > present_prob + 0.1 && emax < present_Emax - 0.01 && imin > present_Imin + 0.1)
          @matches.push(file)
          userdb.params['match_name'] = @name
	  userdb.save!
	  @results.push(userdb)
  	  STDOUT.write("\n#{Time.now} - Match found for #{file}\n")

	  STDOUT.write("\n#{Time.now} - Creating Multiple alignment for #{file} with best hit\n")
	  hhr_file = Regexp.escape(File.join(PDB_ALERT_TMP,'hhr',file))
	  alignment_file = File.join(PDB_ALERT_TMP,'alignment',file.gsub(/\.hhr/,'.pir'))
	  system("#{HHPRED}/hhmakemodel.pl -i #{hhr_file} -pir #{alignment_file} -m 1")

	end
      end
    end
  end

  @matches + @results
end

#######################################################################################################################################################################
#Creating actual Toolkit HHpred Job

def create_toolkit_job ( matches, hhpred_db=ALL_PDB )
  matches.each do |file| 
    infilename = File.join(PDB_WATCHLIST,file.gsub(/\.hhr/,'.fas').gsub(/:,/,'/'))
    infile = File.new(infilename)
    job = Job.new
    job.jobid = job.class.create_id
    job.tool = 'hhpred'
    job.status = 'i'
    job.type = 'HhpredJob'
    job.save!
    
    userdb = Watchlist.find( :first, :conditions =>  [ "path = ?", infilename ])
    parameters = {"jobid" => job.jobid, "reviewing" => 'true', "sequence_file" => "#{TMP}/#{job.id}/sequence_file", "mail_transmitted" => 'false' }
    parameters.merge!(userdb.params)
    parameters["informat"] = "fas"
    parameters["hhpred_dbs"] = "#{hhpred_db}"
  
    if !File.exist?(job.job_dir)
      Dir.mkdir(job.job_dir, 0755)
    end
  
    filename = File.join(TMP,"#{job.id}", 'sequence_file')
    File.open(filename, "w") do |f|
      f.write(infile.read)
    end
    
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
    newaction.save!
  
    newaction.run
  
    userdb.job_id = job.jobid
    userdb.save!
#    job.user_id = userdb.user_id
    job.save!
    STDOUT.write("\n#{Time.now} - Toolkit HHpred Job ID: #{job.jobid} created for #{userdb.name}\n")
  
  end
end
 
#######################################################################################################################################################################
#Creating Toolkit Modeller Job for protein structure

def create_toolkit_str_job ( alignments )
  alignments.each do |file|
    infilename = File.join(PDB_ALERT_TMP,'alignment',file.gsub(/\.hhr/,'.pir'))
    infile = File.new(infilename)
    job = Job.new
    job.jobid = job.class.create_id
    job.tool = 'modeller'
    job.status = 'i'
    job.type = 'ModellerJob'
    job.save!

    userdb = Watchlist.find( :first, :conditions =>  [ "path = ?", File.join(PDB_WATCHLIST,file.gsub(/\.hhr/,'.fas').gsub(/:,/,'/')) ])
    parameters = {  "jobid" => job.jobid, 
    		    "reviewing" => 'true', 
		    "mail_transmitted" => 'false',
		    "informat" => 'pir',
		    "modeller_key" => "MODELIRANJE"
    		 }

    if !File.exist?(job.job_dir)
      Dir.mkdir(job.job_dir, 0755)
    end

    filename = File.join(TMP,"#{job.id}", 'sequence_file')
    File.open(filename, "w") do |f|
      f.write(infile.read)
    end

    new_str_action = ModellerAction.new(
        :params => parameters,
        :job => job,
        :status => 'i',
        :forward_controller => 'hhpred',
        :forward_action => 'results'
        )

    new_str_action.sequence_file = filename
    parameters.each do |key,value|
      if (key != "job" && key != "parent" && key != "method" && key != "forward_controller" && key != "forward_action" && new_str_action.respond_to?(key))
        eval "new_str_action."+key+" = value"
      end
    end

    new_str_action.save!

    new_str_action.run

    userdb.str_id = job.jobid
    userdb.save!
    job.user_id = userdb.user_id
    job.save!
    STDOUT.write("\n#{Time.now} - Toolkit Modeller Job ID: #{job.jobid} created for #{userdb.name}\n")

    system("rm -f #{infilename}")
  end

end

#########################################################################################################################################################################################
# Deleting sequences with no response to warnings

def delete_if_no_response
  @userdbs = Watchlist.find( :all)
  @userdbs.each do |userdb|
    if (userdb.warning_key > 20000000 && Time.now.to_i - userdb.updated_on.to_i > MAX_DAYS_AFTER_WARNING*24*60*60)
      Watchlist.delete_all(["user_id = ?",userdb.user_id])
      STDOUT.write("\n#{Time.now} - All sequences of User ID:#{userdb.user_id} deleted from PDB watchlist since there was no response even after 2 warnings in last #{2*MAX_DAYS_AFTER_WARNING} days\n")
    end
  end
end

#########################################################################################################################################################################################
# Warning users for unchecked results or long inactivity

def generate_warning_key 
  id = (rand(9)+1).to_s
  6.times { id << rand(10).to_s}
  while (Watchlist.find(:first, :conditions => [ "warning_key = ?", id])) do 
    id = (rand(9)+1).to_s
    6.times { id << rand(10).to_s}
  end
  id
end

def second_warning
  @userdbs = Watchlist.find( :all)

  @userdbs.each do |userdb|
    if (userdb.warning_key != 0 && userdb.warning_key < 20000000 && Time.now.to_i - userdb.updated_on.to_i > MAX_DAYS_AFTER_WARNING*24*60*60)
      params = { 'name' => userdb.user.firstname, 'mail' => userdb.user.login, 'db' => userdb.name, 'date' => userdb.updated_on.to_date.to_s(:long), 'key' => userdb.warning_key }
      if(userdb.warning_key < 10000000)
        PdbalertMailer.deliver_mail_warning_unchecked(params)
      else
        PdbalertMailer.deliver_mail_warning_long(params)
      end
      STDOUT.write("\n#{Time.now} - Second warning sent to User ID:#{userdb.user_id} since he didn't respond to first warning\n")
      userdb.warning_key += 20000000       # warning key > 20000000 in this case
      userdb.save!
    end
  end
end

def warn_email
  second_warning
  @users = Watchlist.find_by_sql("select distinct(user_id) from watchlists")
  @users.each do |user|
    mail_sent = false
    inactive = true
    @userdbs = Watchlist.find_all_by_user_id(user.user_id)
    @userdbs.each do |userdb|
      if (mail_sent == false)
        if (userdb.job_id != 0)
          job = Job.find(:first, :conditions => ["jobid = ?",userdb.job_id])
        end
        if (userdb.warning_key == 0 && Time.now.to_i - userdb.updated_on.to_i > MAX_DAYS_TO_CHECK_RESULT*24*60*60 && userdb.job_id != 0 && job.viewed_on.nil?)
          userdb.warning_key = generate_warning_key             # warning key < 10000000 in this case
          params = { 'name' => userdb.user.firstname, 'mail' => userdb.user.login, 'db' => userdb.name, 'date' => userdb.updated_on.to_date.to_s(:long), 'key' => userdb.warning_key }
          PdbalertMailer.deliver_mail_warning_unchecked(params)
          userdb.save!
	  mail_sent = true
          STDOUT.write("\n#{Time.now} - Warning sent to User ID:#{userdb.user_id} since he didn't view the found results for #{MAX_DAYS_TO_CHECK_RESULT} days\n")
        end
        if (Time.now.to_i - userdb.updated_on.to_i < MAX_DAYS_INACTIVITY*24*60*60)
	  inactive = false
        end
      end
    end
    if(inactive && !mail_sent)
      userdb = @userdbs[0]
      userdb.warning_key = generate_warning_key.to_i+10000000     # 10000000 < warning key < 20000000 in this case
      params = { 'name' => userdb.user.firstname, 'mail' => userdb.user.login, 'date' => userdb.updated_on.to_date.to_s(:long), 'key' => userdb.warning_key }
      PdbalertMailer.deliver_mail_warning_long(params)
      userdb.save!
      mail_sent = true
      STDOUT.write("\n#{Time.now} - Warning sent to User ID:#{userdb.user_id} since their was no activity  for #{MAX_DAYS_INACTIVITY} days\n")
    end
  end
end

#########################################################################################################################################################################################
# Sending e-mails for newly found results
def email_results ( results )
  results.each do |userdb|
    userdb.reload
    params = { 'name' => userdb.user.firstname, 'mail' => userdb.user.login, 'db' => userdb.name, 'date' => userdb.created_on.to_date.to_s(:long), 'job_id' => userdb.job_id, 'str_id' => userdb.str_id, 'probability' => userdb.probability, 'match_name' => userdb.params['match_name'] }
    PdbalertMailer.deliver_mail_result(params)
  end
end

#########################################################################################################################################################################################
#Checking for homology in database of sequences kept on-hold
def on_hold_sequence_search(hmm_file=nil)
  if !File.exist?(File.join(PDB_ALERT_TMP,'hhr2'))
    Dir.mkdir(File.join(PDB_ALERT_TMP,'hhr2'))
  end
  
  on_hold_db=NEW_ON_HOLD_SEQUENCE_DATABASE
  @hmm_files = Array.new
  if hmm_file.nil?
    Dir.foreach(File.join(PDB_ALERT_TMP,'hhm')) do |file|
      if file =~ /\.hhm$/ 
        @hmm_files.push(file)
      end
    end
  else
    @hmm_files.push(hmm_file)
    on_hold_db=ALL_PDB_ON_HOLD_DATABASES
  end

  @hmm_files.each do |file|
    hhm_file = File.join(PDB_ALERT_TMP,'hhm',file)
    out_file = File.join(PDB_ALERT_TMP,'hhr2',file.gsub(/\.hhm/,'.hhr'))
    path = File.join(PDB_WATCHLIST,file.gsub(/\.hhm/,'.fas').gsub(/:,/,'/'))
    userdb = Watchlist.find( :first, :conditions =>  [ "path = ?", path ])
    
    if !userdb.nil?
      params = userdb.params
      @mapt = ''
      @realign = params["realign"] ? "-realign" : "-norealign"
      if @realign == '-realign'
        if @ali_mode == 'global'
          @mapt = '-mapt 0.0'
        else
          @mapt = params["mapt"].nil? ? '' : '-mapt '+params["mapt"]
        end
      end
#      STDOUT.write("\n#{Time.now} - Calibrating #{hhm_file} for on-hold sequences......\n")
#      system("#{QUEUE_SETTINGS}; #{RSUB_PATH} #{RSUB_OPTS} --interval 60 -c \"export TK_ROOT=#{TOOLKIT_ROOT}; #{HHPRED}/hhsearch -cpu 4 -v 1 -i #{hhm_file} -d #{CAL_DATABASE} -cal -#{params['alignmode']} -ssm #{params['ss_scoring']} -sc #{params['compbiascorr']} -norealign 1\"")
      STDOUT.write("\n#{Time.now} - Performing HHsearch for #{hhm_file} with on-hold sequence database (#{on_hold_db})......\n")
      system("#{QUEUE_SETTINGS}; #{RSUB_PATH} #{RSUB_OPTS} --interval 60 -c \"export TK_ROOT=#{TOOLKIT_ROOT}; #{HHPRED}/hhsearch -cpu 4 -v 1 -i #{hhm_file} -d #{on_hold_db} -o #{out_file} -p #{params['Pmin']} -P #{params['Pmin']} -Z #{params['maxlines']} -B #{params['maxlines']} -seq #{params['maxseq']} -aliw #{params['width']} -#{params['alignmode']} -ssm #{params['ss_scoring']} #{@realign} #{@mapt} -sc #{params['compbiascorr']} \"")
#      system("rm #{PDB_ALERT_TMP}/hhm/#{file.gsub(/\.hhm/,'.hhr')}")
    end
  end
  
  @matches = []
  @results = []
  @hmm_files.each do |file|
    path = File.join(PDB_WATCHLIST,file.gsub(/\.hhm/,'.fas').gsub(/:,/,'/'))
    userdb = Watchlist.find( :first, :conditions =>  [ "path = ?", path ])
    if !userdb.nil?
      present_prob = userdb.probability
      if !userdb.params['Emax'].nil?
        present_Emax = userdb.params['Emax'].to_f
      else
        present_Emax = 1
      end
      if !userdb.params['Imin'].nil?
        present_Imin = userdb.params['Imin'].to_f
      else
        present_Imin = 20
      end
      
      hhr = File.new(File.join(PDB_ALERT_TMP,'hhr2',file.gsub(/\.hhm/,'.hhr')))
      @lines = hhr.readlines
      @line = @lines[9]
      prob = @line[35..39].to_f
      emax = @line[44..47].to_f
      cut = 0
      @lines.each_index do |i|
        if @lines[i]=~/^No 1\s*$/
          cut = i
        end
      end
      @name = @lines[cut+1].gsub(/>/,'')
      imin = @lines[cut+2].gsub(/^.*Identities=(.*)\%.*$/,'\1').to_f
      if(prob > present_prob + 0.1 && emax < present_Emax - 0.01 && imin > present_Imin + 0.1)
        @matches.push(file.gsub(/\.hhm/,'.hhr'))
        userdb.params['match_name'] = @name
        userdb.save!
        @results.push(userdb)
        STDOUT.write("\n#{Time.now} - Match found for #{file}\n")
      end
    end
  end

  create_toolkit_job(@matches,ALL_PDB_ON_HOLD)

  @results.each do |userdb|
    userdb.reload
    params = { 'name' => userdb.user.firstname, 'mail' => userdb.user.login, 'db' => userdb.name, 'date' => userdb.created_on.to_date.to_s(:long), 'job_id' => userdb.job_id, 'str_id' => userdb.str_id, 'probability' => userdb.probability, 'match_name' => userdb.params['match_name'] }
    PdbalertMailer.deliver_mail_result_on_hold(params)
  end

end

#########################################################################################################################################################################################
#Functions that run the functions required for different cases
def execute_all
  on_hold_sequence_search
  perform_hhsearch
  @return_array = analyse_result
  len = @return_array.length
  @hits = @return_array[0..len/2-1]
  @results = @return_array[len/2..len-1]
  create_toolkit_job(@hits)
  create_toolkit_str_job(@hits)
  delete_if_no_response
  warn_email
  email_results(@results)
end

def execute_recovery
  perform_hhsearch
  @return_array = analyse_result
  len = @return_array.length
  @hits = @return_array[0..len/2-1]
  @results = @return_array[len/2..len-1]
  create_toolkit_job(@hits)
  create_toolkit_str_job(@hits)
  delete_if_no_response
  warn_email
  email_results(@results)
end
		  
def execute_one(watchlist_id)
  userdb = Watchlist.find(watchlist_id)
  hhm_file = create_hmm(userdb.user.login,File.basename(userdb.path),userdb.params)
  on_hold_sequence_search(File.basename(hhm_file))
  perform_hhsearch(File.basename(hhm_file))
  @return_array = analyse_result
  len = @return_array.length
  @hits = @return_array[0..len/2-1]
  @results = @return_array[len/2..len-1]
  create_toolkit_job(@hits)
  create_toolkit_str_job(@hits)
  email_results(@results)
end

#########################################################################################################################################################################################
#Main function that chooses which kind of operation particular execution requires
def main
  STDOUT.write("\n#{Time.now} - STARTED - #{ARGV[0]}\n")

  # check TMP directories
  if !File.exist?(File.join(PDB_ALERT_TMP))
    Dir.mkdir(File.join(PDB_ALERT_TMP))
  end
  if !File.exist?(File.join(TMP, "rsub"))
    Dir.mkdir(File.join(TMP, "rsub"))
  end


  if ARGV[0].nil?
    execute_all
  elsif ARGV[0] == "0"
    execute_recovery
  else 
    execute_one(ARGV[0])
  end
  
  STDOUT.write("\n#{Time.now} - DONE - #{ARGV[0]}\n")
end

main

#########################################################################################################################################################################################
