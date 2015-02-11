require "protected_sql.rb"

class Clubclstprediction < ActiveRecord::Base
    establish_connection "clubsubp"
    has_and_belongs_to_many :clubgipredictions
    has_and_belongs_to_many :clubproteinheaderinfos

    include ProtectedSql
end

