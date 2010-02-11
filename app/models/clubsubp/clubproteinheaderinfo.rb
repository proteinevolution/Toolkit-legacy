class Clubproteinheaderinfo < ActiveRecord::Base
    has_and_belongs_to_many :clubclstpredictions
    has_and_belongs_to_many :clubgipredictions

end

