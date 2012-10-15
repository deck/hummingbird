require 'sequel'

class Hummingbird
  class Database
    def initialize(config)
      @sequel_db = Sequel.connect(config.connection_string)
      @migrations_table_name = config.migrations_table
    end

    def initialized?
      @sequel_db.tables.include?(@migrations_table_name)
    end

    def already_run_migrations
      initialized? ? @sequel_db[@migrations_table_name].order(:run_on).to_a : []
    end
  end
end
