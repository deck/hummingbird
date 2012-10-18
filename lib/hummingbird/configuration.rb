require 'optimism'

class Hummingbird
  class Configuration
    CONFIG_FILE = 'hummingbird.yml'
    USER_CONFIG_FILE = '.hummingbird.yml'

    def initialize(config_dir)
      @config_dir = config_dir

      @config = Optimism.require(
        File.expand_path(File.join(config_dir, CONFIG_FILE)),
        File.expand_path(File.join(FileUtils.pwd, USER_CONFIG_FILE))
      )
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
