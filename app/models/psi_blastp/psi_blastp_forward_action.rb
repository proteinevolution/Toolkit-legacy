require 'forward_hits'

class PsiBlastpForwardAction < Action
  require 'ForwardActions.rb'
  include ForwardActions
  include ForwardHits

  def do_fork?
    return false
  end

  attr_accessor :hits, :includehits, :alignment

  validates_checkboxes(:hits, {:on => :create, :include => :includehits, :alternative => :alignment})

  def run
    forward_hits(".psiblastp", true, false, logger, job, params, queue)
  end

  def forward_params
    forward_alignment_tools()
  end
    
end

