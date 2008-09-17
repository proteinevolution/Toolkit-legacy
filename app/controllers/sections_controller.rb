class SectionsController < ApplicationController
  before_filter :prepare
  
  def prepare
    @section = @sections_hash[params[:action]]
    if !@section.nil?
      @page_title = @section['title_long']
    end
  end

end
