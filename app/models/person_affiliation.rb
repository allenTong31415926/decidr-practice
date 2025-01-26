# == Schema Information
#
# Table name: person_affiliations
#
#  id             :integer          not null, primary key
#  person_id      :integer          not null
#  affiliation_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_person_affiliations_on_affiliation_id  (affiliation_id)
#  index_person_affiliations_on_person_id       (person_id)
#

class PersonAffiliation < ApplicationRecord
  belongs_to :person
  belongs_to :affiliation
end
