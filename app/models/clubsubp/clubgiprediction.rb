class Clubgiprediction < ActiveRecord::Base
    has_and_belongs_to_many :clubclstpredictions
    has_and_belongs_to_many :clubproteinheaderinfos

end

