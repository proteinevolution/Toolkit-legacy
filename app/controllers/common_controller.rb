class CommonController < ApplicationController
  before_filter :prepare

  def prepare
    @meta_section = params[:action]
  end

  def index
  end

  def contact
  end

  def remote_debug
	@widescreen=true;
  end
  
  def stats
  	@widescreen=true;
  end

  def db_stats
        @widescreen=true;
  end
  
  def user_stats
  	@fullscreen=true;
  end

  def impressum
  end
  
  def helpindex
    render(:layout => "help")
  end

  def disclaimer
  end
  
end
