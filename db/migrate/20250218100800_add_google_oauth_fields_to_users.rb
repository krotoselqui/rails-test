class AddGoogleOauthFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :google_token, :string
    add_column :users, :google_refresh_token, :string
    add_column :users, :google_drive_folder_id, :string
  end
end