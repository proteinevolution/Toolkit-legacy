require File.dirname(__FILE__) + '/../test_helper'

class PatsearchTest < Test::Unit::TestCase
  fixtures 'jobs'

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Patsearch, 'jobs'
  end
end
