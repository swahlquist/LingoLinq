Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/v1/public/*',
      headers: :any,
      methods: [:get, :options]
  end

  allow do
    origins ENV['DEFAULT_HOST']
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :delete, :options],
      credentials: true
  end
end
