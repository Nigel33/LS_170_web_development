require_relative 'advice'

#original
# class HelloWorld
# 	def call(env)
# 		case env['REQUEST_PATH']
# 		when '/'
# 			['200', {'Content-Type' => 'text/plain'}, ["Hello worl!"]]
# 		when '/advice'
# 			piece_of_advice = Advice.new.generate
# 			['200', {'Content-Type' => 'text/plain'}, [piece_of_advice]]
# 		else
# 			[
#         '404',
#         {"Content-Type" => 'text/plain', "Content-Length" => '13'},
#         ["404 Not Found"]
#       ]
#     end
# 	end
# end

#updated Part 2

# class HelloWorld
#   def call(env)
#     case env['REQUEST_PATH']
#     when '/'
#       [
#         '200',
#         {"Content-Type" => 'text/html'},
#         ["<h2>Hello World!</h2>"]
#       ]
#     when '/advice'
#       piece_of_advice = Advice.new.generate
#       [
#         '200',
#         {"Content-Type" => 'text/html'},
#         ["<html><body><b><em>#{piece_of_advice}</em></b></body></html>"]
#       ]
#     else
#       [ number is: <%= random_number %>!</p></body></html>")
# => #<ERB:0x007fa2d298e410 ... >
#
# irb(main):008:0> content2.result
# => "<html><body><p>The number is: 8!</p></body></html>"

#         '404',
#         {"Content-Type" => 'text/html', "Content-Length" => '48'},
#         ["<html><body><h4>404 Not Found</h4></body></html>"]
#       ]
#     end
#   end
# end

#Updated Part 3
# hello_world.rb

# class HelloWorld
#   def call(env)
#     case env['REQUEST_PATH']
#     when '/'
#       template = File.read("views/index.erb")
#       content = ERB.new(template)
#       ['200', {"Content-Type" => "text/html"}, [content.result]]
#     when '/advice'
#       piece_of_advice = Advice.new.generate
#       [
#         '200',
#         {"Content-Type" => 'text/html'},
#         ["<html><body><b><em>#{piece_of_advice}</em></b></body></html>"]
#       ]
#     else
#       [
#         '404',
#         {"Content-Type" => 'text/html', "Content-Length" => '48'},
#         ["<html><body><h4>404 Not Found</h4></body></html>"]
#       ]
#     end
#   end
# end

#Part 4 (extract file processing code)
# hello_world.rb

# class HelloWorld
#   def call(env)
#     case env['REQUEST_PATH']
#     when '/'
#       ['200', {"Content-Type" => "text/html"}, [erb(:index)]]
#     when '/advice'
#       piece_of_advice = Advice.new.generate
#       [
#         '200',
#         {"Content-Type" => 'text/html'},
#         ["<html><body><b><em>#{piece_of_advice}</em></b></body></html>"]
#       ]
#     else
#       [
#         '404',
#         {"Content-Type" => 'text/html', "Content-Length" => '48'},
#         ["<html><body><h4>404 Not Found</h4></body></html>"]
#       ]
#     end
#   end

#   private

#   def erb(filename)
#     content = File.read("views/#{filename}.erb")
#     ERB.new(content).result
#   end
# end

#Part 4.a (updating erb method after creating advice and not found .erbs)
# hello_world.rb

class HelloWorld
  def call(env)
    case env['REQUEST_PATH']
    when '/'
      ['200', {"Content-Type" => "text/html"}, [erb(:index)]]
    when '/advice'
      piece_of_advice = Advice.new.generate
      [
        '200',
        {"Content-Type" => 'text/html'},
        ["<html><body><b><em>#{piece_of_advice}</em></b></body></html>"]
      ]
    else
      [
        '404',
        {"Content-Type" => 'text/html', "Content-Length" => '48'},
        ["<html><body><h4>404 Not Found</h4></body></html>"]
      ]
    end
  end

  private

  def erb(filename)
    content = File.read("views/#{filename}.erb")
    ERB.new(content).result
  end
end
