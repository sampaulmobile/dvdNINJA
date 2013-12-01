class Actor < ActiveRecord::Base

  has_many :castings
  has_many :movies, through: :castings

  validates_uniqueness_of :first_name, :scope => :last_name, :case_sensitive => false
end
