require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for" #lets you pass block into erb
require "tilt/erubis"
require 'redcarpet'

helpers do 
	def file_path(file)
		Dir.glob("data/#{file}").join
	end 

	def file_exists?(file)
		!file_path(file).empty?
	end

	def load_file_contents(file)
		content = File.read(file_path(file))
		case File.extname(file)
		when ".txt"
			headers["Content-Type"] = "text/plain"
    	content
    when ".md"
    	render_markdown(content)
    end 
	end 

	def page_not_found(file)
		"The specified page #{file} could not be found"
	end 
end 

before do 
	@files = Dir.glob("data/*").map do |path|
		File.basename(path)
	end 
end 

configure do 
	enable :sessions
	set :session_secret, "secret"
end 

def render_markdown(text)
	markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
	markdown.render(text)
end 

get "/" do 
	redirect "/index"
end 

get "/index" do 
	erb :home 
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
	@file_name = params[:file_name]
	@contents = File.read(file_path(@file_name))
	erb :edit_file 
end 

# (file_path(@file_name)) => data/changes.txt

post "/:file_name/edit" do 
	@file_name = params[:file_name]
	File.write(file_path(@file_name), params[:content])
	session[:message] = "#{@file_name} has been updated!"
	redirect "/index"
end


# not_found do 
# 	session[:error] = 'The page does not exist'
# 	redirect "/index"
# end 

