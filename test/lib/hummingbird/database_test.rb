require 'test_helper'
require 'sqlite3'

describe Hummingbird::Database do
  describe 'with an sqlite3 database' do
    it 'reports the database as uninitialized if the migrations table is not found' do
      sqlite_db = tempfile
      sqlite_db.close

      config = MiniTest::Mock.new
      config.expect :connection_string, "sqlite://#{sqlite_db.path}"
      config.expect :migrations_table,  :hummingbird_migrations

      db = Hummingbird::Database.new(config)

      assert_equal false, db.initialized?, 'DB should not be initialized'

      config.verify
    end

    it 'reports the database as initialized if the migrations table exists' do
      sqlite_db_path = tempfile.path
      sqlite_db = SQLite3::Database.new(sqlite_db_path)

      sqlite_db.execute "create table hummingbird_migrations (migration_name text);"

      config = MiniTest::Mock.new
      config.expect :connection_string, "sqlite://#{sqlite_db_path}"
      config.expect :migrations_table,  :hummingbird_migrations

      db = Hummingbird::Database.new(config)

      assert_equal true, db.initialized?, 'DB should be initialized'

      config.verify
    end

    it 'returns an empty list of already run migrations if the database has not already been initialized' do
      sqlite_db_path = tempfile.path
      sqlite_db = SQLite3::Database.new(sqlite_db_path)

      config = MiniTest::Mock.new
      config.expect :connection_string, "sqlite://#{sqlite_db_path}"
      config.expect :migrations_table, :hummingbird_migrations

      db = Hummingbird::Database.new(config)

      assert_set_equal [], db.already_run_migrations

      config.verify
    end

    it 'returns a list of the migrations that have already been run, in ascending run order of run date' do
      sqlite_db_path = tempfile.path
      sqlite_db = SQLite3::Database.new(sqlite_db_path)
      sqlite_db.execute read_fixture('sql', 'migrations_table.sql')
      stmt = sqlite_db.prepare('INSERT INTO hummingbird_migrations (migration_name, run_on) VALUES (?,?);')
      [ ['third_migration.sql',  DateTime.new(2012,10,11,12,0,0,'-7').strftime('%s')],
        ['first_migration.sql',  DateTime.new(2012,10, 1,13,0,0,'-7').strftime('%s')],
        ['second_migration.sql', DateTime.new(2012,10, 8, 8,0,0,'-7').strftime('%s')]].each {|data| stmt.execute(*data)}

      config = MiniTest::Mock.new
      config.expect :connection_string, "sqlite://#{sqlite_db_path}"
      config.expect :migrations_table, :hummingbird_migrations

      db = Hummingbird::Database.new(config)

      assert_equal(
        [ { migration_name: 'first_migration.sql',  run_on: DateTime.new(2012,10, 1,13,0,0,'-7').strftime('%s').to_i },
          { migration_name: 'second_migration.sql', run_on: DateTime.new(2012,10, 8, 8,0,0,'-7').strftime('%s').to_i },
          { migration_name: 'third_migration.sql',  run_on: DateTime.new(2012,10,11,12,0,0,'-7').strftime('%s').to_i }
        ],
        db.already_run_migrations
      )

      config.verify
    end
  end
end
