class BadController < ToolController

	BAD = File.join(BIOPROGS, 'bad')

	def index
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
		
		@ret = ""
		open("|#{BAD}/main.cgi page=#{@page} domain=#{@domain}") do |ret|
			@ret = ret.readlines.join
		end
		
		if (@id != "")
			@ret.gsub!(/\/bad\/browse/, "/bad/browse/#{@id}")
		end
		
		@widescreen = true
	end
	
	def search
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
