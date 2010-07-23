class Clubgioutextratmdisplay < ActiveRecord::Base
    has_and_belongs_to_many :clubgipredictions
    has_and_belongs_to_many :clubproteinheaderinfos
    has_and_belongs_to_many :clubresultsgicomments
end

