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
    username == "test_user" && password == "testing123"
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
  rank_name = params[:name]
  if rank_name.size == 0
    @error = "The rank name must be at least 1 character long."
    erb :create_rank
  else
    @storage.add_rank(rank_name)
  end

  redirect to("/my_ranks")
end

post "/delete_rank" do
  list_id = params[:list_id].to_i  # Access the list_id, not rank_id
  @storage.delete_rank(list_id)     # Delete the rank from the database
  redirect to("/my_ranks")          # Redirect back to the ranks page
end



# post "/seed" do
#   begin
#     settings.database.add_seed_data
#     session[:success] = "Successfully added seed data"
#   rescue PG::Error => e
#     # Handle the error and log it
#     session[:error] = "Error adding seed data: #{e.message}"
#   end
#   redirect to("/my_ranks")
# end


post "/logout" do 
  session.clear
  redirect '/'
end 
