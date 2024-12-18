require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "pry"
require_relative "database_persistence"

configure do
  #set :logger, Logger.new($stdout)
  #set :database, Database.new(dbname: "ranked", logger: settings.logger)
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => false

  db = PG.connect(dbname: 'ranked') # Replace with your actual DB connection details

  # Check if the user already exists
  result = db.exec("SELECT COUNT(*) FROM users WHERE username = 'test_user'")

  # If the user doesn't exist, insert them
  if result.getvalue(0, 0).to_i == 0
    db.exec("INSERT INTO users (username, email) VALUES ('test_user', 'test_user@gmail.com')")
    puts "User 'test_user' created!"
  else
    puts "User 'test_user' already exists."
  end
  db.close
end

helpers do
  def valid_credentials?(username, password)
    # Hardcoded single user
    username == "test_user" && password == "qwerty"
  end
end

before do
  @storage = DatabasePersistence.new(logger)
end

################## ROUTES
##########################

get "/" do
    erb :index, layout: false
end

post "/login" do
    username = params[:username]
    password = params[:password]
    
    if valid_credentials?(username, password)
      session[:username] = username
      redirect "/my_ranks"
    else
      @error = "Invalid username or password. Please try again."
      erb :index, layout: false #to prevent the layout file rendering on unsuccessful login attempts
    end
end 

get '/my_ranks' do
  @lists = @storage.all_lists(session[:username])
  erb :my_ranks  # Render the 'my_ranks' view
end

get "/create_rank" do
  erb :create_rank
end

post "/seed" do 
  begin
    @storage.add_seed_data
    session[:success] = "Successfully added seed data"
  rescue PG::Error => e
    session[:error] = "Error adding seed data: #{e.message}"
  end
  redirect to("/my_ranks")
end

post "/save_rank" do
  rank_name = params[:name]  # Get the rank name from the form
  items = params[:items]  # Get the items array from the form
  # Validate rank name
  if rank_name.empty? || items.any? { |item| item.empty? }
    @error = "Rank name and all items are required."
    erb :create_rank  # Re-render the form with an error message
  else
    # Save the rank to the database
    @storage.add_rank(rank_name)
    
    # Get the user_id from the session (or hardcoded if needed)
    user_id = 1  # Hardcoded, replace with session[:user_id] if you have login
  
    # Get the rank ID (from the newly inserted rank)
    list_id = @storage.get_list_id_by_name(rank_name, user_id)
    
    # Save each item to the items table
    items.each do |item|
      @storage.add_item(item, list_id)  # Save each item to the items table
    end
    
    # Redirect to My Ranks page after saving the rank and items
    redirect to("/my_ranks")
  end
end



post "/delete_rank" do
  list_id = params[:list_id].to_i  # Access the list_id, not rank_id
  @storage.delete_rank(list_id)     # Delete the rank from the database
  redirect to("/my_ranks")          # Redirect back to the ranks page
end

# Route to show items of a specific rank
get '/my_ranks/:id' do
  list_id = params[:id].to_i

  begin
    @list = @storage.get_list_by_id(list_id)
    raise "List not found" if @list.nil?

    @items = @storage.get_items_for_list(list_id)
  rescue StandardError => e
    # Log the error for debugging
    logger.error "Error fetching list and items: #{e.message}"

    # Redirect to an error page or display an error message
    flash[:error] = "An error occurred. Please try again later."
    redirect to '/error'
  end

  erb :items
end

get '/my_ranks/:id' do
  list_id = params[:id].to_i  # Get the rank ID from the URL
  @list = @storage.get_list_by_id(list_id)  # Fetch the list details
  @items = @storage.get_items_for_list(list_id)  # Fetch items for the list
  erb :items  # Render the 'items.erb' page
end


post "/logout" do 
  session.clear
  redirect '/'
end 
