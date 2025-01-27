Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']

  # Enable in all environments except test and development
#   config.enabled = false if Rails.env.test? || Rails.env.development?
#   config.enabled = true if Rails.env.test? || Rails.env.development?
  config.enabled = true

  # By default, Rollbar will try to call the `current_user` method
  # to fetch the logged-in user object, and then call that object's `id`
  # method to get the user ID. If you don't want Rollbar to try to
  # infer the user, uncomment the following:
  # config.person_method = nil

  # Add custom data to your exception reports
  config.custom_data_method = lambda { |message, exception, context|
    {
      environment: Rails.env,
      current_user: context[:current_user]&.id
    }
  }
end