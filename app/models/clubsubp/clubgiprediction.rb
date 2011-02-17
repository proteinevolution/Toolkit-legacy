class Clubgiprediction < ActiveRecord::Base
    establish_connection "clubsubp"
    has_and_belongs_to_many :clubclstpredictions
    has_and_belongs_to_many :clubproteinheaderinfos

end

