class CreateVaultCore < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :users do |t|
      t.references :organization, null: true, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "member"
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :role

    create_table :companies do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :website
      t.string :phone
      t.text :address
      t.text :description
      t.datetime :archived_at
      t.timestamps
    end
    add_index :companies, [ :organization_id, :name ]
    add_index :companies, :archived_at

    create_table :contacts do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :company, null: true, foreign_key: true
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :position
      t.text :memo
      t.datetime :archived_at
      t.timestamps
    end
    add_index :contacts, [ :organization_id, :email ]
    add_index :contacts, [ :organization_id, :name ]
    add_index :contacts, :archived_at

    create_table :business_cards do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.string :label
      t.datetime :archived_at
      t.timestamps
    end
    add_index :business_cards, :archived_at

    create_table :contact_notes do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :visibility, null: false, default: "shared"
      t.text :body, null: false
      t.datetime :archived_at
      t.timestamps
    end
    add_index :contact_notes, [ :organization_id, :visibility ]
    add_index :contact_notes, :archived_at
  end
end
