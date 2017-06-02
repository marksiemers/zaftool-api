get "/users" do |env|
  env.response.content_type = "application/json"
  User.all.to_json
end
