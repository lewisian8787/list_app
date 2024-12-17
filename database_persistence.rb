#all interactions with database

require "pg"
require "logger"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "ranked")
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def add_rank(rank_name)
    sql = "INSERT INTO lists (name, user_id) VALUES ($1, 1)"
    @db.exec_params(sql, [rank_name])
  end

  def delete_rank(rank_id)
    sql = "DELETE FROM lists WHERE id = $1"
    @db.exec_params(sql, [rank_id])
  end

  def all_lists(username)
    # Obtain user id of logged in user from the users table
    sql = "SELECT id FROM users WHERE username = $1;"
    result = query(sql, username)
    logged_in_user_id = result.ntuples

    sql = "SELECT * FROM lists WHERE user_id = $1;"
    result = query(sql, logged_in_user_id)

    result.map do |tuple|
      { id: tuple["id"], name: tuple["name"], user_id: tuple["user_id"].to_i }
    end
  end

  def add_seed_data
    # Insert test ranks into lists table
    sql_lists = <<~SQL
      INSERT INTO lists (name, user_id)
      VALUES 
        ('Favorite Recipes', 1),
        ('Favorite Action Movies', 1),
        ('Favorite Love Songs', 1);
    SQL
    query(sql_lists)
  
    # Insert test items into items table
    sql_items = <<~SQL
      INSERT INTO items (name, description, list_id)
      VALUES 
        -- Items for "Favorite Recipes" (list_id = 1)
        ('Spaghetti Bolognese', NULL, 1),
        ('Chicken Curry', NULL, 1),
        ('Chocolate Cake', NULL, 1),
        ('Grilled Cheese Sandwich', NULL, 1),
        ('Caesar Salad', NULL, 1),
        ('Beef Stroganoff', NULL, 1),
        ('Vegetable Stir Fry', NULL, 1),
        ('BBQ Ribs', NULL, 1),
        ('Apple Pie', NULL, 1),
        ('Fish Tacos', NULL, 1),
        
        -- Items for "Favorite Action Movies" (list_id = 2)
        ('Die Hard', NULL, 2),
        ('Mad Max: Fury Road', NULL, 2),
        ('The Dark Knight', NULL, 2),
        ('John Wick', NULL, 2),
        ('The Matrix', NULL, 2),
        ('Gladiator', NULL, 2),
        ('Terminator 2: Judgment Day', NULL, 2),
        ('Inception', NULL, 2),
        ('Mission: Impossible - Fallout', NULL, 2),
        ('Black Panther', NULL, 2),
  
        -- Items for "Favorite Love Songs" (list_id = 3)
        ('I Will Always Love You', NULL, 3),
        ('Perfect', NULL, 3),
        ('My Heart Will Go On', NULL, 3),
        ('Unchained Melody', NULL, 3),
        ('Endless Love', NULL, 3),
        ('All of Me', NULL, 3),
        ('I Can Not Handle This', NULL, 3),
        ('At Last', NULL, 3),
        ('Thinking Out Loud', NULL, 3),
        ('Something', NULL, 3);
    SQL
    query(sql_items)
  end
  
  

#   Method to establish the database connection
#   def connect
#     # If a connection already exists, return it
#     return @conn if @conn

#     # Establish a new connection
#     @conn = PG.connect(dbname: @dbname)
#   end

#   # Method to close the connection
#   def close
#     if @conn
#       @conn.close
#     end
#   end
end
