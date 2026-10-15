require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require "test/unit/rr"

$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))

require "fluent/test"
require "fluent/test/driver/output"
require "fluent/test/helpers"

require 'fluent/plugin/in_gcloud_pubsub'
require 'fluent/plugin/out_gcloud_pubsub'

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)
