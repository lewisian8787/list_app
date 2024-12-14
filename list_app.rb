require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => false
end

helpers do
  def valid_credentials?(username, password)
    # Hardcoded single user
    username == "test_user" && password == "password"
  end
end

class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end
end

before do
  @storage = SessionPersistence.new(session)
  content_type :html
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
      redirect "/myranks"
    else
      @error = "Invalid username or password. Please try again."
      #@username = username #preserving the username for future attempts
      erb :index, layout: false #to prevent the layout file rendering on unsuccessful login attempts
    end
end 

get "/myranks" do
  erb :myranks
end

get "/create_rank" do
  erb :create_rank
end

post "/save_rank" do
  #yet to do this. Button to save new rank not yet working. 
end 

post "/logout" do 
  session.clear
  redirect '/'
end 
