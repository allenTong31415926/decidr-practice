class Person < ApplicationRecord
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :affiliations

  validates :first_name, presence: true
  validates :affiliations, presence: true

  before_save :titleize_name

  def titleize_name
    self.first_name = first_name.titleize
    self.last_name = last_name&.titleize
  end
end
