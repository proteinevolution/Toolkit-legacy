#!/usr/bin/ruby
require File.join(File.dirname(__FILE__), '../config/environment')

PRODUCTION  = "/cluster/toolkit/production" 
DEVELOPMENT = (Pathname.new(RAILS_ROOT)).realpath.to_s
BACKUPPATH  = "/archive/backup/toolkit"

ESCAPED_PRODUCTION  = PRODUCTION.gsub('/',"\\/")
ESCAPED_DEVELOPMENT = DEVELOPMENT.gsub('/',"\\/")

del=0
#check for the development environemnt
if( ENV['RAILS_ENV']=="production" )
	raise("This script copies the development to the production environment!\n 
	Please call it from the development environment!\n")
end

#check cmd line args
ARGV.each{ |a|
	if( a=="-d" )
		del=1
	else
		puts "Usage: ./copy2production.rb [-d]\n"
		puts " -d  : optional, remove all files in production directory before copying."
		puts "\nThis script copies all files from development to production environment and changes paths in './bioprogs'."
		exit 1	
	end 
}

#ask the user wether he/she is shure about what will be done
input = "-"
while( input !~ /^(y|N|(\s*))$/i ) do
puts "Do you really want to copy all development files to the production environment? [y/N]"
input = $stdin.readline
end

#check if the user got chicken-hearted
if( input =~ /^(N|(\s*))$/i  )
	puts "User requested abortion!"
	exit
end

#change version number
version="";
filename = File.join(DEVELOPMENT, "config", "environment.rb")
file = IO.readlines(filename)
file.each do |line|
	if( line =~ /TOOLKIT_RELEASE\s*=\s*\'(.+)\'/ )
		version = $1
		puts "Current Toolkit-version is:\n #{version}"
		puts "Please enter version for this release:"
		version = $stdin.readline.chomp
		file[file.index(line)] = "TOOLKIT_RELEASE = '#{version}'"
	end
end
#write modified environment.rb
File.open(filename,"w") do |out|
	out.write(file)	
end	

#check if the user wants to delete the entire production dir before updating
if(del==1)
	puts "Deleting production environment files..."
	system("rm -rf #{PRODUCTION}/*")
end

#check if the production dir exists, else create it
if( !( File.exists?(PRODUCTION) && File.directory?(PRODUCTION) ) )
  Dir.mkdir(PRODUCTION)
end


puts "Remove backup-files *~, *#, *% ..."
#delete all backup/recovering files
system("find #{DEVELOPMENT} -iname '*~' | xargs rm ")
system("find #{DEVELOPMENT} -iname '*#' | xargs rm ")
system("find #{DEVELOPMENT} -iname '*%' | xargs rm ")

puts "Copy#{DEVELOPMENT} --> #{PRODUCTION} ..."
#rsync development and production dir
system("cp -f -p -r -v -d #{DEVELOPMENT}/app/* #{PRODUCTION}/app/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/bioprogs/* #{PRODUCTION}/bioprogs/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/config/* #{PRODUCTION}/config/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/databases/* #{PRODUCTION}/databases/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/db/* #{PRODUCTION}/db/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/doc/* #{PRODUCTION}/doc/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/lang/* #{PRODUCTION}/lang/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/lib/* #{PRODUCTION}/lib/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/public/* #{PRODUCTION}/public/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/script/* #{PRODUCTION}/script/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/test/* #{PRODUCTION}/test/")
system("cp -f -p -r -v -d #{DEVELOPMENT}/vendor/* #{PRODUCTION}/vendor/")

#enable the production mode by uncommenting the magic line in environment.rb	
#read environment.rb
filename = File.join(PRODUCTION, "config", "environment.rb")
puts "Changes #{filename} for production mode..."
file = IO.readlines(filename)
file.each do |line|
	if( line =~ /^# ENV\['RAILS_ENV'\] \|\|= 'production'/ )
		file[file.index(line)] = "ENV['RAILS_ENV'] ||= 'production'\n"
	end
end
#write modified environment.rb
File.open(filename,"w") do |out|
	out.write(file)	
end		

puts "Autoreplace #{ESCAPED_DEVELOPMENT} --> #{ESCAPED_PRODUCTION}..."
#replace all '/cluster/www/toolkit' to '/cluster/www/toolkit_prod' paths in perl and config files of bioprogs
#system("#{DEVELOPMENT}/bioprogs/perl/autoreplace.pl '#{ESCAPED_PRODUCTION}' '#{ESCAPED_DEVELOPMENT}' -f -n -r #{PRODUCTION}/bioprogs/*")
system("#{DEVELOPMENT}/bioprogs/perl/autoreplace.pl '#{ESCAPED_DEVELOPMENT}' '#{ESCAPED_PRODUCTION}' -f -n -r #{PRODUCTION}/bioprogs/*")
#clean /tmp
puts "Cleaning /tmp/ dir..."
system("sudo su toolkit -c 'rm -rf /tmp/*; exit'")

#create backup
puts "Create backup of current release(#{version})..."
name = "toolkit_release_#{version.gsub(/\./,"_")}"
system("zip -r -y #{BACKUPPATH}/#{name}.zip #{PRODUCTION} -x #{PRODUCTION}/tmp/\*")

puts "done.\n"
exit
