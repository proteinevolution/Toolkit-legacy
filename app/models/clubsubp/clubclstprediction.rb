class Clubclstprediction < ActiveRecord::Base
    establish_connection "clubsubp"
    has_and_belongs_to_many :clubgipredictions
    has_and_belongs_to_many :clubproteinheaderinfos

end

