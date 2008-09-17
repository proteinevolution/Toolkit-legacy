class ToolGenerator < Rails::Generator::NamedBase
  attr_reader :tool_section, :tool_name, :tool_title, :tool_title_long, 
              :job_name, :job_title, :job_code, :action_name

  def initialize(*runtime_args)
   
   super(*runtime_args)
	if(  runtime_args[1][:pretend] )
		puts "\nPRETENDING MODE ENABLED - NO FILE CREATIONS!\n\n"
	end
   
	if( @name.to_s !~ /^[A-Z0-9].*/ )
		puts "ToolName must start with capital letter!"
		raise SystemExit
	end
   
    @tool_name = @name.camelize 
    @sections = YAML.load_file(CONFIG+"/sections.yml")
    
    if( @do_inquire && options[:command] == :create ) 
      # inquire values one by one
      if !defined?(@tool_section) then inquire_tool_section end
      if !defined?(@tool_title) then inquire_tool_title end
      if !defined?(@tool_title_long) then inquire_tool_title_long end
      if !defined?(@job_name) then inquire_job_name end
      if !defined?(@job_title) then inquire_job_title end
      if !defined?(@job_code) then inquire_job_code end
      if !defined?(@action_name) then inquire_action_name end
    elsif options[:command] == :create
      # provide default values based on @tool_name
      if !defined?(@tool_section) then inquire_tool_section end
      @tool_title = @tool_name
      @tool_title_long = @tool_name
      @job_name = @tool_name
      @job_title = @job_name
      @job_code = @job_name[0..3].upcase
      @action_name = @tool_name
    end

  end

  # Override with your own usage banner.
  def banner
    "Usage: #{$0} #{spec.name} #{spec.name.camelize}Name [options]"
  end

  def manifest
    record do |m|
      m.directory File.join('app/views', file_name)
      m.directory File.join('app/models', file_name)
      
      m.template 'controller.rb', File.join('app/controllers', "#{file_name}_controller.rb")
      #m.template 'functional_test.rb', File.join('test/functional', class_path, "#{file_name}_controller_test.rb")
      #m.template 'helper.rb', File.join('app/helpers', "#{file_name}_helper.rb")
      
      m.template 'job.rb',      File.join('app/models', file_name, "#{file_name}_job.rb")
      m.template 'action.rb',      File.join('app/models', file_name, "#{file_name}_action.rb")
      m.template 'unit_test_job.rb',  File.join('test/unit', "#{file_name}_job_test.rb")
      m.template 'unit_test_action.rb',  File.join('test/unit', "#{file_name}_action_test.rb")
      #m.template 'fixtures_job.yml',  File.join('test/fixtures', "#{file_name}_job.yml")
      #m.template 'fixtures_action.yml',  File.join('test/fixtures', "#{file_name}_action.yml")
      
      m.template 'index.rhtml', File.join('app/views', file_name, "index.rhtml")
      m.template 'results.rhtml', File.join('app/views', file_name, "results.rhtml")
      m.template 'export_browser.rhtml', File.join('app/views', file_name, file_name + "_export_browser.rhtml")
      m.template 'export_file.rhtml', File.join('app/views', file_name, file_name + "_export_file.rhtml")
      m.template '_description.rhtml', File.join('app/views', file_name, "_description.rhtml")
      m.template 'waiting.rhtml', File.join('app/views', file_name, "waiting.rhtml")
      m.template '_help_navigation.rhtml', File.join('app/views', file_name, "_help_navigation.rhtml")
      m.template 'help_ov.rhtml', File.join('app/views', file_name, "help_ov.rhtml")
      m.template 'help_params.rhtml', File.join('app/views', file_name, "help_params.rhtml")

      m.template 'tool.js', File.join('public/javascripts', "#{file_name}.js")
      m.template 'jobs.yml', File.join('config', "#{file_name}_jobs.yml")
      
      manage_tool_yml
      
    end
  end

  private

  def add_options!(opt)
    opt.on('-I', '--inquire', 'Interactive mode') { |value| options[:do_inquire] = value; @do_inquire = value }
    opt.on('-S', '--tool_section section') { |value| options[:tool_section] = value; @tool_section = value }
    opt.on('-T', '--tool_title title') { |value| options[:tool_title] = value; @tool_title = value }
    opt.on('-L', '--tool_title_long \'...\'', 'A more descriptive title') { |value| options[:tool_title_long] = value; @tool_title_long = value }
    opt.on('-N', '--job_name name') { |value| options[:job_name] = value; @job_name = value }
    opt.on('-J','--job_title title') { |value| options[:job_title] = value; @job_title = value }
    opt.on('-C','--job_code code', '4 letter code') { |value| options[:job_code] = value; @job_code = value }
    opt.on('-A','--action_name title') { |value| options[:action_name] = value; @action_name = value }
   end

  def manage_tool_yml
    if( options[:command] == :create && options[:pretend].nil? )
      tools = YAML.load_file(CONFIG+"/tools.yml")
      tools << { 
        'name' => @name.underscore, 
        'title' => @tool_title,
        'title_long' => @tool_title_long,
        'section' => @tool_section,
        'active' => ['member', 'internal', 'external']
      }
      File.open(CONFIG+"/tools.yml" ,'w') do |file|
        YAML.dump(tools, file)
      end
    elsif( options[:command] == :destroy && options[:pretend].nil? )
      tools = YAML.load_file(CONFIG+"/tools.yml")
      tools.delete_if {|h| h['name'] == @name.underscore }
      File.open(CONFIG+"/tools.yml" ,'w') do |file|
        YAML.dump(tools, file)
      end
    end 
  end
  

  def inquire_tool_title
    # inquire tool title
    puts "Please enter a tool title [default: #{tool_name}]"
    @tool_title = $stdin.gets.strip
    if @tool_title.empty? 
      @tool_title = tool_name 
    end
  end
  
  def inquire_tool_title_long
    # inquire tool title long
    puts "Please enter a descriptive tool title [default: #{tool_name}]"
    @tool_title_long = $stdin.gets.strip
    if @tool_title_long.empty? 
      @tool_title_long = tool_name 
    end
  end
    
  def inquire_tool_section
    # inquire tool section
    
    puts "Sections:"
    @sections.each_index do |i|
      printf "%3d %s\n", i+1, @sections[i]['name']      
    end
    print "\nPlease select a section for your tool: "
    

    section = $stdin.gets.strip.to_i
    while( section < 1 || section > @sections.size )
      puts "'#{section}' is not a valid section number! "
      print "Enter section number for the tool: "
      section = $stdin.gets.strip.to_i
    end
    @tool_section = @sections[section-1]['name']
  end

  def inquire_job_code
    # inquire job code
    puts "Enter a four letter code for the jobs that are associated with the tool. [default: #{tool_name[0..3].upcase}]"
    @job_code = $stdin.gets.strip
    if @job_code.empty? 
      @job_code = tool_name[0..3].upcase 
    end
  end

  def inquire_job_name
    # inquire job name
    puts "Please enter a name for the jobs that are created by this tool (each job has a name in addition to a unique id, we recommend to set this name to the toolname). [default: #{tool_name}]"
    @job_name = $stdin.gets.strip
    if @job_name.empty? 
      @job_name = tool_name
    end
  end
    
  def inquire_job_title
    # inquire job title
    puts "Please enter a title for the jobs. [default: #{tool_name}]"
    @job_title = $stdin.gets.strip
    if @job_title.empty? 
      @job_title = tool_name
    end
  end
    
  def inquire_action_name
    # inquire action name
    puts "Please enter a name for the default action of the job. [default: #{tool_name}]"
    @action_name = $stdin.gets.strip
    if @action_name.empty? 
      @action_name = tool_name
    end
  end

end
