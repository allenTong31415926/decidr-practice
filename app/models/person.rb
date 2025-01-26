# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  first_name :string           not null
#  last_name  :string
#  species    :string
#  gender     :string
#  weapon     :string
#  vehicle    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
