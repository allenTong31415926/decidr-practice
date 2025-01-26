# == Schema Information
#
# Table name: affiliations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_affiliations_on_name  (name) UNIQUE
#

class Affiliation < ApplicationRecord
  has_and_belongs_to_many :people

  validates :name, presence: true, uniqueness: true
end
