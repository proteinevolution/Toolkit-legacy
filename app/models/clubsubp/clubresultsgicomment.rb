class Clubresultsgicomment < ActiveRecord::Base
    establish_connection "clubsubp"
    has_and_belongs_to_many :clubgipredictions
    has_and_belongs_to_many :clubproteinheaderinfos
    has_and_belongs_to_many :clubgioutextratmdisplays

    include ProtectedSql
end

