get "/search" do |env|
  env.response.content_type = "application/json"
  if env.params.query["make"]?
    results = Make.search(env.params.query["make"])
  elsif env.params.query["model"]?
    results = Model.search(env.params.query["model"])
  end
  results.to_json
end
