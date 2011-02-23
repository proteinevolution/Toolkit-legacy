class Clubarchgiprediction < ActiveRecord::Base
    has_and_belongs_to_many :clubarchclstpredictions
    has_and_belongs_to_many :clubproteinheaderinfos

end

