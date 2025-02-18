require 'google/apis/drive_v3'

class GoogleDriveService
  def initialize(user)
    @user = user
    @drive = Google::Apis::DriveV3::DriveService.new
    @drive.authorization = auth_client
  end

  def create_folder(name)
    file_metadata = {
      name: name,
      mime_type: 'application/vnd.google-apps.folder'
    }

    file = @drive.create_file(file_metadata, fields: 'id')
    file.id
  end

  def upload_file(file_path, parent_folder_id)
    file_metadata = {
      name: File.basename(file_path),
      parents: [parent_folder_id]
    }

    @drive.create_file(
      file_metadata,
      upload_source: file_path,
      content_type: 'image/png',
      fields: 'id'
    )
  end

  private

  def auth_client
    client = OAuth2::Client.new(
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLE_CLIENT_SECRET'],
      authorize_url: 'https://accounts.google.com/o/oauth2/auth',
      token_url: 'https://oauth2.googleapis.com/token'
    )

    OAuth2::AccessToken.new(
      client,
      @user.google_token,
      refresh_token: @user.google_refresh_token
    )
  end
end