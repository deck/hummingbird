require 'pathname'

class Hummingbird
  class Plan
    attr_reader :migration_dir, :planned_files

    def initialize(config)
      @planned_files = parse_plan(config.planfile)
      @migration_dir = config.migration_dir
    end

    def migration_files
      @migration_files ||= get_migration_files
    end

    def files_missing_from_plan
      migration_files - planned_files
    end

    def files_missing_from_migration_dir
      planned_files - migration_files
    end

    private

    def parse_plan(planfile)
      File.read(planfile).split("\n")
    end

    def get_migration_files
      listing = Dir[File.join(migration_dir,'**','*')].select {|f| File.file? f}

      migration_path = Pathname.new(migration_dir)
      listing.map do |f|
        Pathname.new(f).relative_path_from(migration_path).to_s
      end
    end
  end
end
