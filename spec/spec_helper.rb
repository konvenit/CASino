ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"] == "true"
  require "simplecov"
  SimpleCov.start
end

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'rspec/its'
require 'webmock/rspec'
require 'ostruct'
require 'capybara/rails'

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb')].each {|f| require f }

RSpec.configure do |config|
  config.before(:each) do
    stub_const("Person", Class.new)
    allow(Person).to receive(:find).and_return(OpenStruct.new(employee?: true, allow_2fa_auth?: false))
  end
end