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
      ['config','basic_config.yml'],
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal File.expand_path('sql',@tempdir),          config.basedir
    assert_equal _with_basedir(config, 'application.plan'), config.planfile
    assert_equal _with_basedir(config, 'migrations-dir'),   config.migrations_dir
    assert_equal :application_migrations,                   config.migrations_table
    assert_equal 'sequel connection string',                config.connection_string
  end

  it "defaults #basedir to be the configuration directory" do
    copy_fixture_to(
      ['config','no_basedir_config.yml'],
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal @tempdir, config.basedir
  end

  it "defaults #planfile to be basedir + 'hummingbird.plan'" do
    copy_fixture_to(
      ['config','no_planfile_config.yml'],
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal _with_basedir(config,'hummingbird.plan'), config.planfile
  end

  it "defaults #migrations_dir to be basedir + 'migrations'" do
    copy_fixture_to(
      ['config','no_migrations_dir_config.yml'],
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal _with_basedir(config,'migrations'), config.migrations_dir
  end

  it 'defaults #migrations_table to be :hummingbird_migrations' do
    copy_fixture_to(
      ['config','no_migrations_table_config.yml'],
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal :hummingbird_migrations, config.migrations_table
  end

  it "does not have a default #connection_string" do
    copy_fixture_to(
      ['config','no_connection_string_config.yml'],
      File.join(@tempdir, Hummingbird::Configuration::CONFIG_FILE)
    )

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal nil, config.connection_string
  end

  it "prefers the user's configuration file if one is present in the config dir" do
    [ ['basic_config.yml', Hummingbird::Configuration::CONFIG_FILE],
      ['user_config.yml',  Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(['config',s], File.join(@tempdir, d))
    end

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal File.expand_path('user-sql', @tempdir),        config.basedir
    assert_equal _with_basedir(config,'user-application.plan'), config.planfile
    assert_equal _with_basedir(config,'user-migrations-dir'),   config.migrations_dir
  end

  it "uses non-user basedir if not present for user" do
    [ ['basic_config.yml',           Hummingbird::Configuration::CONFIG_FILE],
      ['no_basedir_user_config.yml', Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(['config',s], File.join(@tempdir, d))
    end

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal File.expand_path('sql', @tempdir),              config.basedir
    assert_equal _with_basedir(config, 'user-application.plan'), config.planfile
    assert_equal _with_basedir(config, 'user-migrations-dir'),   config.migrations_dir
  end

  it "uses non-user planfile if not present for user" do
    [ ['basic_config.yml',            Hummingbird::Configuration::CONFIG_FILE],
      ['no_planfile_user_config.yml', Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(['config',s], File.join(@tempdir, d))
    end

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal File.expand_path('user-sql', @tempdir),       config.basedir
    assert_equal _with_basedir(config, 'application.plan'),    config.planfile
    assert_equal _with_basedir(config, 'user-migrations-dir'), config.migrations_dir
  end

  it "uses non-user migrations_dir if not present for user" do
    [ ['basic_config.yml',                  Hummingbird::Configuration::CONFIG_FILE],
      ['no_migrations_dir_user_config.yml', Hummingbird::Configuration::USER_CONFIG_FILE]].each do |s,d|
      copy_fixture_to(['config',s], File.join(@tempdir, d))
    end

    config = Hummingbird::Configuration.new(@tempdir)

    assert_equal File.expand_path('user-sql', @tempdir),         config.basedir
    assert_equal _with_basedir(config, 'user-application.plan'), config.planfile
    assert_equal _with_basedir(config, 'migrations-dir'),        config.migrations_dir
  end

  it "overrides the base config file name when given a relative :config_file option" do
    [ ['overridden_config.yml', 'overridden_name.yml'],
      ['basic_config.yml',      Hummingbird::Configuration::CONFIG_FILE]].each do |s,d|
      copy_fixture_to(['config',s],File.join(@tempdir,d))
    end

    config = Hummingbird::Configuration.new(@tempdir, config_file: 'overridden_name.yml')

    assert_equal File.expand_path('overridden-sql', @tempdir),                    config.basedir
    assert_equal File.expand_path('overridden-application.plan', config.basedir), config.planfile
    assert_equal File.expand_path('overridden-migrations-dir', config.basedir),   config.migrations_dir
    assert_equal :overridden_application_migrations,                              config.migrations_table
    assert_equal 'overridden sequel connection string',                           config.connection_string
  end

  it "overrides the base config file name when given an absolute :config_file option" do
    copy_fixture_to(['config','basic_config.yml'], File.join(@tempdir,Hummingbird::Configuration::CONFIG_FILE))
    overridden_config_path = File.join(tempdir,'config.yml')
    copy_fixture_to(['config','overridden_config.yml'], overridden_config_path)

    config = Hummingbird::Configuration.new(@tempdir, config_file: overridden_config_path)

    assert_equal File.expand_path('overridden-sql', @tempdir),                    config.basedir
    assert_equal File.expand_path('overridden-application.plan', config.basedir), config.planfile
    assert_equal File.expand_path('overridden-migrations-dir', config.basedir),   config.migrations_dir
    assert_equal :overridden_application_migrations,                              config.migrations_table
    assert_equal 'overridden sequel connection string',                           config.connection_string
  end

  it "overrides the base user config file name when given a relative :user_config_file option" do
    [ ['basic_config.yml',      Hummingbird::Configuration::CONFIG_FILE],
      ['user_config.yml',       Hummingbird::Configuration::USER_CONFIG_FILE],
      ['overridden_config.yml', 'overridden_name.yml']].each do |s,d|
      copy_fixture_to(['config',s],File.join(@tempdir,d))
    end

    config = Hummingbird::Configuration.new(@tempdir, user_config_file: 'overridden_name.yml')

    assert_equal File.expand_path('overridden-sql', @tempdir),                    config.basedir
    assert_equal File.expand_path('overridden-application.plan', config.basedir), config.planfile
    assert_equal File.expand_path('overridden-migrations-dir', config.basedir),   config.migrations_dir
    assert_equal :overridden_application_migrations,                              config.migrations_table
    assert_equal 'overridden sequel connection string',                           config.connection_string
  end

  it "overrides the base user config file name when given an absolute :user_config_file option" do
    overridden_config_path = File.join(tempdir,'overridden_name.yml')
    [ ['basic_config.yml',      Hummingbird::Configuration::CONFIG_FILE],
      ['user_config.yml',       Hummingbird::Configuration::USER_CONFIG_FILE],
      ['overridden_config.yml', overridden_config_path]].each do |s,d|
      copy_fixture_to(['config',s],File.expand_path(d,@tempdir))
    end

    config = Hummingbird::Configuration.new(@tempdir, user_config_file: overridden_config_path)

    assert_equal File.expand_path('overridden-sql', @tempdir),                    config.basedir
    assert_equal File.expand_path('overridden-application.plan', config.basedir), config.planfile
    assert_equal File.expand_path('overridden-migrations-dir', config.basedir),   config.migrations_dir
    assert_equal :overridden_application_migrations,                              config.migrations_table
    assert_equal 'overridden sequel connection string',                           config.connection_string
  end

  def _with_basedir(config,path)
    File.expand_path(path,config.basedir)
  end
end
