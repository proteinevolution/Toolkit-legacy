require File.dirname(__FILE__) + '/../../test_helper'

class ProtBlast::ProtBlastJobTest < Test::Unit::TestCase
  fixtures :prot_blast_jobs

  # Replace this with your real tests.
  def test_truth
    assert_kind_of ProtBlast::ProtBlastJob, prot_blast_jobs(:first)
  end
end
