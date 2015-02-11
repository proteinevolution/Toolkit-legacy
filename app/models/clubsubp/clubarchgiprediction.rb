require "protected_sql.rb"

class Clubarchgiprediction < ActiveRecord::Base
    establish_connection "clubsubp"
    has_and_belongs_to_many :clubarchclstpredictions
    has_and_belongs_to_many :clubproteinheaderinfos

    include ProtectedSql
end

