get "/makes" do |env|
  env.response.content_type = "application/json"
  Make.all_as_json
end

get "/makes.ndjson" do |env|
  env.response.content_type = "application/x-ndjson"
  Make.all_as_ndjson(env.response.output)
end
