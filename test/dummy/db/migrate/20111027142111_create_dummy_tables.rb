class CreateDummyTables < ActiveRecord::Migration
  def change
    create_table :dummy_tables do |t|
      t.string :field1
      t.integer :field2
      t.integer :dummy_user_id

      t.timestamps
    end
  end
end
