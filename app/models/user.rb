class User < ApplicationRecord
  has_secure_password

  # メールアドレスのバリデーション
  validates :email, presence: { message: 'を入力してください' },
                   uniqueness: { case_sensitive: false, message: 'は既に使用されています' },
                   format: { with: URI::MailTo::EMAIL_REGEXP, message: 'の形式が正しくありません' }

  # パスワードのバリデーション
  validates :password, presence: { message: 'を入力してください' },
                      length: { minimum: 6, message: 'は6文字以上で入力してください' },
                      allow_nil: true

  # パスワード確認のバリデーション
  validates :password_confirmation, presence: { message: 'を入力してください' }

  # コールバック
  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
