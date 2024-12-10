require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, :escape_html => true
end

helpers do
end

class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end
end

before do
  @storage = SessionPersistence.new(session)
end

################## ROUTES
##########################

get "/" do
    erb :index
end

post "/login" do
    users = { "test_user" => "password" }
    
    username = params[:username]
    password = params[:password]
    #need to add validation logic later
    
    if users[username] && users[username] == password
      redirect "/lists"
    else
      @error = "Invalid username or password. Please try again."
      erb :index
    end
end 

get "/lists" do
  erb :lists
end 

