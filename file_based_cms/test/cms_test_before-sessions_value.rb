ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "fileutils"

require_relative "../cms"

class CmsTest < Minitest::Test
	include Rack::Test::Methods

	def app
		Sinatra::Application 
	end 

	def setup 
		FileUtils.mkdir_p(data_path)
	end 

	def teardown
		FileUtils.rm_rf(data_path)
	end 

	def create_document(name, content = "")
		File.open(File.join(data_path,name), "w") do |file|
			file.write(content)
		end 
	end 

	def session 
		last_request.env["rack.session"]
	end 

	def test_index 
		create_document "about.txt"
		create_document "changes.txt"

		get "/index"
		assert_equal 200, last_response.status
		assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
		assert_includes last_response.body, "changes.txt"
		assert_includes last_response.body, "about.txt"
	end 

	def test_redirect
		get "/"
		assert_equal 302, last_response.status
		assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
	end 

	def test_view_file
		create_document "history.txt", "Ruby 0.95 released"

    get "/index/history.txt"

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Ruby 0.95 released"
  end

	def test_nonexistent 
		get "/index/notes.txt"

		assert_equal 302, last_response.status 

		get last_response["Location"]

		assert_equal 200, last_response.status 
		assert_includes last_response.body, 'The specified page notes.txt could not be found'
	end 

	def test_get_edit 
		create_document "changes.txt"

		get  "/index/changes.txt/edit"

		assert_equal 200, last_response.status 
		assert_includes last_response.body, "<textarea"
		assert_includes last_response.body, %q(<button type="submit") 
	end 

	def test_update_file 
		create_document "changes.txt"

		post"/changes.txt/edit", content: "Testing text"

		assert_equal 302, last_response.status

		get last_response["Location"]
		assert_equal 200, last_response.status 
		assert_includes last_response.body, "changes.txt has been updated"

		get "/index/changes.txt"

		assert_equal 200, last_response.status 
		assert_includes last_response.body, "Testing text"
	end 

	def test_get_new_doc 
		get "/index/new"

		assert_equal 200, last_response.status 
		assert_includes last_response.body, "Add a new document"
	end 

	def test_create_new_doc 
		post "/create", filename: "test.txt"

		assert_equal 302, last_response.status
		
		get last_response["Location"]
		assert_equal 200, last_response.status 
		assert_includes last_response.body, "test.txt"
		assert_includes last_response.body, "test.txt was successfully created!" 
	end 

	def test_create_new_doc_fail
		post "/create", filename: ""

		assert_equal 200, last_response.status 
		assert_includes last_response.body, "File name must be valid!"
	end 

	def test_delete_file 
		create_document "test.txt"
		post "/index/test.txt/delete"

		assert_equal 302, last_response.status

		get last_response["Location"]
		assert_equal 200, last_response.status
		assert_includes last_response.body, "test.txt has been deleted!"
	end 

	def test_get_sign_in 
		get "/users/sign_in" 

		assert_equal 200, last_response.status
		assert_includes last_response.body, "Username:"
		assert_includes last_response.body, "Password:" 
	end 

	def test_sign_in_success 
		post "/users/sign_in", username: "admin" , password: "secret"

		assert_equal 302, last_response.status
		get last_response["Location"]
		assert_equal 200, last_response.status
		assert_includes last_response.body, "You have succesfully signed in!"
	end 

	def test_sign_in_failure
		post "/users/sign_in", username: "agfg" , password: "secrgfg"

		assert_equal 200, last_response.status
		assert_includes last_response.body, "Username or password is invalid!"
	end  

	def test_sign_out 
		post "/sign_out"

		assert_equal 302, last_response.status
		get last_response["Location"]
		assert_equal 200, last_response.status
		assert_includes last_response.body, "You have been signed out"
	end 
	# def test_markdown 
	# 	get "/index/about.md"

	# 	assert_equal 200, last_response.status 
	# 	assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
	# end 
end 