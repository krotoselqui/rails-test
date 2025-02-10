class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    Rails.logger.debug "Creating user with params: #{user_params.except('password', 'password_confirmation')}"
    
    if @user.save
      Rails.logger.info "User created successfully: #{@user.email}"
      session[:user_id] = @user.id
      redirect_to firestore_index_path, notice: 'アカウントを作成しました。'
    else
      Rails.logger.warn "User creation failed: #{@user.errors.full_messages}"
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error creating user: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:alert] = "アカウントの作成に失敗しました。"
    render :new, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end