class ChangeGenderToEnumInPeople < ActiveRecord::Migration[8.0]
  def change
    change_column :people, :gender, :integer, using: 'gender::integer', null: true
  end
end
