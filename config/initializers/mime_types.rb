# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# JavaScriptモジュールのMIME type設定
Mime::Type.register "text/javascript", :js, %w(application/javascript application/x-javascript)
Mime::Type.register "text/css", :css