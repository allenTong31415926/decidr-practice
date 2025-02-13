# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  first_name :string           not null
#  last_name  :string
#  species    :string
#  gender     :integer
#  weapon     :string
#  vehicle    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ApplicationRecord
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :affiliations

  enum :gender, { Male: 0, Female: 1, Other: 2 }

  validates :first_name, presence: true
  validates :affiliations, presence: true
  validates :gender, inclusion: { in: genders.keys }, allow_nil: true

  before_save :titleize_name

  def titleize_name
    self.first_name = if first_name.include?("-")
      # Capitalize first letter if it's lowercase, leave rest unchanged
      first_name[0].upcase + first_name[1..]
    else
      first_name.titleize
    end
    self.last_name = last_name&.titleize
  end
end
