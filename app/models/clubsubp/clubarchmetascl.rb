require "protected_sql.rb"

class Clubarchmetascl < ActiveRecord::Base
#   has_and_belongs_to_many :dapfragments
    establish_connection "clubsubp"

    include ProtectedSql
end

