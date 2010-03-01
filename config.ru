require 'twicket.rb'

set :environment, :production
set :run, false

run Sinatra::Application

# log = File.new(File.dirname(__FILE__) + "/log/sinatra.log", "a")
# STDOUT.reopen(log)
# STDERR.reopen(log)
