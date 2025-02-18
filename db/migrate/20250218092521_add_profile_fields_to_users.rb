class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :username, :string
    add_column :users, :icon, :string
    add_column :users, :profile, :text
    add_index :users, :username, unique: true

    # 既存のユーザーにデフォルト値を設定
    User.reset_column_information
    User.find_each do |user|
      user.update_columns(
        username: "user_#{SecureRandom.hex(4)}",
        icon: "/default_icon.png",
        profile: "initial_profile"
      )
    end
  end

  def down
    remove_index :users, :username
    remove_column :users, :username
    remove_column :users, :icon
    remove_column :users, :profile
  end
end
