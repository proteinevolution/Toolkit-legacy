require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../test_helper'

class <%= class_name %>Test < Test::Unit::TestCase
  fixtures 'actions'

  # Replace this with your real tests.
  def test_truth
    assert_kind_of <%= class_name %>, 'actions'
  end
end
