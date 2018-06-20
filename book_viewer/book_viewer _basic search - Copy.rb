
#initial
# require "sinatra"
# require "sinatra/reloader"

# get "/" do
#   File.read "public/template.html"
# end

#Using erb
require 'tilt/erubis'
require "sinatra"
require "sinatra/reloader"

# get "/" do
# 	@title = "The Adventures of Sherlock Holmes" #Adding dynamic value and changing value in home.erb
#   # @table_of_contents = File.read("data/toc.txt") #reading table of contents file
#   @contents = File.readlines("data/toc.txt") #load into array of strings
#   erb :home
# end
# get "/chapters/1" do
#   @title = "Chapter 1"
#   @contents = File.readlines("data/toc.txt")
#   @chapter = File.read("data/chp1.txt")

#   erb :chapter
# end
before do
	@contents = File.readlines("data/toc.txt")


end


get "/" do
	@title = "The Adventures of Sherlock Holmes" #Adding dynamic value and changing value in home.erb
  # @table_of_contents = File.read("data/toc.txt") #reading table of contents file
  # @contents = File.readlines("data/toc.txt") #load into array of strings
  erb :home
end
# get "/show/:name" do
#   params[:name]
# end
get "/chapters/:number" do
  number = params[:number].to_i
  # @contents = File.readlines("data/toc.txt")
  title_name = @contents[number - 1]
  redirect "/" unless (1..@contents.size).include?(number)
  @title = "Chapter #{number}, #{title_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

not_found do
	redirect "/"
end


helpers do
	def in_paragraphs(text)
		text.split("\n\n").map do |paragraph|
			"<p>#{paragraph}</p>"
		end.join
	end
end


def each_chapter
	@contents.each_with_index do |name, idx|
		number = idx + 1
		contents = File.read("data/chp#{number}.txt")
		yield(number, name, contents)
	end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
	result = []

	return results if !query || query.empty?

	each_chapter do |number, name, contents|
		result << {name: name, number: number } if contents.include?(query)
	end

	result
end

#adding in search form
get "/search" do
	@results = chapters_matching(params[:query])
	erb :search
end





