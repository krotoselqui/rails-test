class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    redirect_to firestore_index_path if user_signed_in?
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      reset_session # セキュリティのためセッションをリセット
      session[:user_id] = user.id
      Rails.logger.info "Login successful for user: #{user.email} (ID: #{user.id})"
      redirect_to firestore_index_path, notice: 'ログインしました。'
    else
      Rails.logger.warn "Login failed for email: #{params[:email]}"
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません。'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: 'ログアウトしました。'
  end
end