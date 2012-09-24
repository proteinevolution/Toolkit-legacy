class ToolParam < ActiveRecord::Base
  
  attr_accessible :glob, :user_id, :tool
  
  serialize :glob
end