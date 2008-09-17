require File.dirname(__FILE__) + '/../test_helper'
require 'prot_blast_controller'

# Re-raise errors caught by the controller.
class ProtBlastController; def rescue_action(e) raise e end; end

class ProtBlastControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProtBlastController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
