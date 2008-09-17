class SectionGenerator < Rails::Generator::NamedBase
  attr_reader :section_name, :section_title, :section_title_long, :theme

  def initialize(*runtime_args)
   
    super(*runtime_args)
   
    @section_name = @name.downcase
    
    @sections = YAML.load_file(CONFIG+"/sections.yml")
    
    if( @do_inquire && options[:command] == :create ) 
      # inquire values one by one
      if !defined?(@section_title) then inquire_section_title end
      if !defined?(@section_title_long) then inquire_section_title_long end
      if !defined?(@theme) then inquire_theme end
    elsif options[:command] == :create
      # provide default values based on @tool_name
      @section_title = @name.capitalize
      @section_title_long = @name
      @theme = "std"
    end

  end

  # Override with your own usage banner.
  def banner
    "Usage: #{$0} #{spec.name} #{spec.name.camelize}Name [options]"
  end

  def manifest
    record do |m|
      m.template 'section_view.rhtml', File.join('app','views','sections', "#{@section_name}.rhtml")
      manage_section_yml      
    end
  end

  private

  def add_options!(opt)
    opt.on('-I', '--inquire', 'Interactive mode') { |value| options[:do_inquire] = value; @do_inquire = value }
    opt.on('-T', '--section_title title') { |value| options[:section_title] = value; @section_title = value }
    opt.on('-L', '--section_title_long \'...\'', 'A more descriptive title') { |value| options[:section_title_long] = value; @section_title_long = value }
    opt.on('-C', '--color_theme name','Available themes: std,red,green,blue,ocker,darkred,darkblue') { |value| options[:theme] = value; @theme = value }
   end

  def manage_section_yml
    if( options[:command] == :create && options[:pretend].nil? )
      sections = YAML.load_file(CONFIG+"/sections.yml")
      sections << { 
        'name' => @section_name, 
        'title' => @section_title,
        'title_long' => @section_title_long,
        'active' => true,
        'theme' => @theme
      }
      File.open(CONFIG+"/sections.yml" ,'w') do |file|
        YAML.dump(sections, file)
      end
    elsif( options[:command] == :destroy && options[:pretend].nil? )
      sections = YAML.load_file(CONFIG+"/sections.yml")
      sections.delete_if {|h| h['name'] == @section_name }
      File.open(CONFIG+"/sections.yml" ,'w') do |file|
        YAML.dump(sections, file)
      end
    end 
  end
  

  def inquire_section_title
    puts "Please enter a section title [default: #{@section_name.capitalize}]"
    @section_title = $stdin.gets.strip
    if @section_title.empty? 
      @section_title = @section_name.capitalize  
    end
  end
  
  def inquire_section_title_long
    puts "Please enter a descriptive section title [default: #{@name}]"
    @section_title_long = $stdin.gets.strip
    if @section_title_long.empty? 
      @section_title_long = @section_name 
    end
  end
    
  def inquire_theme
    puts "Enter a theme (std,red,blue,green,darkred,darkblue,ocker) [std]"
    @theme = $stdin.gets.strip
    if @theme.empty?
      @theme = "std"
    end
  end
end
