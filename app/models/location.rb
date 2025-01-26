# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_locations_on_name  (name) UNIQUE
#

class Location < ApplicationRecord
  has_and_belongs_to_many :people

  validates :name, presence: true, uniqueness: true
end
