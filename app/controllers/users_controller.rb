class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :set_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'アカウントを作成しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @user == current_user
      redirect_to root_path, alert: '他のユーザーの情報は編集できません'
    end
  end

  def update
    unless @user == current_user
      redirect_to root_path, alert: '他のユーザーの情報は編集できません'
      return
    end

    # パラメータの準備
    update_params = user_params.to_h
    
    # パスワード関連のパラメータを条件付きで削除
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end

    # デバッグ情報
    Rails.logger.debug "Update params: #{update_params.except('password', 'password_confirmation')}"

    if @user.update(update_params)
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'プロフィールを更新しました' }
        format.turbo_stream { redirect_to root_path, notice: 'プロフィールを更新しました' }
      end
    else
      Rails.logger.debug "Validation errors: #{@user.errors.full_messages}"
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username, :icon, :profile)
  end
end