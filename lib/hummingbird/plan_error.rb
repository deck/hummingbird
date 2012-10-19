module Hummingbird
  # Exception class with extra information available to examine what
  # caused a validation error comparing the planned migrations against
  # the recorded migrations.
  class PlanError < Exception
    # @see Hummingbird::Database#already_run_migrations
    #
    # @return [Array<Hash{Symbol => String}>] The
    #   {Hummingbird::Database#already_run_migrations} at the time of
    #   the plan error.
    attr_reader :already_run_migrations

    # @see Hummingbird::Plan#planned_files
    #
    # @return [Array<String>] The {Hummingbird::Plan#planned_files} at
    #   the time of the plan error.
    attr_reader :planned_files

    # @see Hummingbird::Database#already_run_migrations
    # @see Hummingbird::Plan#planned_files
    #
    # @param [String] msg A user friendly explanation of what
    #   triggered the PlanError.
    #
    # @param [Array<String>] planned_files The
    #   {Hummingbird::Plan#planned_files} at the time of the plan
    #   error.
    #
    # @param [Array<Hash{Symbol => String}>] already_run_migrations
    #   The {Hummingbird::Database#already_run_migrations} at the time
    #   of the plan error.
    def initialize(msg,planned_files,already_run_migrations)
      super(msg)
      @planned_files = planned_files
      @already_run_migrations = already_run_migrations
    end
  end
end
