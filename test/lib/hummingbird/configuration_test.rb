require 'test_helper'

describe Hummingbird::Configuration do
  before do
    @tempdir = tempdir
  end

  it 'defines the CONFIG_FILE basename constant' do
    assert_equal 'hummingbird.yml', Hummingbird::Configuration::CONFIG_FILE
  end

  it 'defines the USER_CONFIG_FILE basename constant' do
    assert_equal '.hummingbird.yml', Hummingbird::Configuration::USER_CONFIG_FILE
  end

  it 'loads the hummingbird.yml file from the specified config_dir' do
    copy_fixture_to(
      'basic_config.yml',
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal 'sql',                                     config.basedir
    assert_equal _with_basedir(config, 'application.plan'), config.planfile
    assert_equal _with_basedir(config, 'migrations-dir'),   config.migrations_dir
  end

  it "defaults :basedir to be '.'" do
    copy_fixture_to(
      'no_basedir_config.yml',
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal '.', config.basedir
  end

  it "defaults :planfile to be basedir + 'hummingbird.plan'" do
    copy_fixture_to(
      'no_planfile_config.yml',
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal _with_basedir(config,'hummingbird.plan'), config.planfile
  end

  it "defaults :migrations_dir to be basedir + 'migrations'" do
    copy_fixture_to(
      'no_migrations_dir_config.yml',
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal _with_basedir(config,'migrations'), config.migrations_dir
  end

  it "prefers the user's configuration file if one is present" do
    [['basic_config.yml', Hummingbird::Configuration::CONFIG_FILE],
      ['user_config.yml', Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(s, File.join(@tempdir, d))
    end

    config = nil
    FileUtils.stub :pwd, @tempdir do
      config = Hummingbird::Configuration.new(@tempdir)
    end

    assert_equal 'user-sql',                                    config.basedir
    assert_equal _with_basedir(config,'user-application.plan'), config.planfile
    assert_equal _with_basedir(config,'user-migrations-dir'),   config.migrations_dir
  end

  it "uses non-user basedir if not present for user" do
    [['basic_config.yml', Hummingbird::Configuration::CONFIG_FILE],
      ['no_basedir_user_config.yml', Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(s, File.join(@tempdir, d))
    end

    config = nil
    FileUtils.stub :pwd, @tempdir do
      config = Hummingbird::Configuration.new(@tempdir)
    end

    assert_equal 'sql',                                          config.basedir
    assert_equal _with_basedir(config, 'user-application.plan'), config.planfile
    assert_equal _with_basedir(config, 'user-migrations-dir'),   config.migrations_dir
  end

  it "uses non-user planfile if not present for user" do
    [['basic_config.yml', Hummingbird::Configuration::CONFIG_FILE],
      ['no_planfile_user_config.yml', Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(s, File.join(@tempdir, d))
    end

    config = nil
    FileUtils.stub :pwd, @tempdir do
      config = Hummingbird::Configuration.new(@tempdir)
    end

    assert_equal 'user-sql',                                   config.basedir
    assert_equal _with_basedir(config, 'application.plan'),    config.planfile
    assert_equal _with_basedir(config, 'user-migrations-dir'), config.migrations_dir
  end

  it "uses non-user migrations_dir if not present for user" do
    [['basic_config.yml', Hummingbird::Configuration::CONFIG_FILE],
      ['no_migrations_dir_user_config.yml', Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(s, File.join(@tempdir, d))
    end

    config = nil
    FileUtils.stub :pwd, @tempdir do
      config = Hummingbird::Configuration.new(@tempdir)
    end

    assert_equal 'user-sql',                                     config.basedir
    assert_equal _with_basedir(config, 'user-application.plan'), config.planfile
    assert_equal _with_basedir(config, 'migrations-dir'),        config.migrations_dir
  end

  def _with_basedir(config,path)
    File.expand_path(File.join(config.basedir,path))
  end
end
