require "../modules/cache_on_fire/cache_on_fire"

get "/search" do |env|
  env.response.content_type = "application/json"
  if (make = env.params.query["make"]?)
    CacheOnFire.cache(make, scope: "make") { Make.search(make).to_json }
  elsif (model = env.params.query["model"]?)
    CacheOnFire.cache(model, scope: "model") { Model.search(model).to_json }
  end
end

get "/refresh_cache" do
  start = Time.now
  CacheOnFire.refresh_cache
  elapsed = Time.now - start
  milliseconds = (elapsed * 1_000).to_i
  records = CacheOnFire.records.values.reduce(0) { |sum, values| sum + values.keys.count(&.itself) }
  "Updated #{records} record(s) in #{milliseconds} milliseconds"
end

get "/search_cache" do |env|
  env.response.content_type = "application/json"
  CacheOnFire.records.to_json
end
