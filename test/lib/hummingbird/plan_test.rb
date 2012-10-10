require 'test_helper'

describe Hummingbird::Plan do
  it 'reads the planned file list from config.planfile' do
    config = MiniTest::Mock.new
    config.expect :planfile, path_to_fixture('plan','basic.plan')
    config.expect :migration_dir, tempdir

    plan = Hummingbird::Plan.new(config)

    assert_equal(
      ['file1.sql','file2.sql','file3.sql','file4.sql'],
      plan.planned_files
    )

    config.verify
  end

  it 'gets the list of migration files from examining config.migration_dir' do
    migration_dir = tempdir
    migration_files = ['migration1.sql','migration2.sql','migration3.sql']
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    config = MiniTest::Mock.new
    config.expect :planfile, path_to_fixture('plan','basic.plan')
    config.expect :migration_dir, migration_dir

    plan = Hummingbird::Plan.new(config)

    migration_files.each do |f|
      assert_includes plan.migration_files, f
    end

    config.verify
  end

  it 'recurses into config.migration_dir to get the list of migration files' do
    migration_dir = tempdir
    migration_files = [['a','b','migration1.sql'],['a','migration2.sql'],['migration3.sql']].map {|f| File.join(*f)}
    FileUtils.mkdir_p(File.join(migration_dir, 'a', 'b'))
    FileUtils.touch migration_files.map {|f| File.join(migration_dir, f)}

    config = MiniTest::Mock.new
    config.expect :planfile, path_to_fixture('plan','basic.plan')
    config.expect :migration_dir, migration_dir

    plan = Hummingbird::Plan.new(config)

    migration_files.each do |f|
      assert_includes plan.migration_files, f
    end

    config.verify
  end

  it 'returns the list of files missing from the plan' do
    migration_dir = tempdir
    migration_files = (0..6).map {|n| "file#{n}.sql"}
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    config = MiniTest::Mock.new
    config.expect :planfile, path_to_fixture('plan','basic.plan')
    config.expect :migration_dir, migration_dir

    plan = Hummingbird::Plan.new(config)

    assert_set_equal [migration_files[0],*migration_files[-2,2]], plan.files_missing_from_plan, 'Wrong files missing from plan'
    assert_set_equal [], plan.files_missing_from_migration_dir, 'Wrong files missing from migration_dir'

    config.verify
  end

  it 'returns the list of extra files in the plan' do
    migration_dir = tempdir
    migration_files = (2..3).map {|n| "file#{n}.sql"}
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    config = MiniTest::Mock.new
    config.expect :planfile, path_to_fixture('plan','basic.plan')
    config.expect :migration_dir, migration_dir

    plan = Hummingbird::Plan.new(config)

    assert_set_equal ['file1.sql','file4.sql'], plan.files_missing_from_migration_dir, 'Wrong files missing from migration_dir'
    assert_set_equal [], plan.files_missing_from_plan, 'Wrong files missing from plan'

    config.verify
  end

  it 'reports no files missing when plan, and migration_dir are in sync' do
    migration_dir = tempdir
    migration_files = (1..4).map {|n| "file#{n}.sql"}
    FileUtils.touch migration_files.map {|f| File.join(migration_dir,f)}

    config = MiniTest::Mock.new
    config.expect :planfile, path_to_fixture('plan','basic.plan')
    config.expect :migration_dir, migration_dir

    plan = Hummingbird::Plan.new(config)

    assert_set_equal [], plan.files_missing_from_migration_dir, 'Wrong files missing from migration_dir'
    assert_set_equal [], plan.files_missing_from_plan, 'Wrong files missing from plan'

    config.verify
  end
end
