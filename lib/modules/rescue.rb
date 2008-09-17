# chris 23.10.2006
# this modules overwrites the rescue_action_in_public(exception) method 
# to render the standart 500.html file instead of the hard coded Application error (Rails) message
# see the original file below

module ActionController
  module Rescue
    protected
      # Overwrite to implement public exception handling (for requests answering false to <tt>local_request?</tt>).
      def rescue_action_in_public(exception) #:doc:
        case exception
          when RoutingError, UnknownAction then
            render(IO.read(File.join(RAILS_ROOT, 'public','404.html')), "404 Not Found")
          else 
            render(IO.read(File.join(RAILS_ROOT, 'public', '500.html')), "<html><body><h1>Application error (Rails)</h1></body></html>")
        end
      end
  end
end

            
            
            
#actionpack/lib/action_controller/rescue.rb (line 55):
#      def rescue_action_in_public(exception) #:doc:
#        case exception
#          when RoutingError, UnknownAction then
#            render_text(IO.read(File.join(RAILS_ROOT, 'public','404.html')), "404 Not Found")
#          else render_text "<html><body><h1>Application error(Rails)</h1></body></html>"
#        end
#      end

