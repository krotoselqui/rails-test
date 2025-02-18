# OmniAuthの設定
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true

Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
             scope: 'email, profile, https://www.googleapis.com/auth/drive.file',
             access_type: 'offline',
             prompt: 'consent'
end
  