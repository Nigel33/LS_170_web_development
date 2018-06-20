require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for' #lets you pass block into erb
require 'tilt/erubis'
require 'redcarpet'
require 'date'
require 'rubocop'


configure do
	enable :sessions
	set :session_secret, "secret"
end

before do
	session[:temporary] ||= {}
	session[:data] ||= []
end

def load_params
	first_name = params[:first_name].strip
	last_name = params[:last_name].strip
	card_no = params[:card_no].strip
	exp_date = params[:exp_date].strip
	ccv = params[:ccv].strip
	date_created = Date
	{
			"First name" => first_name,
			"Last name" => last_name,
			"Time" => Time.now.to_s,
			"Card number" => card_no,
			"Expiration date"=> exp_date,
			"CCV" => ccv
	}
end

def filter_empty_data (data_set)
	solution = data_set.select {|key, value| value.size == 0}
end

def error?(data_set)
	!data_set.empty? || invalid_card_number?
end

def error_message(filtered_data)
	message = []
	if invalid_card_number?
		message << "Credit card number must be 16 digits"
	end

	if !filtered_data.empty?
		message << filtered_data.keys.join(", ") + " is missing"
	end
	message.join("</br>")
end

def invalid_card_number?
	params[:card_no].size != 16
end

helpers do
	def render_card_number(number)
		output = "****-****-****-#{number[12,4]}"
	end

	def render_name (first_name, last_name)
		first_name + " " + last_name
	end
end

get "/" do
	session[:data] = nil
	session[:temporary] = nil
	redirect "/payments/create"
end

get "/payments/new" do
	session[:temporary] = nil
	redirect "/payments/create"
end

get "/payments/create" do
	@data = session[:temporary]
	erb :payment_page, layout: :layout
end

get "/payments/confirmation" do
	@data = session[:data]
	erb :confirmation
end

post "/payments/create" do
	session[:temporary] = load_params
	result = filter_empty_data(session[:temporary])
	if error?(result)
		session[:message] = error_message(result)
		redirect "/payments/create"
	else
		session[:data] << session[:temporary]
		session[:message] = "Thank you for your payment!"
		redirect "/payments/confirmation"
	end
end
