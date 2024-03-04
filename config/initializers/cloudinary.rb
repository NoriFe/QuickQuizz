# config/initializers/cloudinary.rb

Cloudinary.config do |config|
  config.cloud_name = ENV.fetch('CLOUD_NAME')
  config.api_key = ENV.fetch('API_KEY')
  config.api_secret = ENV.fetch('API_SECRET')
  config.secure = true # Optional: Use HTTPS for secure connections
end
