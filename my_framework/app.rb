# # app.rb
# require_relative 'advice'

# class App
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


#part 4, refactoring call method to remove the method within an array literal

# require_relative 'advice'

# class App
#   def call(env)
#   case env['REQUEST_PATH']
#   when '/'
#     status = '200'
#     headers = {"Content-Type" => 'text/html'}
#     response(status, headers) do
#       erb :index
#     end
#   when '/advice'
#     piece_of_advice = Advice.new.generate
#     status = '200'
#     headers = {"Content-Type" => 'text/html'}
#     response(status, headers) do
#       erb :advice, message: piece_of_advice
#     end
#   else
#     status = '404'
#     headers = {"Content-Type" => 'text/html', "Content-Length" => '61'}
#     response(status, headers) do
#       erb :not_found
#     end
#   end
# end

# def response(status, headers, body = '')
#   body = yield if block_given?
#   [status, headers, [body]]
# end

#   private

#   def erb(filename, local = {})
#     b = binding
#     message = local[:message]
#     content = File.read("views/#{filename}.erb")
#     ERB.new(content).result(b)
#   end
# end

#Start of framework (extracting common methods to monroe)

require_relative 'advice'
require_relative 'monroe'

class App < Monroe
  def call(env)
    case env['REQUEST_PATH']
    when '/'
      status = '200'
      headers = {"Content-Type" => 'text/html'}
      response(status, headers) do
        erb :index
      end
    when '/advice'
      piece_of_advice = Advice.new.generate
      status = '200'
      headers = {"Content-Type" => 'text/html'}
      response(status, headers) do
        erb :advice, message: piece_of_advice
      end
    else
      status = '404'
      headers = {"Content-Type" => 'text/html', "Content-Length" => '61'}
      response(status, headers) do
        erb :not_found
      end
    end
  end
end

