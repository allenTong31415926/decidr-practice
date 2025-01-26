class CreateJoinTableAffiliationsPeople < ActiveRecord::Migration[8.0]
  def change
    create_join_table :affiliations, :people do |t|
      t.index :affiliation_id
      t.index :person_id
    end
  end
end
