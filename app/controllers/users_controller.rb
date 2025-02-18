class UsersController < ApplicationController
  require 'google/apis/drive_v3'

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
      return unless @user.google_token

      service = GoogleDriveService.new(@user)
      
      # フォルダを作成
      folder_name = "#{@user.email}_files"
      folder_id = service.create_folder(folder_name)
      
      # フォルダIDを保存
      @user.update!(google_drive_folder_id: folder_id)
      
      # デフォルトアイコンをアップロード
      default_icon_path = Rails.root.join('public', 'default_icon.png')
      service.upload_file(default_icon_path, folder_id)
      
      flash[:notice] = 'Googleドライブの設定が完了しました'
      redirect_to edit_user_path(@user)
    rescue Google::Apis::Error => e
      flash[:alert] = 'Googleドライブの設定に失敗しました: ' + e.message
      redirect_to edit_user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:username, :icon, :profile, :password, :password_confirmation)
  end
end