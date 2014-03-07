# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include Localization

  #patch functions for user/group managment to this class
  include UserGroupModule
  
  def link_to_tool(tool)
    link_to tool["title"], :controller => tool["name"], :action => "index"
  end

  def show_tool(tool)
    tool["active"]
  end
  
  def form_label(labeltext, anchor=nil, controller=nil)
    if anchor.nil?  
      "<div class=\"label\">#{labeltext}</div>"
    elsif controller.nil?
      url = url_for(:action => "help_params") + "#" + anchor
      "<a href=\"#\" onClick=\"openHelpWindow('#{url}');\"><div class=\"label\">#{labeltext}</div></a>"
    else
      url = url_for(:controller => controller, :action => "help_params") + "#" + anchor
      "<a href=\"#\" onClick=\"openHelpWindow('#{url}');\"><div class=\"label\">#{labeltext}</div></a>" 
    end
  end
  
  def form_label_id(labeltext, labelid=nil ,anchor=nil, controller=nil)
    
    if labelid.nil?  
         "<div class=\"label\">#{labeltext}</div>"
    elsif anchor.nil?  
      "<div class=\"label\" id=\"#{labelid}\">#{labeltext}</div>"
    elsif controller.nil?
      url = url_for(:action => "help_params") + "#" + anchor
      "<a href=\"#\" onClick=\"openHelpWindow('#{url}');\"><div class=\"label\"   id=\"#{labelid}\"    >#{labeltext}</div></a>"
    else
      url = url_for(:controller => controller, :action => "help_params") + "#" + anchor
      "<a href=\"#\" onClick=\"openHelpWindow('#{url}');\" ><div class=\"label\"  id=\"#{labelid}\"    >#{labeltext}</div></a>" 
    end
  
  
  
  
  end
  
  def form_checkbox(name, value=1, default=true, noformw=false, onchange="", disable=false)
    checked = (params['reviewing']||params.has_key?(name)) ? (params[name] ? params[name] : false) : default
    checked = @error_params.empty? ? checked : (@error_params[name] ? @error_params[name] : false)
    if(noformw)
      check_box_tag(name, value, checked)
    else
      wrap_form_widget check_box_tag(name, value, checked, :onchange => onchange, :disabled => disable)
    end
  end

  def form_text_field(name, default="", descr="", size=5, disable=false, prefix="", noformw=false)
    value = params[name] ? params[name] : default
    value = @error_params[name] ? @error_params[name] : value
    style = @errors[name] ? "formerror" : ""
    if(noformw)
      ret = ""
      if !@errors[name].nil?
        ret = "<p class='formerror'>#{@errors[name]}</p>\n"
      end
      ret = ret << prefix << text_field_tag(name, value, :size => size, :id => name, :class => style, :disabled => disable) << "&nbsp;#{descr}"
    else
      wrap_form_widget(prefix << text_field_tag(name, value, :size => size, :id => name, :class => style, :disabled => disable) << "&nbsp;#{descr}", @errors[name])
    end
  end

  def form_text_area(name, default="")
    value = params[name] ? params[name] : default
    value = @error_params[name] ? @error_params[name] : value
    style = @errors[name] ? "formerror" : ""
    wrap_form_widget(text_area_tag(name, value, :wrap => "off", :rows => 5, :id => name, :class => style), @errors[name])
  end

  def form_hidden_field(name, value=nil, options={})
    value = params[name] ? params[name] : value
    value = @error_params[name] ? @error_params[name] : value
    ret = ""
    if !@errors[name].nil?
      ret = "<p class='formerror'>#{@errors[name]}</p>\n"
    end
    ret = ret << hidden_field_tag(name, value, options)
  end


  def form_file(name, onchange="", onkeyup="")
    wrap_form_widget(file_field_tag(name, :onchange => onchange, :onkeyup => onkeyup, :maxlength => 500000, :size => 60, :id => name), @errors[name])
  end
  
  def form_select_single_with_hash(name, values, labels, kwarguments)
    default = kwarguments.has_key?(:default) ? kwarguments[:default] : ""
    maxsize = kwarguments.has_key?(:maxsize) ? kwarguments[:maxsize] : 1
    onchange = kwarguments.has_key?(:onchange) ? kwarguments[:onchange] : ""
    disable = kwarguments.has_key?(:disable) ? kwarguments[:disable] : false
    noformw = kwarguments.has_key?(:noformw) ? kwarguments[:noformw] : false 
    form_select_single(name, values, labels, default, maxsize, onchange, disable, noformw, kwarguments)
  end

  def form_select_single(name, values, labels, default="", maxsize=1, onchange="", disable=false, noformw=false, kwargs={})
    #size = maxsize > values.length ? values.length : maxsize 
    size = maxsize
    selected = (params['reviewing']||params[name]) ? params[name] : default.to_s
    selected = @error_params[name] ? @error_params[name] : selected
    options = ""
    create_array = kwargs.has_key?(:array) ? kwargs[:array] : false
    
    modes = kwargs.has_key?(:modes) ? kwargs[:modes] : []
    for i in 0..values.length-1 do
      value = values[i].to_s
      label = labels[i].to_s
      mode = modes.empty? ? "" : modes[i]
      mode_attr = mode == "" ? "" : "acceptance=\"#{mode}\""
      sel_attr = selected == value ? "selected=\"selected\"" : ""
      options << "<option value=\"#{value}\" #{sel_attr} #{mode_attr}>#{label}</option>\n"
    end
    nameparam = create_array ? name + '[]' : name
    if (noformw)
      select_tag(nameparam, options, :id => name, :size => size, :onchange => onchange, :disabled => disable)
    else
      wrap_form_widget select_tag(nameparam, options, :id => name, :size => size, :onchange => onchange, :disabled => disable)
    end
  end

  def form_select_multiple(name, values, labels, default=[], maxsize=5, wrap=true, onchange="")
    #    size = maxsize > values.length ? values.length : maxsize 
    size = maxsize
    selected = (params['reviewing']||params[name]) ? (params[name] ? params[name] : "") : default.to_s
    selected = @error_params.empty? ? selected : (@error_params[name] ? @error_params[name] : "")
    style = @errors[name] ? "formerror" : ""
    options = ""
    for i in 0..values.length-1 do
      value = values[i].to_s
      label = labels[i].to_s
      sel = selected.find {|c| c == value}
      sel_attr = sel ? "selected=\"selected\"" : ""
      options << "<option value=\"#{value}\"  #{sel_attr}>#{label}</option>\n"
    end
    if wrap
      wrap_form_widget(select_tag(name+'[]', options, :id => name, :multiple => true, :size => size, :class => style, :onchange => onchange), @errors[name])
    else
      ret = ""
      if (!@errors[name].nil?)
        ret = ret << "<p class='formerror'>#{@errors[name]}</p>\n"
      end
      ret = ret << select_tag(name+'[]', options, :id => name, :multiple => true, :size => size, :class => style, :onchange => onchange)
    end
  end
  
  def form_radio_buttons(name, values, labels, default="", sep="<br/>", onchange="", id_value=0)
    checkval = params[name] ? params[name] : default.to_s
    checkval = @error_params[name] ? @error_params[name] : checkval
    content = ""
    for i in 0..values.length-1 do
      value = values[i].to_s
      label = labels[i].to_s
      if( id_value==1 )
       	content = content << radio_button_tag(name, value, checkval.eql?(value), :onchange => onchange, :id=>value) << "&nbsp;" << label
      else
      	content = content << radio_button_tag(name, value, checkval.eql?(value), :onchange => onchange) << "&nbsp;" << label
      end      
      if i < values.length
        content = content << sep 
      end
    end
    wrap_form_widget(content)
  end

  def form_reset_buttons
    # the test on sequence_input should be replaced with a test on a resubmit... action
    # possible actions: resubmit, resubmit_domain, ...
    if params['sequence_input']
      # A button "Reset form" may not be understood, because
      # it doesn't clear the form, but restores the original input.
      ret = "<input name=\"resetform\" id=\"resetform\" type=\"reset\" class=\"toolbutton\" value=\"Restore input\" />"
      ret = ret << "<input name=\"newform\" id=\"newform\" type=\"button\" class=\"toolbutton\" onclick=\"window.location.href='#{url_for(:action => 'index')}';\" value=\"New form\" /><br/>"
    else
      ret = "<input name=\"resetform\" id=\"resetform\" type=\"reset\" class=\"toolbutton\" value=\"Reset form\" /><br/>"
    end
  end
 
  def form_submit_buttons
    ret = "<input name=\"submitform\" id=\"submitform\"  type=\"submit\" class=\"toolbutton\" value=\"Submit job\" />"
    ret = ret << form_reset_buttons()
  end
    
  def form_submit_snail_buttons(message)
    ret = "<input name=\"submitform\" type=\"submit\" class=\"snailbutton\" value=\"Submit job\" onmouseover=\"return overlib('#{message}');\" onmouseout=\"return nd();\" />"
    ret = ret << form_reset_buttons()
  end

  def wrap_form_widget(content, errormsg=nil)
    ret = "<div class=\"formw\">"
    if (!errormsg.nil?)
      ret = ret << "<p class='formerror'>#{errormsg}</p>\n"
    end
    ret = ret << content
    ret = ret << "</div>\n" 
  end

  def is_internal?(ip)
    begin
      ip = IPAddr.new(ip)
      INT_IPS.each do |mask|
        if mask.include?(ip) then return true end   
      end 
      return false
    rescue Exception => e
      return false
    end
  end


  #def form_add_button(name, options = {})
  #  label = "#{name}"
  #  #label = l(:"#{@controller.controller_name}_#{name}_button")
  #  "#{self.send(:submit_tag, label, options)}"
  #end

end
