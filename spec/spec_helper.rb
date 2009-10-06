__DIR__ = File.dirname __FILE__
$LOAD_PATH.unshift __DIR__ + '/../lib'

require 'resource_potato'
require 'rubygems'

require 'couch_potato'
require 'action_controller'

gem 'rspec'
gem 'rspec-rails'
module Rails
  module VERSION
    STRING = '2.3.4'
  end
end
require 'spec/rails'

require __DIR__ + '/../rails/init'
