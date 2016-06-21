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

  def form_select_multiple(name, values, labels, default=[], maxsize=5, wrap=true, onchange="", onclick="")
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
      wrap_form_widget(select_tag(name+'[]', options, :id => name, :multiple => true, :size => size, :class => style, :onchange => onchange, :onclick => onclick), @errors[name])
    else
      ret = ""
      if (!@errors[name].nil?)
        ret = ret << "<p class='formerror'>#{@errors[name]}</p>\n"
      end
      ret = ret << select_tag(name+'[]', options, :id => name, :multiple => true, :size => size, :class => style, :onchange => onchange, :onclick => onclick)
    end
  end

  def form_radio_buttons(name, values, labels, default="", sep="<br/>", onchange="", id_value=0, disable=false)
    checkval = params[name] ? params[name] : default.to_s
    checkval = @error_params[name] ? @error_params[name] : checkval
    content = ""
    for i in 0..values.length-1 do
      value = values[i].to_s
      label = labels[i].to_s
      if( id_value==1 )
       	content = content << radio_button_tag(name, value, checkval.eql?(value), :onchange => onchange, :disabled => disable, :id=>value) << "&nbsp;" << label
      else
      	content = content << radio_button_tag(name, value, checkval.eql?(value), :onchange => onchange, :disabled => disable) << "&nbsp;" << label
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
        #if mask.include?(ip) then return true end   
        if (mask.include?(ip) && @user.login == "vikram.alva@tuebingen.mpg.de") then return true end
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

  # form_jalview_label formats a label for a jalview button
  # labeltext   text of label
  # len         size of label (in em unit). Defaults to length of labeltext. If 0, size of label remains unspecified.
  # anchor      section name in help file. If nil, no link to help file is generated.
  # controller  the help results file of that controller is used
  # lines       number of lines which are used (only 1 or 2 allowed)
  def form_jalview_label(labeltext, len=nil, anchor=nil, controller=nil, lines=1)
    if (len.nil?)
      len=labeltext.length
    end
    if 0 == len
      style_clause = ""
    else
      style_clause = "width:#{len}em;"
    end
    if 2==lines
      style_clause += "padding-top:4px;" # standard value (10px) reduced by 6px
    end
    if !style_clause.empty?
      style_clause = " style=\"#{style_clause}\""
    end
    if anchor.nil?
      "<div class=\"help_jal\" #{style_clause}><strong>#{labeltext}</strong></div>"
    else
      if controller.nil?
        url = url_for(:action => "help_results") + "#" + anchor
      else
        url = url_for(:controller => controller, :action => "help_results") + "#" + anchor
      end
        
      "<div class=\"help_jal\"#{style_clause}><a href=\"#\" onClick=\"openHelpWindow('#{url}');\">#{labeltext}</a></div>"
    end
  end

  # form_jalview_buttons formats two jalview buttons with labels in a row
  # label1     label to first jalview button
  # label2     label to second jalview button
  # len1       width of label1 (number of printed characters).
  #            If nil, defaults to number of characters in text. If 0, omitted.
  # len2       width of label2
  # ext1       file extension to use by first jalview button
  # ext2       file extension to use by second jalview button
  # anchor     section name in help file. If nil, no link to help file is generated.
  # controller the help results file of that controller is used
  # lines      number of lines used by labels (default 1, only 1 or 2 allowed)
  # colors     special user defined colors to use by jalview
  def form_jalview_buttons(label1, label2, len1, len2, ext1, ext2, anchor=nil, controller=nil, lines=1, colors=nil)
    res = <<-END_OF_STRING
    <div class="row">
    END_OF_STRING
    res += form_jalview_button(label1, len1, ext1, nil, anchor, controller, lines, colors) + "\n"
    res += form_jalview_button(label2, len2, ext2, nil, anchor, controller, lines, colors)
    res += <<-END_OF_STRING
      <div class="hr">&nbsp;</div>
    </div>
    END_OF_STRING
    res
  end

  # form_jalview_buttons_f formats two jalview buttons with labels in a row
  # label1     label to first jalview button
  # label2     label to second jalview button
  # len1       width of label1 (number of printed characters).
  #            If nil, defaults to number of characters in text. If 0, omitted.
  # len2       width of label2
  # file1      file to use by first jalview button
  # file2      file to use by second jalview button
  # anchor     section name in help file. If nil, no link to help file is generated.
  # controller the help results file of that controller is used
  # lines      number of lines used by labels (default 1, only 1 or 2 allowed)
  # colors     special user defined colors to use by jalview
  def form_jalview_buttons_f(label1, label2, len1, len2, file1, file2, anchor=nil, controller=nil, lines=1, colors=nil)
    res = <<-END_OF_STRING
    <div class="row">
    END_OF_STRING
    res += form_jalview_button(label1, len1, nil, file1, anchor, controller, lines, colors) + "\n"
    res += form_jalview_button(label2, len2, nil, file2, anchor, controller, lines, colors)
    res += <<-END_OF_STRING
      <div class="hr">&nbsp;</div>
    </div>
    END_OF_STRING
    res
  end

  # form_jalview_button formats a jalview buttons with a label
  # label      label to jalview button
  # len        width of label (number of printed characters).
  #            If nil, defaults to number of characters in text. If 0, omitted.
  # ext        file extension to use by jalview
  # file       file name to use by jalview (alternative to ext)
  # anchor     section name in help file. If nil, no link to help file is generated.
  # controller the help results file of that controller is used
  # lines      number of lines used by label (default 1, only 1 or 2 allowed)
  # colors     special user defined colors to use by jalview
  def form_jalview_button(label, len, ext=nil, file=nil, anchor=nil, controller=nil, lines=1, colors=nil)
    res = <<-END_OF_STRING
      <div class="jalview">
    END_OF_STRING
    locals = nil
    if (!file.nil?)
      locals = {:file => file}
    elsif (!ext.nil?)
      locals = {:file_extension => ext}
    end
    if (!colors.nil?)
      locals[:userDefinedColour] = colors
    end
    res += render(:partial => "shared/jalview", :locals => locals)
    res += <<-END_OF_STRING
      </div>
    END_OF_STRING
    res += form_jalview_label(label, len, anchor, controller, lines)
    res
  end

  # remove first id link from content string
  # keeps number of displayed characters to be useful in pre tag
  # id       name of anchor
  # content  string possibly including a link reference to the anchor.
  #          Restriction: No '<' allowed in linked text.
  def remove_idlink(id, content)
    content.sub(/<a href\s*=\s*##{id}>([^<]+)<\/a>/, '\1')
  end

end
