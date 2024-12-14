
-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Lists Table
CREATE TABLE IF NOT EXISTS lists (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,  -- Name of the list (e.g., "Favorite Recipes")
  user_id INTEGER REFERENCES users(id),  -- Foreign key to the Users table
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Items table
CREATE TABLE IF NOT EXISTS items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,  -- Name of the item (e.g., "Chocolate Cake" or "The Beatles")
  description TEXT,  -- Optional: Description of the item (e.g., recipe instructions, song details)
  list_id INTEGER REFERENCES lists(id),  -- Foreign key to the Lists table
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
