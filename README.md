## Purpose

Add [Fly.io](https://fly.io) support to [Rails](https://rubyonrails.org/).

## Usage

For usage instructions, see the following guides:

  * [Machine API](https://fly.io/docs/rails/advanced-guides/machine/)
  * [Lite FS](https://fly.io/docs/rails/advanced-guides/litefs/)
  * [Terraform](https://fly.io/docs/rails/advanced-guides/terraform/)

## Generator options

  * `--name` name of the application.  If a name is not provided, one will be generated for you.
  * `--org` the organization to operate on.  Defaults to `personal`.
  * `--region` region to launch the application in.  Accepts multiple values, and can be specified multiple times.
  * `--nomad` generates a nomad application instead of a machines application.
  * `--litefs` adds support for replicated sqlite3 databases via [litefs](https://fly.io/blog/introducing-litefs/).  Only works on nomad machines currently.
  * `--passenger` run your Rails application with [nginx](https://www.nginx.com/) and [Phusion Passenger](https://www.phusionpassenger.com/).
  * `--serverless` configures your application to exit after 5 minutes of inactivity.  Machines will automatically restart when next accessed.  Only works with passenger currently.

## Automatically detected features

  * _ruby_: the deployed application will use the same version of ruby and bundler as your development environment.
  * _node_: if the use of node is detected, node, yarn, and your npm packages will be installed.
  * _sqlite3_: if the production database is sqlite3 a volume will be allocated and the database will be put there.
  * _postgres_: if the production database is postgres a postgres machine will be allocated
  * _redis_: if redis is used for action cable, caching, or sidekiq your redis database will be added to this application.  If you don't currently have a redis database, one will be allocated.  If redis is used for caching, eviction will be turned on.
  * _sidekiq_: if sidekiq is used it will be launched along side of your rails application.

## Key files

  * Entrypoints: [lib/tasks/fly.rake](./lib/tasks/fly.rake), [lib/generators/app_generator.rb](./lib/generators/app_generator.rb), [lib/generators/terraform_generator.rb](.lib/generators/terraform_generator.rb) contain the deploy task, fly:app generator and
  fly:terraform generator respectively.
  * [lib/fly-rails/actions.rb](./lib/fly-rails/actions.rb) contains Thor actions used by the
  rake task and generators.  Does some funky stuff to allow Thor actions to
  be called from Rake.
  * [lib/fly-rails/machines.rb](./lib/fly-rails/machines.rb) wraps Fly.io's machine API as a Ruby module.
  * [lib/generators/templates](./lib/generators/templates) contains erb
  templates for all of the files produced primarily by the generator, but also
  by the deploy task.
  * [Rakefile](./Rakefile) used to build gems.  Includes native binaries for each supported platform.



## Build instructions

```
rake package
```

This will involve downloading binaries from github and building gems for
every supported platform as well as an additional gem that doesn't
include a binary.

To download new binaries, run `rake clobber` then `rake package` agein.

## Debugging instructions

This gem provides a Railtie, with rake tasks and a generator that uses
Thor and templates.  Being in Ruby, there is no "compile" step.  That
coupled with Bundler "local overrides" makes testing a breeze.  And
Rails 7 applications without node dependencies are quick to create.

A script like the following will destroy previous fly applications,
create a new rails app, add and then override this gem, and finally
copy in any files that would need to be manually edited.

```
if [ -e welcome/fly.toml ]; then
  app=$(awk -e '/^app\s+=/ { print $3 }' welcome/fly.toml | sed 's/"//g')
  fly apps destroy -y $app
fi
rm -rf welcome
rails new welcome
cd welcome
bundle config disable_local_branch_check true
bundle config set --local local.fly-rails /Users/rubys/git/fly-rails
bundle add fly-rails --git https://github.com/rubys/fly-rails.git
cp ../routes.rb config
# bin/rails generate fly:app --eject
```

Once created, I rerun using:

```
cd ..; sh redo-welcome; cd welcome; 
```

Generally after the finaly semicolon, I have commands like
`bin/rails generate fly:app --litefs; fly deploy`.  Rerunning
after I make a change is a matter of pushing the up arrow until
I find this command and then pressing enter.

