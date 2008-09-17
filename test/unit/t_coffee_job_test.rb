require File.dirname(__FILE__) + '/../test_helper'

class TCoffeeTest < Test::Unit::TestCase
  fixtures 'jobs'

  # Replace this with your real tests.
  def test_truth
    assert_kind_of TCoffee, 'jobs'
  end
end
