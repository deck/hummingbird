require 'test_helper'
require 'sqlite3'

describe Hummingbird::Plan do
  it 'reads the planned file list from the planfile' do
    plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), tempdir)

    assert_equal(
      ['file1.sql','file2.sql','file3.sql','file4.sql'],
      plan.planned_files
    )
  end

  it 'gets the list of migration files from examining config.migration_dir' do
    migration_dir = tempdir
    migration_files = ['migration1.sql','migration2.sql','migration3.sql']
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), migration_dir)

    assert_equal(
      migration_files,
      plan.migration_files
    )
  end

  it 'recurses into config.migration_dir to get the list of migration files' do
    migration_dir = tempdir
    migration_files = [['a','b','migration1.sql'],['a','migration2.sql'],['migration3.sql']].map {|f| File.join(*f)}
    FileUtils.mkdir_p(File.join(migration_dir, 'a', 'b'))
    FileUtils.touch migration_files.map {|f| File.join(migration_dir, f)}

    plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), migration_dir)

    assert_equal(
      migration_files,
      plan.migration_files
    )
  end

  it 'returns the list of files missing from the plan' do
    migration_dir = tempdir
    migration_files = (0..6).map {|n| "file#{n}.sql"}
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), migration_dir)

    assert_set_equal [migration_files[0],*migration_files[-2,2]], plan.files_missing_from_plan, 'Wrong files missing from plan'
    assert_set_equal [], plan.files_missing_from_migration_dir, 'Wrong files missing from migration_dir'
  end

  it 'returns the list of extra files in the plan' do
    migration_dir = tempdir
    migration_files = (2..3).map {|n| "file#{n}.sql"}
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), migration_dir)

    assert_set_equal ['file1.sql','file4.sql'], plan.files_missing_from_migration_dir, 'Wrong files missing from migration_dir'
    assert_set_equal [], plan.files_missing_from_plan, 'Wrong files missing from plan'
  end

  it 'reports no files missing when plan, and migration_dir are in sync' do
    migration_dir = tempdir
    migration_files = (1..4).map {|n| "file#{n}.sql"}
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), migration_dir)

    assert_set_equal [], plan.files_missing_from_migration_dir, 'Wrong files missing from migration_dir'
    assert_set_equal [], plan.files_missing_from_plan, 'Wrong files missing from plan'
  end

  describe '#migrations_to_be_run' do
    it 'returns all planned files when the db is uninitialized' do
      sqlite_db_path = tempfile.path
      config = MiniTest::Mock.new
      config.expect :connection_string, "sqlite://#{sqlite_db_path}"
      config.expect :migrations_table,  :hummingbird_migrations

      plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), path_to_fixture('sql','migrations','basic'))
      db   = Hummingbird::Database.new(config)

      assert_equal(
        ['file1.sql','file2.sql','file3.sql','file4.sql'],
        plan.migrations_to_be_run(db.already_run_migrations)
      )

      config.verify
    end

    it 'returns all planned files when no migrations have been run' do
      sqlite_db_path = tempfile.path
      connect_string = "sqlite://#{sqlite_db_path}"
      sqlite_db = SQLite3::Database.new(sqlite_db_path)
      sqlite_db.execute read_fixture('sql', 'migrations_table.sql')

      config = MiniTest::Mock.new
      config.expect :connection_string, connect_string
      config.expect :migrations_table,  :hummingbird_migrations

      plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), path_to_fixture('sql','migrations','basic'))
      db   = Hummingbird::Database.new(config)

      assert_equal(
        ['file1.sql','file2.sql','file3.sql','file4.sql'],
        plan.migrations_to_be_run(db.already_run_migrations)
      )

      config.verify
    end

    it 'returns all planned files after the last run migration when plan and DB are in sync to that point' do
      sqlite_db_path = tempfile.path
      connect_string = "sqlite://#{sqlite_db_path}"
      sqlite_db = SQLite3::Database.new(sqlite_db_path)
      sqlite_db.execute read_fixture('sql', 'migrations_table.sql')
      stmt = sqlite_db.prepare('INSERT INTO hummingbird_migrations (migration_name, run_on) VALUES (?,?);')
      [ ['file1.sql', DateTime.new(2012,10, 1,12,0,0,'-7').strftime('%s')],
        ['file2.sql', DateTime.new(2012,10,11,13,0,0,'-7').strftime('%s')]].each {|data| stmt.execute(*data)}

      config = MiniTest::Mock.new
      config.expect :connection_string, connect_string
      config.expect :migrations_table,  :hummingbird_migrations

      plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), path_to_fixture('sql','migrations','basic'))
      db   = Hummingbird::Database.new(config)

      assert_equal(
        ['file3.sql','file4.sql'],
        plan.migrations_to_be_run(db.already_run_migrations)
      )

      config.verify
    end

    it 'raises when a yet-to-be-run planned file is before a recorded migration' do
      sqlite_db_path = tempfile.path
      connect_string = "sqlite://#{sqlite_db_path}"
      sqlite_db = SQLite3::Database.new(sqlite_db_path)
      sqlite_db.execute read_fixture('sql', 'migrations_table.sql')
      stmt = sqlite_db.prepare('INSERT INTO hummingbird_migrations (migration_name, run_on) VALUES (?,?);')
      file3_run_on = DateTime.new(2012,10,11,13,0,0,'-7')
      [ ['file1.sql', DateTime.new(2012,10, 1,12,0,0,'-7').strftime('%s')],
        ['file3.sql', file3_run_on.strftime('%s')]].each {|data| stmt.execute(*data)}

      config = MiniTest::Mock.new
      config.expect :connection_string, connect_string
      config.expect :migrations_table,  :hummingbird_migrations

      plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), path_to_fixture('sql','migrations','basic'))
      db   = Hummingbird::Database.new(config)

      e = assert_raises Hummingbird::PlanError do
        plan.migrations_to_be_run(db.already_run_migrations)
      end

      assert_equal "Plan has 'file2.sql' before 'file3.sql' which was run on #{file3_run_on.new_offset(0)}", e.message

      config.verify
    end

    it 'raises when the plan file is not in the same order as the recorded migrations' do
      sqlite_db_path = tempfile.path
      connect_string = "sqlite://#{sqlite_db_path}"
      sqlite_db = SQLite3::Database.new(sqlite_db_path)
      sqlite_db.execute read_fixture('sql', 'migrations_table.sql')
      stmt = sqlite_db.prepare('INSERT INTO hummingbird_migrations (migration_name, run_on) VALUES (?,?);')
      file4_run_on = DateTime.new(2012,10,2,13,1,1,'-7')
      [ ['file1.sql', DateTime.new(2012,10,1,12,0,0,'-7').strftime('%s')],
        ['file4.sql', file4_run_on.strftime('%s')],
        ['file3.sql', DateTime.new(2012,10,3,14,2,2,'-7').strftime('%s')],
        ['file2.sql', DateTime.new(2012,10,4,15,3,3,'-7').strftime('%s')]].each {|data| stmt.execute(*data)}

      config = MiniTest::Mock.new
      config.expect :connection_string, connect_string
      config.expect :migrations_table,  :hummingbird_migrations

      plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), path_to_fixture('sql','migrations','basic'))
      db   = Hummingbird::Database.new(config)

      e = assert_raises Hummingbird::PlanError do
        plan.migrations_to_be_run(db.already_run_migrations)
      end

      assert_equal "Plan has 'file2.sql' before 'file4.sql' which was run on #{file4_run_on.new_offset(0)}", e.message

      config.verify
    end

    it 'raises when a recorded migration is missing from the plan' do
      sqlite_db_path = tempfile.path
      connect_string = "sqlite://#{sqlite_db_path}"
      sqlite_db = SQLite3::Database.new(sqlite_db_path)
      sqlite_db.execute read_fixture('sql', 'migrations_table.sql')
      stmt = sqlite_db.prepare('INSERT INTO hummingbird_migrations (migration_name, run_on) VALUES (?,?);')
      [ ['file1.sql', DateTime.new(2012,10,1,12,0,0,'-7').strftime('%s')],
        ['file2.sql', DateTime.new(2012,10,2,13,1,1,'-7').strftime('%s')],
        ['file3.sql', DateTime.new(2012,10,3,14,2,2,'-7').strftime('%s')],
        ['file4.sql', DateTime.new(2012,10,4,15,3,3,'-7').strftime('%s')],
        ['file5.sql', DateTime.new(2012,10,5,16,4,4,'-7').strftime('%s')]].each {|data| stmt.execute(*data)}

      config = MiniTest::Mock.new
      config.expect :connection_string, connect_string
      config.expect :migrations_table,  :hummingbird_migrations

      plan = Hummingbird::Plan.new(path_to_fixture('plan','basic.plan'), path_to_fixture('sql','migrations','basic'))
      db   = Hummingbird::Database.new(config)

      e = assert_raises Hummingbird::PlanError do
        plan.migrations_to_be_run(db.already_run_migrations)
      end

      assert_equal "Plan is missing the following already run migrations: file5.sql", e.message

      config.verify
    end
  end
end
