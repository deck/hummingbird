# What is it?

Hummingbird is a way to write SQL migrations in SQL, and provide
some minimal tooling around running these migrations against a DB.

# Why is it?

DSLs that abstract away the differences in databases can be nice to
work with, but they often cater to something resembling the lowest
common denominator amongst those databases.

# How to use it

## Configuration

Hummingbird will look for a `hummingbird.yml` in the directory passed
to `Hummingbird::Configuration.new`.  Hummingbird will also look for a
user-specific `.hummingbird.yml` in that directory.  The user-specific
configuration file will take precidence over the configuration in the
`hummingbird.yml`.  Both the configuration file name and path, and the
user-specific configuration name and path can be overridden by passing
`:config_file => config_name` or `:user_config_file => user_config_name`
to `Hummingbird::Configuration.new`.

For example:

```Ruby
config = Hummingbird::Configuration.new(
  Dir.getwd,
  config_file: 'path/to/config.yml',
  user_config_file: '/absolute/path/to/user_config.yml'
)
```
The above example will cause Hummingbird to look for the configuration
file in `File.join(Dir.getwd, 'path/to/config.yml')`, and to look for
the user's configuration file in `/absolute/path/to/user_config.yml`.

Both of these configuration files are YAML files with the following
format:

```YAML
---
basedir: 'sql'
planfile: 'application.plan'
migrations_dir: 'migrations'
migrations_table: 'application_migrations'
connection_string: 'sqlite://db/database.db'
```

* `basedir`: The `planfile`, and `migrations_dir` settings are relative
  to this directory, which is relative to the current working
  directory.
* `planfile`: Described more below. This determines the order in which
  migration files are run.
* `migrations_dir`: This is the name of the directory that will
  contain all of the migrations.  All files in this directory are
  considered to be migration files, and Hummingbird will recurse into
  any and all subdirectories starting here.
* `connection_string`: This is a [Sequel][] compatible connection
  string for connecting to the database.

The above example configures Hummingbird to look in the file
`sql/application.plan` for the list of migrations to run, in the
directory `sql/migrations` for all of the migration files, use the
table named `application_migrations` within the database, and to
connect to the database using the [Sequel][] connection string `'sqlite://db/database.db'`.

## Boot-strapping the Database

Hummingbird is capable of bootstrapping itself into the database to be
managed as long as the first migration creates the table named by the
`migrations_table` configuration option.  This table will need to have
a `migration_name` column of type `TEXT` (or similar data type to
handle the maximum file path relative to `migrations_dir`), and a
`run_on` column of type `INTEGER`.

The following is an example for defining the `migrations_table` for
SQLite3:

```sql
CREATE TABLE hummingbird_migrations (
  migration_name TEXT PRIMARY KEY,
  run_on INTEGER
);

```

## Plan file

The plan file contains the names of the migration files to be run, one
per line, in the order that they should be run.

Given the following plan file and the example configuration from above:

```
bootstrap.sql
stored_procedures/foo.sql
tables/bar.sql
```

Hummingbird would attempt to run the files
`sql/migrations/bootstrap.sql`,
`sql/migrations/stored_procedures/foo.sql`,
`sql/migrations/tables/bar.sql` in exactly this order.

## Running migrations

Right now, only just enough is written to enable someone to write
their own rake task, or other glue code to actually migrate their
database using Hummingbird.

This isn't really a great way to go about it, but you can do the
following in your `Rakefile` at least until the rest of the glue is
included in Hummingbird itself:

```Ruby
desc 'Migrate the database'
task "migrate" do
  require 'hummingbird'

  config = Hummingbird::Configuration.new(Dir.getwd)
  plan   = Hummingbird::Plan.new(config.planfile, config.migrations_dir)
  db     = Hummingbird::Database.new(config.connection_string, config.migrations_table)

  unplanned_files = plan.files_missing_from_plan
  fail "Found migration files not listed in #{config.planfile}: #{unplanned_files.join(', ')}" unless unplanned_files.empty?

  missing_files = plan.files_missing_from_migration_dir
  fail "Found planned migration files not in migrations directory: #{missing_files.join(', ')}" unless missing_files.empty?

  migrations_already_run = db.already_run_migrations
  migrations_to_run      = plan.migrations_to_be_run(migrations_already_run)

  puts "#{plan.planned_files.count} migrations planned; #{migrations_already_run.count} already run; #{migrations_to_run.count} to run"

  migrations_to_run.each do |migration|
    puts "Running migration: #{migration[:migration_name]}"
    db.run_migration(migration[:migration_name], migration[:sql])
  end
end
```

# Resources

* [Travis CI][travis-ci] [![Build Status](https://secure.travis-ci.org/jhelwig/hummingbird.png?branch=master)](http://travis-ci.org/jhelwig/hummingbird)
* [Issues][issues]

[travis-ci]: http://travis-ci.org "Travis CI"
[issues]: https://github.com/jhelwig/hummingbird/issues "GitHub issues"
[Sequel]: http://sequel.rubyforge.org/ "The Database Toolkit for Ruby"
