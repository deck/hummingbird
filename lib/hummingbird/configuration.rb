require 'optimism'

module Hummingbird
  class Configuration
    CONFIG_FILE = 'hummingbird.yml'
    USER_CONFIG_FILE = '.hummingbird.yml'

    def initialize(config_dir,opts={})
      opts[:config_file]      ||= CONFIG_FILE
      opts[:user_config_file] ||= USER_CONFIG_FILE

      config_file_names = [opts[:config_file],opts[:user_config_file]].map do |f|
        File.expand_path(f,config_dir)
      end

      @config_dir = config_dir
      @config = Optimism.require(*config_file_names)
    end

    def basedir
      @basedir ||= File.expand_path(@config[:basedir] || '.', @config_dir)
    end

    def planfile
      @planfile ||= File.expand_path(@config[:planfile] || 'hummingbird.plan', basedir)
    end

    def migrations_dir
      @migrations_dir ||= File.expand_path(@config[:migrations_dir] || 'migrations', basedir)
    end

    def migrations_table
      @migrations_table ||= (@config[:migrations_table] || :hummingbird_migrations).to_sym
    end

    def connection_string
      @connection_string ||= @config[:connection_string]
    end
  end
end
