class CacheRecord
  JSON.mapping(
    results: String,
    hits: UInt64,
    first_hit: Time,
    last_hit: Time,
    cache_timestamp: Time
  )
  getter hits, first_hit, last_hit, cache_timestamp

  def initialize(@results : String)
    @hits = 0_u64
    @first_hit = Time.now
    @last_hit = Time.now
    @cache_timestamp = Time.now
  end

  def results
    @last_hit = Time.now
    @hits +=1
    @results
  end

  def results=(results)
    @cache_timestamp = Time.now
    @results = results
  end

end

SEARCH_CACHE = {
  "make" => {} of String => CacheRecord,
  "model" => {} of String => CacheRecord
}

def cache(scope, item, &block) : String
  SEARCH_CACHE[scope][item] ||= CacheRecord.new(yield)
  SEARCH_CACHE[scope][item].results
end

get "/search" do |env|
  env.response.content_type = "application/json"
  if (make = env.params.query["make"]?)
    cache("make", make) { Make.search(make).to_json }
  elsif (model = env.params.query["model"]?)
    cache("model", model) { Model.search(model).to_json }
  end
end

get "/search_cache" do |env|
  env.response.content_type = "application/json"
  SEARCH_CACHE.to_json
end
