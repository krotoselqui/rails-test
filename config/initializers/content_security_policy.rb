# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    asset_host = "https://aquaridz.com"
    
    policy.default_src :self, asset_host
    policy.font_src    :self, asset_host, :data
    policy.img_src     :self, asset_host, :data,
                       'https://drive.google.com',
                       'https://drive-thirdparty.googleusercontent.com',
                       'https://*.googleusercontent.com',
                       'https://*.usercontent.google.com',
                       'https://lh3.googleusercontent.com',
                       'https://work.fife.usercontent.google.com',
                       'https://drive.google.com/uc'
    policy.object_src  :none
    policy.script_src  :self, asset_host, :unsafe_eval
    policy.style_src   :self, asset_host
    policy.connect_src :self, asset_host

    # 開発環境特有の設定
    if Rails.env.development?
      policy.connect_src :self, "ws://localhost:*", "ws://127.0.0.1:*"
      policy.script_src :self, :unsafe_eval, :unsafe_inline
      policy.style_src :self, :unsafe_inline
    end
  end

  # レポートモードを一時的に無効化して、実際のブロックを確認
  config.content_security_policy_report_only = false

  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(style-src script-src)
end
