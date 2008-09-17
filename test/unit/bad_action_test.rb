require File.dirname(__FILE__) + '/../test_helper'

class BadTest < Test::Unit::TestCase
  fixtures 'actions'

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Bad, 'actions'
  end
end
