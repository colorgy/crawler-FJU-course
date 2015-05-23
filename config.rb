require 'rubygems'
require 'bundler'

Bundler.require
Dotenv.load

require './spider'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end
