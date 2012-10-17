require 'hummingbird/plan_error'

require 'pathname'

class Hummingbird
  class Plan
    attr_reader :migration_dir, :planned_files

    def initialize(planfile, migration_dir)
      @planned_files = parse_plan(planfile)
      @migration_dir = migration_dir
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

    def migrations_to_be_run(already_run_migrations)
      to_be_run_migration_file_names(already_run_migrations).map do |f|
        {
          migration_name: f,
          sql: get_migration_contents(f)
        }
      end
    end

    def to_be_run_migration_file_names(already_run_migrations)
      return planned_files if already_run_migrations.empty?

      unless (run_migrations_missing_from_plan = already_run_migrations.map {|a| a[:migration_name]} - planned_files).empty?
        raise Hummingbird::PlanError.new("Plan is missing the following already run migrations: #{run_migrations_missing_from_plan.join(', ')}",planned_files,already_run_migrations)
      end

      files = planned_files.dup
      already_run_migrations.each do |f|
        if f[:migration_name] == files.first
          files.shift
        else
          first_out_of_sync_run_on = DateTime.strptime(f[:run_on].to_s, '%s')

          raise Hummingbird::PlanError.new("Plan has '#{files.first}' before '#{f[:migration_name]}' which was run on #{first_out_of_sync_run_on}",planned_files,already_run_migrations)
        end
      end

      files
    end

    def get_migration_contents(migration_file)
      File.read(File.absolute_path(migration_file, @migration_dir))
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
