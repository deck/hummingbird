class Hummingbird
  class PlanError < Exception
    attr_reader :already_run_migrations, :planned_files

    def initialize(msg,planned_files,already_run_migrations)
      super(msg)
      @planned_files = planned_files
      @already_run_migrations = already_run_migrations
    end
  end
end
