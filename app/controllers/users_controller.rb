class UsersController < ApplicationController
  require 'google/apis/drive_v3'
  skip_before_action :verify_authenticity_token, only: [:create_google_drive_folder, :upload_to_google_drive]

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

  def google_drive
    @user = User.find(params[:id])
    unless @user == current_user
      flash[:alert] = '権限がありません'
      redirect_to root_path
      return
    end

    unless @user.google_token
      flash[:alert] = 'Googleアカウントとの連携が必要です'
      redirect_to edit_user_path(@user)
      return
    end

    if @user.google_drive_folder_id
      begin
        service = GoogleDriveService.new(@user)
        @files = service.list_files(@user.google_drive_folder_id)
      rescue => e
        flash.now[:alert] = "ファイル一覧の取得に失敗しました: #{e.message}"
        @files = []
      end
    end
  end

  def create_google_drive_folder
    @user = User.find(params[:id])
    
    unless @user == current_user
      flash[:alert] = '権限がありません'
      redirect_to root_path
      return
    end

    unless @user.google_token
      flash[:alert] = 'Googleアカウントとの連携が必要です'
      redirect_to edit_user_path(@user)
      return
    end

    begin
      service = GoogleDriveService.new(@user)
      folder_name = "#{@user.email}_files"
      folder_id = service.create_folder(folder_name)
      @user.update!(google_drive_folder_id: folder_id)
      flash[:notice] = "Googleドライブにフォルダ「#{folder_name}」を作成しました"
    rescue => e
      flash[:alert] = "フォルダの作成に失敗しました: #{e.message}"
    end

    redirect_to google_drive_user_path(@user)
  end

  def upload_to_google_drive
    @user = User.find(params[:id])
    
    unless @user == current_user
      flash[:alert] = '権限がありません'
      redirect_to root_path
      return
    end

    unless @user.google_drive_folder_id
      flash[:alert] = 'まずGoogleドライブフォルダを作成してください'
      redirect_to google_drive_user_path(@user)
      return
    end

    begin
      file = params[:file]
      if file
        service = GoogleDriveService.new(@user)
        service.upload_file(
          file.path,
          @user.google_drive_folder_id,
          file.original_filename
        )
        flash[:notice] = "ファイル「#{file.original_filename}」をアップロードしました"
      else
        flash[:alert] = 'ファイルを選択してください'
      end
    rescue => e
      flash[:alert] = "アップロードに失敗しました: #{e.message}"
    end

    redirect_to google_drive_user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:username, :icon, :profile, :password, :password_confirmation)
  end
end