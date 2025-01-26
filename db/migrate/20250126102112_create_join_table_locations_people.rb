class CreateJoinTableLocationsPeople < ActiveRecord::Migration[8.0]
  def change
    create_join_table :locations, :people do |t|
      t.index :location_id
      t.index :person_id
    end
  end
end
