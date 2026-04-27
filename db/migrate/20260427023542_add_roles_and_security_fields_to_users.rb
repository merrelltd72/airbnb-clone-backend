class AddRolesAndSecurityFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :reset_password_token_digest, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :failed_attempts, :integer, null: false, default: 0
    add_column :users, :locked_at, :datetime
    add_column :users, :last_login_at, :datetime

    # Case-insensitive unique email index (replaces the implicit uniqueness from model validation)
    add_index :users, "LOWER(email)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :role
    add_index :users, :reset_password_token_digest
  end
end
