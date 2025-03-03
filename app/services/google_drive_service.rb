require 'google/apis/drive_v3'

class GoogleDriveService
  def initialize(user)
    @user = user
    @drive = Google::Apis::DriveV3::DriveService.new
    @drive.authorization = authenticate_token
    @drive.client_options.application_name = 'AquaRidz'
  end

  def create_folder(name)
    file_metadata = {
      name: name,
      mime_type: 'application/vnd.google-apps.folder'
    }

    file = @drive.create_file(file_metadata, fields: 'id')
    file.id
  end

  def list_files(folder_id)
    begin
      query = "'#{folder_id}' in parents and trashed=false"
      response = @drive.list_files(
        q: query,
        fields: 'files(id, name, mimeType, createdTime, modifiedTime, size)',
        order_by: 'modifiedTime desc',
        page_size: 100
      )
      response.files || []
    rescue Google::Apis::ClientError => e
      Rails.logger.error "Google Drive API error: #{e.message}"
      []
    end
  end

  def upload_file(file_path, parent_folder_id, original_filename = nil)
    require 'marcel'

    # ファイルの読み込みとMIMEタイプの検出
    file = File.open(file_path)
    content_type = Marcel::MimeType.for(file)
    file.close

    file_metadata = {
      name: original_filename || File.basename(file_path),
      parents: [parent_folder_id]
    }

    @drive.create_file(
      file_metadata,
      upload_source: file_path,
      content_type: content_type || 'application/octet-stream',
      fields: 'id'
    )
  end

  private

  def authenticate_token
    raise Google::Apis::AuthorizationError, 'トークンが設定されていません' if @user.google_token.blank?

    client = OAuth2::Client.new(
      ENV['GOOGLE_CLIENT_ID'],
      ENV['GOOGLE_CLIENT_SECRET'],
      authorize_url: 'https://accounts.google.com/o/oauth2/auth',
      token_url: 'https://oauth2.googleapis.com/token'
    )

    begin
      credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        scope: [
          'https://www.googleapis.com/auth/drive.file',
          'email',
          'profile'
        ],
        access_token: @user.google_token,
        refresh_token: @user.google_refresh_token,
        expiration_time_millis: Time.current.to_i * 1000
      )

      if credentials.expired?
        Rails.logger.info "トークンの有効期限が切れています。更新を試みます..."
        begin
          credentials.fetch_access_token!
          @user.update!(
            google_token: credentials.access_token,
            google_refresh_token: credentials.refresh_token
          )
          Rails.logger.info "トークンを更新しました"
        rescue Google::Apis::AuthorizationError => e
          Rails.logger.error "トークン更新エラー: #{e.message}"
          raise
        end
      end

      credentials
    rescue OAuth2::Error => e
      Rails.logger.error "認証エラー: #{e.message}"
      raise Google::Apis::AuthorizationError, "認証に失敗しました: #{e.message}"
    rescue => e
      Rails.logger.error "予期せぬエラー: #{e.message}"
      raise Google::Apis::AuthorizationError, "認証処理でエラーが発生しました: #{e.message}"
    end
  end
end