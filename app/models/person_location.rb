# == Schema Information
#
# Table name: person_locations
#
#  id          :integer          not null, primary key
#  person_id   :integer          not null
#  location_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_person_locations_on_location_id  (location_id)
#  index_person_locations_on_person_id    (person_id)
#

class PersonLocation < ApplicationRecord
  belongs_to :person
  belongs_to :location
end
