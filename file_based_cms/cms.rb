require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for" #lets you pass block into erb
require "tilt/erubis"
require 'redcarpet'
require 'yaml'
require "bcrypt"

helpers do 
	

	def page_not_found(file)
		"The specified page #{file} could not be found"
	end 

end 

def data_path
	  if ENV["RACK_ENV"] == "test"
	    File.expand_path("../test/data", __FILE__)
	  else
	    File.expand_path("../data", __FILE__)
	  end
	end 

	def pattern(file)
		File.join(data_path, "#{file}")
	end 

	def file_exists?(file)
		 !Dir.glob(pattern(file)).empty?
	end

	def load_file_contents(file)
		content = File.read(pattern(file))
		case File.extname(file)
		when ".txt"
			headers["Content-Type"] = "text/plain"
    	content
    when ".md"
    	render_markdown(content)
    end 
	end 

	def load_user_credentials 
		credentials_path = if ENV["RACK_ENV"] == "test"
			File.expand_path("../test/users.yml", __FILE__)
		else 
			File.expand_path("../users.yml", __FILE__)
		end 
		YAML.load_file(credentials_path)
	end

	def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end


	def filename_valid?(file_name)
		!file_name.strip.empty?
	end 

before do 
	@files = Dir.glob(pattern("*")).map do |path|
		File.basename(path) 
	end
end 

configure do 
	enable :sessions
	set :session_secret, "secret"
end

def load_users_passwords(file)
	load_file_contents(@yml_file)
end 

def signed_in? 
	session.key?(:username)
end 

def require_signed_in_user
	unless signed_in?
		session[:message] = "You must be signed in to do that"
		redirect "/"
	end 
end 

def render_markdown(text)
	markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
	markdown.render(text)
end 

get "/" do 
	redirect "/index"
end 

get "/users/sign_in" do 
	erb :sign_in, layout: :layout 
end 

get "/index" do 
	erb :home, layout: :layout
end 

get "/index/new" do 
		require_signed_in_user
		erb :new_document
end 

get "/index/:file_name" do 
	file_name = params[:file_name].to_s

	if file_exists?(file_name)
		load_file_contents(file_name)
	else
	 	session[:message] = page_not_found(file_name)
	 	redirect "/index"
	end 
end 

get "/index/:file_name/edit" do 
	@file_name = params[:file_name].to_s
	require_signed_in_user
	@contents = File.read(pattern(@file_name))
	erb :edit_file, layout: :layout
end 

# (file_path(@file_name)) => data/changes.txt


post "/users/sign_in" do 
	username = params[:username]
	password = params[:password]
	credentials = load_user_credentials 
	
	if valid_credentials?(username, password)
		session[:username] = username 
		session[:message] = "#{username} has succesfully signed in!"
		redirect "/index"
	else 
		session[:message] = "Username or password is invalid!"
		status 422
		erb :sign_in  
	end 
end 

post "/sign_out" do 
	session[:username] = nil 
	session[:message] = "You have been signed out"
	redirect "/index"
end 

post "/:file_name/edit" do 
	require_signed_in_user
	@file_name = params[:file_name]
	File.write(pattern(@file_name), params[:content])
	session[:message] = "#{@file_name} has been updated!"
	redirect "/index"
end

post "/create" do 
	require_signed_in_user
	file = params[:filename].to_s
	if filename_valid?(file)
		File.new("#{pattern(file)}", "w")
		session[:message] = "#{file} was successfully created!"
		redirect "/index"
	else 
		session[:message] = "File name must be valid!"
		status 422
		erb :new_document
	end 
end 

post "/index/:file_name/delete" do 
	require_signed_in_user
	file_name = params[:file_name].to_s
	File.delete(pattern(file_name))
	session[:message] = "#{file_name} has been deleted!"
	redirect "/index"
end 


# not_found do 
# 	session[:error] = 'The page does not exist'
# 	redirect "/index"
# end 

