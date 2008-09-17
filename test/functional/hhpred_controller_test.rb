require File.dirname(__FILE__) + '/../test_helper'
require 'hhpred_controller'

# Re-raise errors caught by the controller.
class HhpredController; def rescue_action(e) raise e end; end

class HhpredControllerTest < Test::Unit::TestCase
  def setup
    @controller = HhpredController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
