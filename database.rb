#all interactions with database

require "pg"
require "logger"

class Database
  def initialize(dbname: "ranked", logger:)
    @dbname = dbname  # Store the dbname in an instance variable
    @logger = logger  # Store the logger
    @conn = nil  # Initialize the @conn variable to nil
    connect  # Establish the connection during initialization using the conect method
  end

  # Method to establish the database connection
  def connect
    # If a connection already exists, return it
    return @conn if @conn

    # Establish a new connection
    @conn = PG.connect(dbname: @dbname)
    @logger.info("Connected to the database #{@dbname}")  # Log successful connection
  end

  # Method to close the connection
  def close
    if @conn
      @conn.close
      @logger.info("Database connection closed")  # Log when connection is closed
    end
  end
end
