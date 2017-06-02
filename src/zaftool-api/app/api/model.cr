get "/models" do |env|
  env.response.content_type = "application/json"
  Model.all_as_json
end

get "/models.ndjson" do |env|
  env.response.content_type = "application/x-ndjson"
  Model.all_as_ndjson(env.response.output)
end
