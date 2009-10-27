  class Dapfragment < ActiveRecord::Base
    has_and_belongs_to_many :dapkeys
    has_and_belongs_to_many :dapscops

    #def self.create_frag_page()

  end

