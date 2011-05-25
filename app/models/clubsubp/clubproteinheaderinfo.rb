class Clubproteinheaderinfo < ActiveRecord::Base
    establish_connection "clubsubp"
    has_and_belongs_to_many :clubclstpredictions
    has_and_belongs_to_many :clubgipredictions
    has_and_belongs_to_many :clubarchclstpredictions
    has_and_belongs_to_many :clubarchgipredictions

end

