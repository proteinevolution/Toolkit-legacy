class Clubarchresultsgicomment < ActiveRecord::Base
    has_and_belongs_to_many :clubarchgipredictions
    has_and_belongs_to_many :clubproteinheaderinfos
end

