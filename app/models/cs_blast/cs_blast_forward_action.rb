require 'forward_hits'

class CsBlastForwardAction < Action
  require 'ForwardActions.rb'
  include ForwardActions
  include ForwardHits
  
  attr_accessor :hits, :includehits, :alignment
	
  validates_checkboxes(:hits, {:on => :create, :include => :includehits, :alternative => :alignment})
    
  def run
    forward_hits(".csblast", false, true, logger, job, params, queue)
  end

  def forward_params
    forward_alignment_tools()
  end
end

