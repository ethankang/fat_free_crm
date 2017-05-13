# source 'https://rubygems.org'
source 'https://gems.ruby-china.org'

gem "mysql2"

# Removes a gem dependency
def remove(name)
  @dependencies.reject! { |d| d.name == name }
end

# Replaces an existing gem dependency (e.g. from gemspec) with an alternate source.
def gem(name, *args)
  remove(name)
  super
end

# Bundler no longer treats runtime dependencies as base dependencies.
# The following code restores this behaviour.
# (See https://github.com/carlhuda/bundler/issues/1041)
spec = Bundler.load_gemspec(File.expand_path("../fat_free_crm.gemspec", __FILE__))
spec.runtime_dependencies.each do |dep|
  gem dep.name, *dep.requirement.as_list
end

# Remove premailer auto-require
gem 'premailer', require: false

# Remove fat_free_crm dependency, to stop it from being auto-required too early.
remove 'fat_free_crm'

group :development do
  # don't load these gems in travis
  unless ENV["CI"]
    gem 'thin'
    gem 'quiet_assets'
    gem 'capistrano'
    gem 'capistrano-bundler'
    gem 'capistrano-rails'
    gem 'capistrano-rvm'
    gem 'capistrano-unicorn-nginx'
    gem 'guard'
    gem 'guard-rspec'
    gem 'guard-rails'
    gem 'rb-inotify', require: false
    gem 'rb-fsevent', require: false
    gem 'rb-fchange', require: false
  end
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'headless'
  gem 'byebug'
  gem 'pry-rails' unless ENV["CI"]
  gem 'factory_girl_rails', '~> 4.7.0' # 4.8.0+ stubbed models are not allowed to access the database - User#destroyed?()
  gem 'rubocop'
  gem 'rainbow', '< 2.2.1' # https://github.com/fatfreecrm/fat_free_crm/issues/551
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver', '< 3.0.0'
  gem 'database_cleaner'
  gem "acts_as_fu"
  gem 'zeus' unless ENV["CI"]
  gem 'timecop'
end

group :heroku do
  gem 'unicorn', platform: :ruby
  gem 'rails_12factor'
end

group :production do
  gem 'unicorn', '~> 4.9.0'
  gem 'lograge', '~> 0.4.1'
end

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'execjs'
gem 'therubyracer', platform: :ruby unless ENV["CI"]
gem 'nokogiri', '>= 1.6.8'
gem 'gollum', '~> 4.1', '>= 4.1.1'
gem 'gollum-rugged_adapter', '~> 0.4.4'
