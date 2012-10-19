require 'hummingbird/plan_error'

require 'pathname'

module Hummingbird
  # This is responsible for parsing the `.plan` file, and for
  # verifying it against the migrations stored on disk.
  class Plan
    # @return [String] The base directory for all of the migration
    #   files referenced in the `.plan` file.
    attr_reader :migration_dir

    # This list has not been verified against the files on disk, or
    # against the database in any way.
    #
    # @return [Array<String>] The list of all files referenced in the
    #   `.plan` file.
    attr_reader :planned_files

    # @param [String] planfile The path to the `.plan` file.
    #
    # @param [String] migration_dir The path to the base directory for
    #   all of the migration files referenced in the `.plan` file.
    def initialize(planfile, migration_dir)
      @planned_files = parse_plan(planfile)
      @migration_dir = migration_dir
    end

    # @return [Array<String>] All files found under {#migration_dir}.
    def migration_files
      @migration_files ||= get_migration_files
    end

    # @return [Array<String>] All {#migration_files} that are not in
    #   {#planned_files}.
    def files_missing_from_plan
      migration_files - planned_files
    end

    # If this list is not empty, there is probably an error as there
    # are files that have been planned to run that do not exist on
    # disk.
    #
    # @return [Array<String>] All {#planned_files} that are not in
    #   {#migration_files}.
    def files_missing_from_migration_dir
      planned_files - migration_files
    end

    # The names, and SQL for migrations that have yet to be run
    # according to the list of already run migrations in
    # `already_run_migrations`.
    #
    # This delegates to {#to_be_run_migration_file_names} and attaches
    # the associated SQL to each migration.
    #
    # @see #to_be_run_migration_file_names
    # @see Hummingbird::Database#already_run_migrations
    #
    # @param [Array<Hash{Symbol => String}>] already_run_migrations
    #   This takes the same format array as output by
    #   {Hummingbird::Database#already_run_migrations}.
    #
    # @return [Array<Hash{Symbol => String}>] This is the list of
    #   migrations to be run, with their associated SQL as
    #   `[{ :migration_name => String, :sql => String }, ...]`.
    #
    # @raise [Hummingbird::PlanError] If any of the
    #   already_run_migrations are not in the list of planned files.
    #
    # @raise [Hummingbird::PlanError] If any of the
    #   if any of the files in already_run_migrations appear out of
    #   order relative to the planned files.
    def migrations_to_be_run(already_run_migrations)
      to_be_run_migration_file_names(already_run_migrations).map do |f|
        {
          migration_name: f,
          sql: get_migration_contents(f)
        }
      end
    end

    # It compares `already_run_migrations` against the list of planned
    # migrations, and return the list of migrations that have yet to
    # be run.
    #
    # @see Hummingbird::Database#already_run_migrations
    #
    # @param [Array<Hash{Symbol => String}>] already_run_migrations
    #   This takes the same format array as output by
    #   {Hummingbird::Database#already_run_migrations}.
    #
    # @return [Array<String>] The list of migration names that have
    #   not yet been run.
    #
    # @raise [Hummingbird::PlanError] If any of the
    #   already_run_migrations are not in the list of planned files.
    #
    # @raise [Hummingbird::PlanError] If any of the
    #   if any of the files in already_run_migrations appear out of
    #   order relative to the planned files.
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

    # Return the contents of the specified migration file.
    #
    # @param [String] migration_file The path to the desired migration
    #   file, relative to {#migration_dir}.
    #
    # @return [String] The contents of the specified migration file.
    def get_migration_contents(migration_file)
      File.read(File.expand_path(migration_file, @migration_dir))
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
