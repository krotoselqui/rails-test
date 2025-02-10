class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ログインユーザーのみアクセスを許可
  before_action :authenticate_user!
  helper_method :current_user, :user_signed_in?

  private

  def authenticate_user!
    unless user_signed_in?
      Rails.logger.debug "認証が必要: ユーザーは未ログイン状態です"
      Rails.logger.debug "現在のパス: #{request.path}"
      Rails.logger.debug "セッションID: #{session.id}"
      store_location
      flash[:alert] = 'ログインが必要です。'
      redirect_to login_path
    end
  end

  def current_user
    return @current_user if defined?(@current_user)
    if session[:user_id]
      Rails.logger.debug "セッションからユーザーIDを取得: #{session[:user_id]}"
      @current_user = User.find_by(id: session[:user_id])
      unless @current_user
        Rails.logger.warn "セッションにユーザーIDがありますが、対応するユーザーが見つかりません: #{session[:user_id]}"
        session.delete(:user_id)
      end
    end
    @current_user
  end

  def user_signed_in?
    current_user.present?
  end

  def store_location
    session[:return_to] = request.fullpath if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end
end
