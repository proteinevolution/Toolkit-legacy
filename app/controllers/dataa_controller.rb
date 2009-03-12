class DataaController < ToolController

	BAD = File.join(BIOPROGS, 'dataa')

	def search
		@ret = ""
		open("|#{BAD}/main.cgi") do |ret|
			@ret = ret.readlines.join
		end
		@widescreen = true
		@id = params['jobid'] ? params['jobid'] : ""
	end
	
	def browse
		@include_js = ["domTT/domLib", "domTT/domTT", "domTT/domTT_drag"]
		@include_js_text = "var domTT_styleClass = 'domTT';"
		@include_css = "domtt.css"
		@include_css_text = ".ramka {color: #000000; border-top: 1px silver solid; border-bottom: 1px silver solid; background-color: #ECF1F4; }\n	.delikatna {color: #000000; border-top: 1px silver solid; border-left: 1px silver solid; background-color: white;}"
		
		@id = params['jobid'] ? params['jobid'] : ""
		@domain = params['domain'] ? params['domain'] : ""
		@page = params['page'] ? params['page'] : "browse"
		@db = params['db'] ? params['db'] : ""

#		@ret = "aq"
#		open("|#{BAD}/main.cgi page=#{@page} domain=#{@domain}") do |ret|
#			@ret = ret.readlines.join
#		end
		
		if (@domain != "")
			@ret = "aq"
	                open("|#{BAD}/main.cgi page\=show domain\=#{@domain} db=#{@db}") do |ret|
		        @ret = ret.readlines.join
			#
			end
			@ret.gsub!(/\/dataa\/browse/, "/dataa/browse/#{@id}")
		else
			@ret = "aq2 #{BAD}/main.cgi page=browse"
#			@ret = `#{BAD}/main.cgi page\=show domain\=1`
			open("|#{BAD}/main.cgi page\=browse ") do |ret| 
        		@ret = ret.readlines.join
			end
		end
		@widescreen = true
	end

	def showimage
		@id = params['jobid'] ? params['jobid'] : ""
		@image = params['image'] ? params['image'] : ""
		@db = params['db'] ? params['db'] : "domains"
		open ("|#{BAD}/main.cgi page\=show image\=#{@image} db=#{@db}") do |img| 
		img.binmode
		@img = img.readlines.join
		end
		send_data(@img, :type => 'image/png', :disposition => 'inline')

	end	

	def showpic
		@id = params['jobid'] ? params['jobid'] : ""
		@image=params['image2'] ? params['image2'] : ""
		@db=params['db'] ? params['db'] : "domains"
		open ("|#{BAD}/main.cgi page\=show image2\=#{@image} db\=#{@db}") do |img|
		img.binmode
		@img = img.readlines.join
		end
		send_data(@img, :type => 'image/png', :disposition => 'inline')

	end
	
	def index
		@widescreen = true
	end
	
	def results
		@widescreen = true
		@include_js = ["domTT/domLib", "domTT/domTT.js", "domTT/domTT_drag"]
		@include_js_text = "var domTT_styleClass = 'domTT';"
		@include_css = "domtt.css"
		@include_css_text = ".ramka {color: #000000; border-top: 1px silver solid; border-bottom: 1px silver solid; background-color: #ECF1F4; }\n	.delikatna {color: #000000; border-top: 1px silver solid; border-left: 1px silver solid; background-color: white;}"
		
	end
  
end
