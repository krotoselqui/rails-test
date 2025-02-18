Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
             scope: 'email, profile, https://www.googleapis.com/auth/drive.file',
             access_type: 'offline'
end
  