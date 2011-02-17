class Clubarchresultsgicomment < ActiveRecord::Base
    establish_connection "clubsubp"
    has_and_belongs_to_many :clubarchgipredictions
    has_and_belongs_to_many :clubproteinheaderinfos
end

