require 'sequel'

module Hummingbird
  class Database
    def initialize(connection_string, migrations_table)
      @sequel_db                     = Sequel.connect(connection_string)
      @migrations_table_name         = migrations_table
      @prepared_run_migration_insert = nil
    end

    def initialized?
      @sequel_db.tables.include?(@migrations_table_name)
    end

    def already_run_migrations
      initialized? ? @sequel_db[@migrations_table_name].order(:run_on).to_a : []
    end

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
