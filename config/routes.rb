ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.home '', :controller => 'common', :action => 'index'

  map.section 'sections/:action',
  :controller => "sections",
  :tool => nil

  map.common 'common/:action',
  :controller => 'common'
  
  map.connect ':controller',:action => "index"
  map.connect ':controller/:action'
  map.connect ':controller/run/:job', :action => "run"
  map.connect ':controller/run/:job/:jobaction', :action => "run"  
  map.connect ':controller/run/:job/:forward_controller/:forward_action', :action => "run"
  map.connect ':controller/:action/:jobid'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
