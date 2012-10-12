require 'optimism'

class Hummingbird
  class Configuration
    CONFIG_FILE = 'hummingbird.yml'
    USER_CONFIG_FILE = '.hummingbird.yml'

    def initialize(config_dir)
      @config = Optimism.require(
        File.expand_path(File.join(config_dir, CONFIG_FILE)),
        File.expand_path(File.join(FileUtils.pwd, USER_CONFIG_FILE))
      )
    end

    def basedir
      @config[:basedir] || '.'
    end

    def planfile
      File.expand_path(File.join(basedir, @config[:planfile] || 'hummingbird.plan'))
    end

    def migrations_dir
      File.expand_path(File.join(basedir, @config[:migrations_dir] || 'migrations'))
    end

    def migrations_table
      (@config[:migrations_table] || :hummingbird_migrations).to_sym
    end
  end
end
