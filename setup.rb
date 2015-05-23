require 'rubygems'
require 'bundler'

Bundler.require

require './spider'

Dotenv.load

$redis = Redis.new
