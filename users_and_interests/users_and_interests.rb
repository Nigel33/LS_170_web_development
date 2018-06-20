require 'tilt/erubis'
require "sinatra"
require "sinatra/reloader"
require "yaml"

before do
	@contents = YAML.load_file("data/data.yaml")
	@users = @contents.keys
end

get "/" do
	erb :home
end

get '/user/:user' do
	user = params[:user].to_sym
	@email = @contents[user][:email]
	@interests = @contents[user][:interests].join(", ")

  erb :user
end

helpers do

	def count_interests
		array = []
		@contents.each do |element|
			array << element[1][:interests].size
		end
		array.reduce(:+)
	end

end
