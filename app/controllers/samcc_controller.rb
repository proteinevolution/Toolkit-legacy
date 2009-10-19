class SamccController < ToolController

  def index
    @periodicity_values = ['7', '11', '18']
    @periodicity_labels = ['7', '11', '18']
  end

end
