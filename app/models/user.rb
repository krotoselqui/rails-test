class User < ApplicationRecord
  has_secure_password validations: false  # パスワードのバリデーションを個別に制御

  # メールアドレスのバリデーション
  validates :email, presence: { message: 'を入力してください' },
                   uniqueness: { case_sensitive: false, message: 'は既に使用されています' },
                   format: { with: URI::MailTo::EMAIL_REGEXP, message: 'の形式が正しくありません' }

  # パスワードのバリデーション（新規作成時と変更時のみ）
  validates :password, presence: { message: 'を入力してください' }, on: :create
  validates :password, length: { minimum: 6, message: 'は6文字以上で入力してください' },
                      confirmation: true,
                      if: -> { password.present? }

  # パスワード確認のバリデーション（パスワードが入力されている場合のみ）
  validates :password_confirmation, presence: { message: 'を入力してください' },
                                  if: -> { password.present? }

  # ユーザー名のバリデーション
  validates :username, presence: { message: 'を入力してください' },
                      uniqueness: { message: 'は既に使用されています' },
                      length: { maximum: 50, message: 'は50文字以内で入力してください' }

  # プロフィールのバリデーション
  validates :profile, length: { maximum: 1000, message: 'は1000文字以内で入力してください' }

  # コールバック
  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
