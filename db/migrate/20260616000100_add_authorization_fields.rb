class AddAuthorizationFields < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :archived_at, :datetime
    add_index :organizations, :archived_at

    add_column :users, :archived_at, :datetime
    add_index :users, :archived_at

    add_reference :companies, :created_by, foreign_key: { to_table: :users }
    add_reference :contacts, :created_by, foreign_key: { to_table: :users }
    add_reference :business_cards, :created_by, foreign_key: { to_table: :users }

    create_table :system_settings do |t|
      t.string :key, null: false
      t.text :value
      t.timestamps
    end
    add_index :system_settings, :key, unique: true
  end
end
