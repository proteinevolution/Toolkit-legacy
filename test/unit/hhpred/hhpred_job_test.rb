require File.dirname(__FILE__) + '/../../test_helper'

class Hhpred::HhpredJobTest < Test::Unit::TestCase
  fixtures :hhpred_jobs

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Hhpred::HhpredJob, hhpred_jobs(:first)
  end
end
