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

  def get_list_id_by_name(rank_name, user_id)
    sql = "SELECT id FROM lists WHERE name = $1 AND user_id = $2"
    result = @db.exec_params(sql, [rank_name, user_id])
    result[0]["id"].to_i
  end

  # Method to add an item to the items table
  def add_item(item_name, list_id)
    sql = "INSERT INTO items (name, list_id) VALUES ($1, $2)"
    @db.exec_params(sql, [item_name, list_id])
  end

  def get_list_by_id(list_id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, list_id)
    tuple = result[0]  # There should be only one row returned
    { id: tuple["id"], name: tuple["name"], user_id: tuple["user_id"].to_i }
  end

  def get_items_for_list(list_id)
    sql = "SELECT * FROM items WHERE list_id = $1"
    result = query(sql, list_id)

    result.map do |tuple|
      { id: tuple["id"], name: tuple["name"], list_id: tuple["list_id"].to_i }
    end
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
    logged_in_user_id = result[0]["id"].to_i

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
  
    # Insert test items into items table (no description column)
    sql_items = <<~SQL
      INSERT INTO items (name, list_id)
      VALUES 
        -- Items for "Favorite Recipes" (list_id = 1)
        ('Spaghetti Bolognese', 1),
        ('Chicken Curry', 1),
        ('Chocolate Cake', 1),
        ('Grilled Cheese Sandwich', 1),
        ('Caesar Salad', 1),
        ('Beef Stroganoff', 1),
        ('Vegetable Stir Fry', 1),
        ('BBQ Ribs', 1),
        ('Apple Pie', 1),
        ('Fish Tacos', 1),
          
        -- Items for "Favorite Action Movies" (list_id = 2)
        ('Die Hard', 2),
        ('Mad Max: Fury Road', 2),
        ('The Dark Knight', 2),
        ('John Wick', 2),
        ('The Matrix', 2),
        ('Gladiator', 2),
        ('Terminator 2: Judgment Day', 2),
        ('Inception', 2),
        ('Mission: Impossible - Fallout', 2),
        ('Black Panther', 2),
    
        -- Items for "Favorite Love Songs" (list_id = 3)
        ('I Will Always Love You', 3),
        ('Perfect', 3),
        ('My Heart Will Go On', 3),
        ('Unchained Melody', 3),
        ('Endless Love', 3),
        ('All of Me', 3),
        ('I Can Not Handle This', 3),
        ('At Last', 3),
        ('Thinking Out Loud', 3),
        ('Something', 3);
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
