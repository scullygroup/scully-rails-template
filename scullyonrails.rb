# Scully Group Rails Template
# http://scullytown.com
#
# based on Suspenders by Thoughtbot
#
# This adds a few more gems/plugins as noted below
# Also, additional HAML and SASS support is added

#====================
# PLUGINS
#====================

plugin 'hoptoad_notifier', :git => "git://github.com/thoughtbot/hoptoad_notifier.git"
plugin 'limerick_rake', :git => "git://github.com/thoughtbot/limerick_rake.git"
plugin 'jrails', :svn => "http://ennerchi.googlecode.com/svn/trunk/plugins/jrails"
plugin 'admin_data', :git => "git://github.com/neerajdotname/admin_data.git"
plugin 'engines', :git => "git://github.com/lazyatom/engines.git"

#====================
# GEMS
#====================

gem 'RedCloth', :lib => 'redcloth'
gem 'will_paginate', :lib => 'will_paginate', :source => 'http://gemcutter.org'
gem 'mocha'
gem 'factory_girl',:lib => 'factory_girl', :source => 'http://gemcutter.org'
gem 'shoulda', :lib => 'shoulda', :source => 'http://gemcutter.org'
gem 'paperclip', :lib => 'paperclip', :source => 'http://gemcutter.org'
gem 'newrelic_rpm', :source => 'http://gemcutter.org'
gem 'haml', :source => 'http://gemcutter.org'
gem 'justinfrench-formtastic', :lib => 'formtastic', :source => 'http://gems.github.com'
gem 'rubyist-aasm', :lib => 'aasm', :source => 'http://gems.github.com'
gem 'authlogic', :lib => 'authlogic', :source => 'http://gemcutter.org'
gem 'searchlogic', :lib => 'searchlogic', :source => 'http://gemcutter.org'

#TODO create email validation and password recovery
#TODO setup mailers and observers for user auth
#TODO setup Roles and integrate with comatose_engine

#freeze!
rake("gems:install", :sudo => true)
rake("gems:unpack")
rake("gems:build")

#====================
# Generators
#====================
generate(:session, "user_session")
generate(:controller, "user_sessions")

generate(:model, "user", "login:string", "email:string", "crypted_password:string", "password_salt:string", "persistence_token:string", "single_access_token:string", "perishable_token:string", "login_count:integer", "failed_login_count:integer", "last_request_at:datetime", "current_login_at:datetime", "last_login_at:datetime", "current_login_ip:string", "last_login_ip:string")
generate(:controller, "users")

#====================
# APP
#====================

file 'app/controllers/application_controller.rb',
%q{class ApplicationController < ActionController::Base

  helper :all

  protect_from_forgery

  include HoptoadNotifier::Catcher

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user
  
  before_filter :start_session
  
  def start_session
    unless session[:user_random]
  		session[:user_random] = rand(99999999)
  	end
  end
  
  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      flash[:error] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  # def require_no_user
  #   if current_user
  #     store_location
  #     flash[:error] = "You must be logged out to access this page"
  #     redirect_to account_url
  #     return false
  #   end
  # end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
end
}

file 'app/helpers/application_helper.rb', 
%q{module ApplicationHelper
  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end
end
}

#====================
# INITIALIZERS
#====================

# Because the formtastic generator is not working for some reason
initializer 'formtastic.rb',
%q{# Set the default text field size when input is a string. Default is 50.
# Formtastic::SemanticFormBuilder.default_text_field_size = 50

# Should all fields be considered "required" by default?
# Defaults to true, see ValidationReflection notes below.
# Formtastic::SemanticFormBuilder.all_fields_required_by_default = true

# Should select fields have a blank option/prompt by default?
# Defaults to true.
# Formtastic::SemanticFormBuilder.include_blank_for_select_by_default = true

# Set the string that will be appended to the labels/fieldsets which are required
# It accepts string or procs and the default is a localized version of
# '<abbr title="required">*</abbr>'. In other words, if you configure formtastic.required
# in your locale, it will replace the abbr title properly. But if you don't want to use
# abbr tag, you can simply give a string as below
# Formtastic::SemanticFormBuilder.required_string = "(required)"

# Set the string that will be appended to the labels/fieldsets which are optional
# Defaults to an empty string ("") and also accepts procs (see required_string above)
# Formtastic::SemanticFormBuilder.optional_string = "(optional)"

# Set the way inline errors will be displayed.
# Defaults to :sentence, valid options are :sentence, :list and :none
Formtastic::SemanticFormBuilder.inline_errors = :list

# Set the method to call on label text to transform or format it for human-friendly
# reading when formtastic is user without object. Defaults to :humanize.
# Formtastic::SemanticFormBuilder.label_str_method = :humanize

# Set the array of methods to try calling on parent objects in :select and :radio inputs
# for the text inside each @<option>@ tag or alongside each radio @<input>@. The first method
# that is found on the object will be used.
# Defaults to ["to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]
# Formtastic::SemanticFormBuilder.collection_label_methods = [
#   "to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]

# Formtastic by default renders inside li tags the input, hints and then
# errors messages. Sometimes you want the hints to be rendered first than
# the input, in the following order: hints, input and errors. You can
# customize it doing just as below:
Formtastic::SemanticFormBuilder.inline_order = [:input, :hints, :errors]

# Specifies if labels/hints for input fields automatically be looked up using I18n.
# Default value: false. Overridden for specific fields by setting value to true,
# i.e. :label => true, or :hint => true (or opposite depending on initialized value)
# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false
}

initializer 'action_mailer_configs.rb', 
%q{require 'smtp_tls'
ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => "smtp.gmail.com" ,
  :port => 587,
  :domain => "scullytown.com" ,
  :authentication => :plain,
  :user_name => "admin@scullytown.com",
  :password => "XXXXXXXXX"
}
}

initializer 'errors.rb', 
%q{# Example:
#   begin
#     some http call
#   rescue *HTTP_ERRORS => error
#     notify_hoptoad error
#   end

HTTP_ERRORS = [Timeout::Error,
               Errno::EINVAL,
               Errno::ECONNRESET,
               EOFError,
               Net::HTTPBadResponse,
               Net::HTTPHeaderSyntaxError,
               Net::ProtocolError]

SMTP_SERVER_ERRORS = [TimeoutError,
                      IOError,
                      Net::SMTPUnknownError,
                      Net::SMTPServerBusy,
                      Net::SMTPAuthenticationError]

SMTP_CLIENT_ERRORS = [Net::SMTPFatalError,
                      Net::SMTPSyntaxError]

SMTP_ERRORS = SMTP_SERVER_ERRORS + SMTP_CLIENT_ERRORS
}


initializer 'hoptoad.rb', 
%q{HoptoadNotifier.configure do |config|
  config.api_key = 'HOPTOAD-KEY'
end
}

initializer 'mocks.rb', 
%q{# Rails 2 doesn't like mocks

# This callback will run before every request to a mock in development mode, 
# or before the first server request in production. 

Rails.configuration.to_prepare do
  Dir[File.join(RAILS_ROOT, 'test', 'mocks', RAILS_ENV, '*.rb')].each do |f|
    load f
  end
end
}

initializer 'requires.rb', 
%q{require 'redcloth'

Dir[File.join(RAILS_ROOT, 'lib', 'extensions', '*.rb')].each do |f|
  require f
end

Dir[File.join(RAILS_ROOT, 'lib', '*.rb')].each do |f|
  require f
end
}

initializer 'time_formats.rb', 
%q{# Example time formats
{ :short_date => "%x", :long_date => "%a, %b %d, %Y" }.each do |k, v|
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(k => v)
end
}

# ====================
# CONFIG
# ====================

capify!

file 'config/environment.rb', 
%q{# Be sure to restart your server when you modify this file

PROJECT_NAME = "CHANGEME"

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  
  config.plugins = [:engines, :comatose_engine, :all]
  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/comatose_engine/engine_plugins"]
  
  # Settings in config/environments/* take precedence over those specified here.

  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  config.gem 'RedCloth',
             :lib => 'redcloth' 
  config.gem 'will_paginate', 
             :lib => 'will_paginate', 
             :source => 'http://gemcutter.org'
  config.gem 'mocha'
  config.gem 'factory_girl', 
             :lib => 'factory_girl', 
             :source => 'http://gemcutter.org'
  config.gem 'shoulda', 
             :lib => 'shoulda', 
             :source => 'http://gemcutter.org'
  config.gem 'newrelic_rpm',
             :source => 'http://gemcutter.org'
  config.gem 'haml',
             :source => 'http://gemcutter.org'
  config.gem 'paperclip', 
             :lib => 'paperclip', 
             :source => 'http://gemcutter.org'
  config.gem 'justinfrench-formtastic',
             :lib => 'formtastic', 
             :source => 'http://gems.github.com'             
  config.gem 'rubyist-aasm', 
             :lib => 'aasm',
             :source => 'http://gems.github.com'
  config.gem 'authlogic',
             :lib => 'authlogic',
             :source => 'http://gemcutter.org'
  config.gem 'searchlogic',
             :lib => 'searchlogic',
             :source => 'http://gemcutter.org'
             
  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
  # Add the vendor/gems/*/lib directories to the LOAD_PATH
  config.load_paths += Dir.glob(File.join(RAILS_ROOT, 'vendor', 'gems', '*', 'lib'))

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  SESSION_KEY = "CHANGESESSION" 
  config.action_controller.session = {
    :session_key => "_#{PROJECT_NAME}_session",
    :secret      => SESSION_KEY
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end

Comatose.configure do |config|

  config.admin_title          = 'Administration'
  config.admin_helpers        = []
  config.admin_sub_title      = 'Administration Pages'
  config.content_type         = 'utf-8'
  config.default_filter       = ''
  config.default_processor    = :erb
  config.default_tree_level   = 3
  config.disable_caching      = true
  config.hidden_meta_fields   = 'filter'
  
  # might want to set these to false at go-live
  #config.allow_import_export  = true
  #config.allow_clear_cache    = true
  #config.allow_add_child      = true
  #config.allow_reordering     = true
  
  #config.helpers << ApplicationHelper

  # Includes AuthenticationSystem in the ComatoseController
  #config.includes << Authlogic::ActsAsAuthentic

  # Calls :login_required as a before_filter
  #config.authorization = :require_user
     
  # Includes AuthenticationSystem in the ComatoseAdminController
  config.admin_includes << Authlogic::ActsAsAuthentic

  # Returns the author name (login, in this case) for the current user
  config.admin_get_author do
    current_user.login
  end

  # Calls :login_required as a before_filterc
  #config.admin_authorization = :login_required
  config.admin_authorization = :require_user
    
  #Returns different admin 'root paths'
  # config.admin_get_root_page do
  #   ComatosePage.find_by_path( '' )
  # end

end

require "#{RAILS_ROOT}/vendor/plugins/comatose_engine/engine_config/boot.rb"
}

file 'Capfile', 
%q{load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'
}

file 'config/database.yml', 
%q{

development:
  adapter: mysql
  database: <%= PROJECT_NAME %>_development
  username: root
  password: 
  host: localhost
  encoding: utf8
  socket: /var/mysql/mysql.sock
    
test:
  adapter: mysql
  database: <%= PROJECT_NAME %>_test
  username: root
  password: 
  host: localhost
  encoding: utf8
  
staging:
  adapter: mysql
  database: <%= PROJECT_NAME %>_staging
  username: <%= PROJECT_NAME %>
  password:
  host: localhost
  encoding: utf8
  socket: /var/run/mysqld/mysqld.sock
  
production:
  adapter: mysql
  database: <%= PROJECT_NAME %>_production
  username: <%= PROJECT_NAME %>
  password:
  host: localhost
  encoding: utf8
  socket: /var/run/mysqld/mysqld.sock
}

file 'config/deploy.rb', 
%q{set :stages, %w(staging prod)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

namespace :deploy do
 [:start, :stop, :restart, :finalize_update, :migrate, :migrations, :cold].each do |t|
   desc "#{t} task is a no-op with mod_rails"
   task t, :roles => :app do ; end
 end
end

namespace :deploy do
  desc "Default deploy - updated to run migrations"
  task :default do
    set :migrate_target, :latest
    update_code
    migrate
    symlink
    restart
  end
  desc "Run this after every successful deployment" 
  task :after_default do
    cleanup
  end
end
}

file 'config/deploy/staging.rb', 
%q{################################################################################################################
# This deploy recipe will deploy a project from a GitHub repo to a Webbynode VPS server
#
# Assumptions:
#   * You are using WebbyNode for hosting, but this would most likely work on any VPS, such as Slicehost
#   * Your deployment directory is located in /home
#   * This is a Rails project and will use the staging environment
#
#################################################################################################################
#
# Change this to the name of the project.  It should match the name of the Git repo.
# This will set the name of the project directory and become the subdomain
set :project, 'MY-PROJECT' 

set :github_user, "USERNAME" # Your GitHub username
set :domain_name, "MYDOMAIN.COM" # should be something like mydomain.com
set :user, 'USERNAME' # Webbynode username
set :domain, 'XXX.XX.XXX.XX' # Webbynode IP address

#### You shouldn't need to change anything below ########################################################
default_run_options[:pty] = true

set :repository,  "git@github.com:#{github_user}/#{project}.git" #GitHub clone URL
set :scm, "git"
set :scm_passphrase, "" # This is the passphrase for the ssh key on the server deployed to
set :branch, "master"
set :scm_verbose, true
set :subdomain, "#{project}.#{domain_name}"
set :applicationdir, "/home/#{project}"

set :keep_releases, 1

# Don't change this stuff, but you may want to set shared files at the end of the file ##################
# deploy config
set :deploy_to, applicationdir
set :deploy_via, :remote_cache
 
# roles (servers)
role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

namespace :webbynode do
  desc "Setup New Project"
  task :setup do
    config_vhost
    apache_reload
  end
  
  desc "Configure VHost"
  task :config_vhost do
    vhost_config =<<-EOF
<VirtualHost *:80>
  ServerName #{subdomain}
  RailsEnv staging
  DocumentRoot #{deploy_to}/current/public
</VirtualHost>
    EOF
    put vhost_config, "src/vhost_config"
    sudo "mv src/vhost_config /etc/apache2/sites-available/#{project}"
    sudo "chown root:root /etc/apache2/sites-available/#{project}"
    sudo "a2ensite #{project}"
    sudo "mkdir /home/#{project}"
    sudo "chown #{user}:#{user} /home/#{project}"
  end
  
  desc "Reload Apache"
  task :apache_reload do
    sudo "/etc/init.d/apache2 reload"
  end
end

# additional settings
#default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys
#set :chmod755, "app config db lib public vendor script script/* public/disp*"
set :use_sudo, false
 
# Optional tasks ##########################################################################################
# for use with shared files (e.g. config files)
# after "deploy:update_code" do
#   run "ln -s #{shared_path}/uploads #{release_path}/public"
# end
}

file 'config/deploy/production.rb', 
%q{################################################################################################################
# This deploy recipe will deploy a project from a GitHub repo to a Webbynode VPS server
#
# Assumptions:
#   * You are using WebbyNode for hosting, but this would most likely work on any VPS, such as Slicehost
#   * Your deployment directory is located in /home
#   * This is a Rails project and will use the production environment
#
#################################################################################################################
#
# Change this to the name of the project.  It should match the name of the Git repo.
# This will set the name of the project directory and become the subdomain
set :project, 'MY-PROJECT' 

set :github_user, "USERNAME" # Your GitHub username
set :user, 'USERNAME' # Webbynode username
set :domain, 'XXX.XX.XXX.XX' # Webbynode IP address

#### You shouldn't need to change anything below ########################################################
default_run_options[:pty] = true

set :repository,  "git@github.com:#{github_user}/#{project}.git" #GitHub clone URL
set :scm, "git"
set :scm_passphrase, "" # This is the passphrase for the ssh key on the server deployed to
set :branch, "master"
set :scm_verbose, true
set :applicationdir, "/home/#{project}"

set :keep_releases, 1

# Don't change this stuff, but you may want to set shared files at the end of the file ##################
# deploy config
set :deploy_to, applicationdir
set :deploy_via, :remote_cache
 
# roles (servers)
role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

# additional settings
#default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys
#set :chmod755, "app config db lib public vendor script script/* public/disp*"
set :use_sudo, false
 
# Optional tasks ##########################################################################################
# for use with shared files (e.g. config files)
# after "deploy:update_code" do
#   run "ln -s #{shared_path}/uploads #{release_path}/public"
# end
}

file 'config/environments/production.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = false
}

file 'config/environments/staging.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# We'd like to stay as close to prod as possible
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Disable delivery errors if you bad email addresses should just be ignored
config.action_mailer.raise_delivery_errors = false

Paperclip.options[:image_magick_path] = '/usr/bin'
}

file 'config/environments/development.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

HOST = 'localhost'
Paperclip.options[:image_magick_path] = '/opt/local/bin'
}

file 'config/environments/test.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

HOST = 'localhost'

require 'factory_girl'
require 'mocha'
begin require 'redgreen'; rescue LoadError; end
}

file 'lib/smtp_tls.rb', 
%q{require "openssl"
require "net/smtp"

Net::SMTP.class_eval do
  private
  def do_start(helodomain, user, secret, authtype)
    raise IOError, 'SMTP session already started' if @started

    # use the ruby 1.8.6 library in development
    if ENV["RAILS_ENV"] == "development" || ENV["RAILS_ENV"] == "test"
      check_auth_args user, secret, authtype if user or secret
    else
      check_auth_args user, secret
    end

    sock = timeout(@open_timeout) { TCPSocket.open(@address, @port) }
    @socket = Net::InternetMessageIO.new(sock)
    @socket.read_timeout = 60 #@read_timeout

    check_response(critical { recv_response() })
    do_helo(helodomain)

    if starttls
      raise 'openssl library not installed' unless defined?(OpenSSL)
      ssl = OpenSSL::SSL::SSLSocket.new(sock)
      ssl.sync_close = true
      ssl.connect
      @socket = Net::InternetMessageIO.new(ssl)
      @socket.read_timeout = 60 #@read_timeout
      do_helo(helodomain)
    end

    authenticate user, secret, authtype if user
    @started = true
  ensure
    unless @started
      # authentication failed, cancel connection.
      @socket.close if not @started and @socket and not @socket.closed?
      @socket = nil
    end
  end

  def do_helo(helodomain)
    begin
      if @esmtp
        ehlo helodomain
      else
        helo helodomain
      end
      rescue Net::ProtocolError
      if @esmtp
        @esmtp = false
        @error_occured = false
        retry
      end
      raise
    end
  end

  def starttls
    getok('STARTTLS') rescue return false
    return true
  end

  def quit
    begin
      getok('QUIT')
      rescue EOFError
    end
  end
end
}

file 'lib/tasks/metric_fu.rake', 
%q{
begin  
    require 'metric_fu'  
  rescue LoadError  
end
}

# ====================
# ROUTES (listed in reverse order)
# ====================
route 'map.comatose_root "", :layout => "application"'
route 'map.comatose_admin "admin"'
route 'map.login "/login", :controller => :user_sessions, :action => :new'
route 'map.logout "/logout", :controller => :user_sessions, :action => :destroy'
route 'map.register "/register", :controller => :users, :action => :new'
route 'map.resources :user_sessions'
route 'map.resources :account, :controller => :user'
route 'map.resources :users'

# ====================
# TEST
# ====================

inside ('test') do
  run "mkdir factories"
end

file 'test/shoulda_macros/forms.rb', 
%q{class Test::Unit::TestCase
  def self.should_have_form(opts)
    model = self.name.gsub(/ControllerTest$/, '').singularize.downcase
    model = model[model.rindex('::')+2..model.size] if model.include?('::')
    http_method, hidden_http_method = form_http_method opts[:method]
    should "have a #{model} form" do
      assert_select "form[action=?][method=#{http_method}]", eval(opts[:action]) do
        if hidden_http_method
          assert_select "input[type=hidden][name=_method][value=#{hidden_http_method}]"
        end
        opts[:fields].each do |attribute, type|
          attribute = attribute.is_a?(Symbol) ? "#{model}[#{attribute.to_s}]" : attribute
          assert_select "input[type=#{type.to_s}][name=?]", attribute
        end
        assert_select "input[type=submit]"
      end
    end
  end

  def self.form_http_method(http_method)
    http_method = http_method.nil? ? 'post' : http_method.to_s
    if http_method == "post" || http_method == "get"
      return http_method, nil
    else
      return "post", http_method
    end
  end  
end
}

file 'test/shoulda_macros/pagination.rb', 
%q{class Test::Unit::TestCase
  # Example:
  #  context "a GET to index logged in as admin" do
  #    setup do
  #      login_as_admin 
  #      get :index
  #    end
  #    should_paginate_collection :users
  #    should_display_pagination
  #  end
  def self.should_paginate_collection(collection_name)
    should "paginate #{collection_name}" do
      assert collection = assigns(collection_name), 
        "Controller isn't assigning to @#{collection_name.to_s}."
      assert_kind_of WillPaginate::Collection, collection, 
        "@#{collection_name.to_s} isn't a WillPaginate collection."
    end
  end
  
  def self.should_display_pagination
    should "display pagination" do
      assert_select "div.pagination", { :minimum => 1 }, 
        "View isn't displaying pagination. Add <%= will_paginate @collection %>."
    end
  end
  
  # Example:
  #  context "a GET to index not logged in as admin" do
  #    setup { get :index }
  #    should_not_paginate_collection :users
  #    should_not_display_pagination
  #  end
  def self.should_not_paginate_collection(collection_name)
    should "not paginate #{collection_name}" do
      assert collection = assigns(collection_name), 
        "Controller isn't assigning to @#{collection_name.to_s}."
      assert_not_equal WillPaginate::Collection, collection.class, 
        "@#{collection_name.to_s} is a WillPaginate collection."
    end
  end
  
  def self.should_not_display_pagination
    should "not display pagination" do
      assert_select "div.pagination", { :count => 0 }, 
        "View is displaying pagination. Check your logic."
    end
  end
end
}

file 'test/test_helper.rb', 
%q{ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'action_view/test_case'

class Test::Unit::TestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  self.backtrace_silencers << :rails_vendor
  self.backtrace_filters   << :rails_root

end

class ActionView::TestCase
  # Enable UrlWriter when testing helpers
  include ActionController::UrlWriter
  # Default host for helper tests
  default_url_options[:host] = HOST
end
}

# ====================
# Copy Templates
# ====================

run "git clone --depth 1 git://github.com/bcalloway/comatose-engine.git vendor/plugins/comatose_engine"

# Cleanup junk
run "rm -f app/views/layouts/*"
run "rm -f app/views/user_sessions/*"
run "rm -f app/views/users/*"
run "rm -rf vendor/plugins/comatose_engine/.git"

# stylesheets
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/public/stylesheets/reset.css -O public/stylesheets/reset.css"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/public/stylesheets/admin.sass -O public/stylesheets/admin.sass"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/public/stylesheets/theme.sass -O public/stylesheets/theme.sass"

# controllers
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/controllers/users_controller.rb -O app/controllers/users_controller.rb"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/controllers/user_sessions_controller.rb -O app/controllers/user_sessions_controller.rb"

# models
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/models/user.rb -O app/models/user.rb"

# layouts
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/layouts/application.html.haml -O app/views/layouts/application.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/layouts/comatose_admin.html.haml -O app/views/layouts/comatose_admin.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/layouts/_user_bar.html.haml -O app/views/layouts/_user_bar.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/layouts/_admin_nav.html.haml -O app/views/layouts/_admin_nav.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/layouts/_flashes.html.haml -O app/views/layouts/_flashes.html.haml"

# views
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/user_sessions/new.html.haml -O app/views/user_sessions/new.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/users/_form.html.haml -O app/views/users/_form.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/users/_secondary_nav.html.haml -O app/views/users/_secondary_nav.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/users/edit.html.haml -O app/views/users/edit.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/users/index.html.haml -O app/views/users/index.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/users/new.html.haml -O app/views/users/new.html.haml"
run "wget http://github.com/scullygroup/scully-rails-template/raw/master/templates/app/views/users/show.html.haml -O app/views/users/show.html.haml"

# ====================
# FINALIZE
# ====================
generate :formtastic
generate :plugin_migration

# Misc tasks
run "rm public/index.html"
run "haml --rails ."
run "mkdir public/stylesheets/sass"
run "touch public/stylesheets/sass/screen.sass"
#run 'find . \( -type d -empty \) -and \( -not -regex ./\.git.* \) -exec touch {}/.gitignore \;'
file '.gitignore', <<-END
.DS_Store
coverage/*
log/*.log
db/*.db
db/schema.rb
tmp/**/*
doc/api
doc/app
END

git :init
git :add => "."
git :commit => "-a -m 'Initial project commit'"

puts "
**********************************************************************************************
*
*  All Done!!
*    
*  Be sure to configure database.yml
*  and then run rake db:migrate to run pending migrations
*
**********************************************************************************************
"