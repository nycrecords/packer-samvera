# Capify a Rails app to be run on CentOS the packer-samvera way

Capifying a project just means to construct it in such a way that it works with Capistrano, which is what packer-samvera uses.

First, check out the project and ensure the tests pass.

Edit `config/solr.yml` to look like:

```ruby
    development:
      url: <%= ENV['SOLR_URL'] || "http://127.0.0.1:8983/solr/hydra-development" %>
    test:
      url: <%= ENV['SOLR_URL'] || "http://127.0.0.1:8985/solr/hydra-test" %>
    production:
      url: <%= ENV['SOLR_URL'] %>
```

Edit `config/blacklight.yml` to look like:

```ruby
    development:
      adapter: solr
      url: <%= ENV['SOLR_URL'] || "http://127.0.0.1:8983/solr/hydra-development" %>
    test: &test
      adapter: solr
      url: <%= ENV['SOLR_URL'] || "http://127.0.0.1:8985/solr/hydra-test" %>
    production:
      adapter: solr
      url: <%= ENV['SOLR_URL'] %>
```

Edit `config/fedora.yml` to add the production fedora settings:

```ruby
    default: &default
      user: <%= ENV['FEDORA_USER'] || 'fedoraAdmin' %>
      password: <%= ENV['FEDORA_PASSWORD'] || 'fedoraAdmin' %>
    development:
      <<: *default
      url: <%= ENV['FEDORA_URL'] || 'http://127.0.0.1:8984/rest' %>
      base_path: <%= ENV['FEDORA_BASE_PATH'] || '/dev' %>
    test:
      <<: *default
      url: <%= ENV['FEDORA_URL'] || 'http://127.0.0.1:8986/rest' %>
      base_path: <%= ENV['FEDORA_BASE_PATH'] || '/test' %>
    production:
      user: <%= ENV['FEDORA_USER'] %>
      password: <%= ENV['FEDORA_PASSWORD'] %>
      url: <%= ENV['FEDORA_URL'] %>
      base_path: <%= ENV['FEDORA_BASE_PATH'] || '/prod' %>
      request: { timeout: 7200, open_timeout: 60}
```

Use the following for your Gemfile or make sure the dependencies in it are also in your own:

```ruby
    # frozen_string_literal: true
    source 'https://rubygems.org'

    git_source(:github) do |repo_name|
      repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
      "https://github.com/#{repo_name}.git"
    end

    ruby '>= 2.4.0', '<= 2.5.99'

    gem 'darlingtonia', '~> 1.0'
    gem 'honeybadger', '~> 3.1'
    gem 'hyrax', '~> 2.2', '>= 2.2.2'
    gem 'rails', '~> 5.1.6'

    gem 'pkg-config', '~> 1.1'

    # Use mysql
    gem 'mysql2', '~> 0.5'
    # Use Puma as the app server
    gem 'puma', '~> 3.7'
    # Use SCSS for stylesheets
    gem 'sass-rails', '~> 5.0'
    # Use Uglifier as compressor for JavaScript assets
    gem 'uglifier', '>= 1.3.0'
    # See https://github.com/rails/execjs#readme for more supported runtimes
    # gem 'therubyracer', platforms: :ruby

    # Use CoffeeScript for .coffee assets and views
    gem 'coffee-rails', '~> 4.2'
    # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
    gem 'turbolinks', '~> 5'
    # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
    gem 'jbuilder', '~> 2.5'
    # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
    gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

    gem 'devise'
    gem 'devise-guests', '~> 0.6'
    gem 'dotenv-rails', '~> 2.2.1'
    gem 'hydra-role-management', '~> 1.0.0'
    gem 'jquery-rails'
    gem 'retries'
    gem 'riiif', '~> 1.1'
    gem 'rsolr', '>= 1.0'
    gem 'sidekiq', '~> 5.1.3'
    gem 'whenever', require: false

    group :development do
      # Use Capistrano for deployment automation
      gem "capistrano", "~> 3.11", require: false
      gem 'capistrano-bundler', '~> 1.3'
      gem 'capistrano-ext'
      gem 'capistrano-passenger'
      gem 'capistrano-rails'
      gem 'capistrano-rails-collection'
      gem 'capistrano-sidekiq', '~> 0.20.0'
      # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
      gem 'listen', '>= 3.0.5', '< 3.2'
      gem 'web-console', '>= 3.3.0'
      # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
      gem 'spring'
      gem 'spring-watcher-listen', '~> 2.0.0'
    end

    group :development, :test do
      gem 'bixby', '~> 1.0.0'
      # Call 'byebug' anywhere in the code to stop execution and get a debugger console
      gem 'byebug', platforms: %i[mri mingw x64_mingw]
      # Adds support for Capybara system testing and selenium driver
      gem 'capybara', '~> 2.13'
      gem 'database_cleaner'
      gem 'factory_bot_rails'
      gem 'fcrepo_wrapper'
      gem 'ffaker'
      gem 'rspec-rails'
      gem 'rubocop-rspec'
      gem 'selenium-webdriver'
      gem 'solr_wrapper', '>= 0.3'
    end
```

Run `bundle install` from within the project directory

> *Note:* If `pg` and `sidekiq` haven't been added to the project yet, chances are good they aren't really setup properly. Don't forget to go back and check that.
> *Note:* Pinning `pg` to a pre-1.0 version is necessary because of [this bug](https://github.com/rails/rails/issues/31678). Hopefully this will not always be the case.

Make some DCE specific stages, instead of just the defaults: `bundle exec cap install STAGES=localhost,sandbox,qa,staging,production`

   Edit the newly created `config/deploy/localhost.rb` so it contains:

```ruby
   server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
```

Edit the newly created `config/deploy.rb` file:

- Add the `:application` name
- Add the github `:repo_url`
- Add this boilerplate, customizing as appropriate:

```ruby
    set :log_level, :debug
    set :bundle_flags, '--deployment'

    set :keep_releases, 5
    set :assets_prefix, "#{shared_path}/public/assets"

    SSHKit.config.command_map[:rake] = 'bundle exec rake'

    set :branch, ENV['REVISION'] || ENV['BRANCH'] || ENV['BRANCH_NAME'] || 'master'

    append :linked_dirs, "log"
    append :linked_dirs, "public/assets"

    append :linked_dirs, "tmp/pids"
    append :linked_dirs, "tmp/cache"
    append :linked_dirs, "tmp/sockets"

    append :linked_files, ".env.production"
    append :linked_files, "config/secrets.yml"

    # We have to re-define capistrano-sidekiq's tasks to work with
    # systemctl in production. Note that you must clear the previously-defined
    # tasks before re-defining them.
    Rake::Task["sidekiq:stop"].clear_actions
    Rake::Task["sidekiq:start"].clear_actions
    Rake::Task["sidekiq:restart"].clear_actions
    namespace :sidekiq do
      task :stop do
        on roles(:app) do
          execute :sudo, :systemctl, :stop, :sidekiq
        end
      end
      task :start do
        on roles(:app) do
          execute :sudo, :systemctl, :start, :sidekiq
        end
      end
      task :restart do
        on roles(:app) do
          execute :sudo, :systemctl, :restart, :sidekiq
        end
      end
    end
```

> *Note:* You do NOT want the `:passenger_restart_with_touch` option. This will prevent passenger from automatically restarting after you deploy.  
> See: <https://github.com/capistrano/passenger#restarting-passenger--4033-applications>

Add this content to your `Capfile`:

```ruby
    # Load DSL and set up stages
    require "capistrano/setup"

    # Include default deployment tasks
    require "capistrano/deploy"

    # Use bundler to install gem requirements
    require 'capistrano/bundler'
    require 'capistrano/rails'
    require 'capistrano/sidekiq'
    require 'capistrano/passenger'
    require "capistrano/scm/git"
    install_plugin Capistrano::SCM::Git

    # Load custom tasks from `lib/capistrano/tasks` if you have any defined
    Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
```

Make sure to supply all the variables in the project's `config.json` file (consult the `sample-config.json` file for possible variables) are supplied.

This is a first pass of this process and is, most likely, incomplete. If you have trouble using a Hyrax project with packer-samvera, we'd be interested in hearing your experiences. The project's [issues queue](https://github.com/uclalibrary/packer-samvera/issues) is a good way to communicate.
