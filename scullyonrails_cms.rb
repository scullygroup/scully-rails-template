# CMS rails template
#
# This loads the base rails template and also sets-up the following:
# CMS using comatose-engine
# User authentication using AuthLogic
#

load_template "/Users/bcalloway/RUBY/scully-rails-template/scullyonrails.rb"

plugin 'comatose_engine', :git => "git://github.com/bcalloway/comatose-engine.git"

gem 'rubyist-aasm'
gem 'binarylogic-authlogic'
generate :auth #TODO write generator that sets up all user auth in controllers, etc

#TODO user auth methods, sessions, filter_parameter_logging if User Auth is going here
#file 'app/controllers/application_controller.rb'

# Appending to environment.rb
# env = IO.read ‘config/environment.rb’
# 
# ins = <<-ENDOFTEXT
# # blah, blah, blah
# ENDOFTEXT
# 
# env.gsub!(/^end$/, "#{ins}end") unless env.include?(ins)
# File.open(‘config/environment.rb’, ‘w’) do |env_out|
#   env_out.write(env)
# end