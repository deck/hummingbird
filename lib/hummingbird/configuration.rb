require 'optimism'
require 'yaml'

module Hummingbird
  # Helper class to handle reading configuration options from YAML
  # files.
  class Configuration
    # The name of the default configuration file.
    CONFIG_FILE = 'hummingbird.yml'
    # The name of the default user specific configuration file.  Used
    # for overriding settings in the default configuration file, or
    # providing values for settings missing from there.
    USER_CONFIG_FILE = '.hummingbird.yml'

    # Provides access to the settings found in the configuration file,
    # and user specific configuration file.  By default it will look
    # for {CONFIG_FILE}, and {USER_CONFIG_FILE} in the specified
    # `config_dir`.  These can be overridden.
    #
    # The YAML configuration files should be in the format:
    #
    #     ---
    #     basedir: 'sql'
    #     planfile: 'application.plan'
    #     migrations_dir: 'migrations-dir'
    #     migrations_table: 'application_migrations'
    #     connection_string: 'sequel connection string'
    #
    # See the individual access methods for details about each
    # setting.
    #
    # @see #basedir
    # @see #planfile
    # @see #migrations_dir
    # @see #migrations_table
    # @see #connection_string
    #
    # @param [String] config_dir The directory in which to look for
    #   configuration files.
    #
    # @param [Hash] opts Overrides for the default configuration file
    #   names and locations.
    #
    # @option opts [String] :config_file Override the default
    #   configuration file name and location.  This can be either a
    #   path relative to the `config_dir`, or an absolute path to the
    #   configuration file.
    #
    # @option opts [String] :user_config_file Override the default
    #   user specific configuration file name and location.  This can
    #   be either a path relative to the `config_dir`, or an absolute
    #   path to the configuration file.
    def initialize(config_dir,opts={})
      opts[:config_file]      ||= CONFIG_FILE
      opts[:user_config_file] ||= USER_CONFIG_FILE

      config_file_names = [opts[:config_file],opts[:user_config_file]].map do |f|
        File.expand_path(f,config_dir)
      end

      @config_dir = config_dir
      @config = Optimism.require(*config_file_names)
    end

    # The directory on which to base relative paths of other settings.
    # This directory itself is relative to `Dir.getwd` unless
    # specified as an absolute path.  This defaults to '.' (the
    # current working directory).
    #
    # @return [String] The absolute path to the directory specified in
    #   the config file.
    def basedir
      @basedir ||= File.expand_path(@config[:basedir] || '.', @config_dir)
    end

    # The file containing the list of migrations to be run in the
    # order that they should be run.  This is relative to {#basedir}
    # when specified in the configuration file, unless specified as an
    # absolute path.  Defaults to `hummingbird.plan`.
    #
    # @see #basedir
    #
    # @return [String] The absolute path to the plan file.
    def planfile
      @planfile ||= File.expand_path(@config[:planfile] || 'hummingbird.plan', basedir)
    end

    # The base directory for all migration files.  This is relative to
    # {#basedir} when specified in the configuration file, unless
    # specified as an absolute path.  Defaults to `migrations`.
    #
    # @see #basedir
    #
    # @return [String] The absolute path to the plan file.
    def migrations_dir
      @migrations_dir ||= File.expand_path(@config[:migrations_dir] || 'migrations', basedir)
    end

    # The name of the migrations table used to keep track of which
    # migrations have been successfully run, and when they were run.
    # Defaults to `hummingbird_migrations`.
    #
    # @return [Symbol] The name of the migrations table as a symbol.
    def migrations_table
      @migrations_table ||= (@config[:migrations_table] || :hummingbird_migrations).to_sym
    end

    # The {http://sequel.rubyforge.org/ Sequel} compatible connection
    # string.  This has no default, and must be specified in the
    # configuration file, or provided by another means.
    #
    # @return [String] Connection string to be passed to
    #   {http://sequel.rubyforge.org/ Sequel}.
    def connection_string
      @connection_string ||= @config[:connection_string]
    end
  end
end
