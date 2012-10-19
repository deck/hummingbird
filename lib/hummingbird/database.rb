require 'sequel'

module Hummingbird
  # Class to handle retrieving recorded migrations, as well as running
  # new migrations and recording that they have been run.
  class Database
    # @param [String] connection_string A
    #   {http://sequel.rubyforge.org/ Sequel} compatible connection string.
    #
    # @param [Symbol] migrations_table The name of the table used to
    #   keep track of migrations.
    def initialize(connection_string, migrations_table)
      @sequel_db                     = Sequel.connect(connection_string)
      @migrations_table_name         = migrations_table
      @prepared_run_migration_insert = nil
    end

    # @return [true, false] Whether or not the migrations table is
    #   present in the database.
    def initialized?
      @sequel_db.tables.include?(@migrations_table_name)
    end

    # If the database has yet to be initialized with the migrations
    # table, or if the migrations table has no recorded migrations,
    # this will return an empty array.
    #
    # If there are recorded migrations, this will return an array
    # of hashes.  Where the hashes have the following format:
    #
    #     {
    #       :migration_name => 'name/of/migration.sql',
    #       :run_on         => 1350683387
    #     }
    #
    # `:migration_name` is the path of the migration file relative to
    # the migrations directory.  `:run_on` is the time the migration
    # was run, as a unix epoch.
    #
    # @return [Array<Hash{Symbol => String, Number}>] The list of
    #   migrations that have already been run, along with when they
    #   were run as a unix epoch.
    def already_run_migrations
      initialized? ? @sequel_db[@migrations_table_name].order(:run_on).to_a : []
    end

    # Run the provided SQL in a transaction (provided the DB in
    # question supports transactions).  If the SQL successfully runs,
    # then also record the migration in the migration table.  The time
    # recorded for the `run_on` of the migration is when the migration
    # _finished_, not when it _started_.
    #
    # @param [String] name The name of the migration to run (as listed
    #   in the .plan file).
    #
    # @param [String] sql The SQL to run.
    def run_migration(name,sql)
      @prepared_run_migration_insert ||= @sequel_db[@migrations_table_name].prepare(:insert, :record_migration, migration_name: :$name, run_on: :$date)

      @sequel_db.transaction do
        @sequel_db.execute(sql)

        @prepared_run_migration_insert.call(name: name, date: DateTime.now.strftime('%s'))
      end

      true
    end
  end
end
