class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :google_oauth2_callback]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = 'ログインしました'
      redirect_back_or root_path
    else
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = 'ログアウトしました'
    redirect_to root_path
  end

  def google_oauth2_callback
    auth = request.env['omniauth.auth']
    
    if current_user
      # 既存ユーザーとGoogle認証を連携
      update_google_credentials(current_user, auth)
      flash[:notice] = 'Googleアカウントと連携しました'
      redirect_to edit_user_path(current_user)
    else
      # Google認証情報に基づいて既存ユーザーを探すか新規作成
      user = find_or_create_user_from_google(auth)
      session[:user_id] = user.id
      flash[:notice] = 'ログインしました'
      redirect_to edit_user_path(user)
    end
  rescue => e
    flash[:alert] = '連携に失敗しました: ' + e.message
    redirect_to root_path
  end

  private

  def update_google_credentials(user, auth)
    user.update!(
      google_email: auth.info.email,
      google_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token
    )
  end

  def find_or_create_user_from_google(auth)
    User.find_by(google_email: auth.info.email) || create_user_from_google(auth)
  end

  def create_user_from_google(auth)
    User.create!(
      email: SecureRandom.uuid + '@example.com', # 一時的なメールアドレス
      username: auth.info.name,
      password: SecureRandom.urlsafe_base64,
      password_confirmation: SecureRandom.urlsafe_base64,
      google_email: auth.info.email,
      google_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token
    )
  end
end