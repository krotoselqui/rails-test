class UsersController < ApplicationController
  require 'google/apis/drive_v3'
  skip_before_action :verify_authenticity_token, only: [:setup_google_drive]

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = 'プロフィールを更新しました'
      redirect_to edit_user_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def setup_google_drive
    @user = User.find(params[:id])
    
    # 権限チェック
    unless @user == current_user
      flash[:alert] = '権限がありません'
      redirect_to root_path
      return
    end

    # Google認証チェック
    unless @user.google_token
      flash[:alert] = 'Googleアカウントとの連携が必要です'
      redirect_to root_path
      return
    end

    begin
      User.transaction do
        service = GoogleDriveService.new(@user)
        
        # フォルダを作成
        folder_name = "#{@user.email}_files"
        folder_id = service.create_folder(folder_name)
        
        # フォルダIDを保存
        @user.update!(google_drive_folder_id: folder_id)
        
        # デフォルトアイコンをアップロード
        default_icon_path = Rails.root.join('public', 'default_icon.png')
        unless File.exist?(default_icon_path)
          raise "デフォルトアイコンファイルが見つかりません"
        end
        
        service.upload_file(default_icon_path, folder_id)
        
        flash[:notice] = "Googleドライブにフォルダ「#{folder_name}」を作成し、デフォルトアイコンをアップロードしました"
      end
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "認証エラー: #{e.message}"
      flash[:alert] = 'Googleアカウントの認証に失敗しました。再度連携を行ってください。'
    rescue Google::Apis::Error => e
      Rails.logger.error "Google Drive API error: #{e.message}"
      flash[:alert] = 'Googleドライブへのアクセスに失敗しました: ' + e.message
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "データベースエラー: #{e.message}"
      flash[:alert] = 'データの保存に失敗しました: ' + e.message
    rescue StandardError => e
      Rails.logger.error "予期せぬエラー: #{e.class.name} - #{e.message}"
      flash[:alert] = '予期せぬエラーが発生しました。しばらく時間をおいて再度お試しください。'
    ensure
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :icon, :profile, :password, :password_confirmation)
  end
end