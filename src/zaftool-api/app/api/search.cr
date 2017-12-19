class CacheRecord
  JSON.mapping(
    results: String,
    total_hits: UInt64,
    hits_since_update_timestamp: UInt64,
    first_hit: Time,
    last_hit: Time,
    create_timestamp: Time,
    update_timestamp: Time,
  )
  getter total_hits, first_hit, last_hit, create_timestamp, update_timestamp, hits_since_update_timestamp

  @refresh_proc : (Proc(String))?

  def initialize(&block : -> String)
    @results = block.call
    @total_hits = 0_u64
    @hits_since_update_timestamp = 0_u64
    @first_hit = Time.now
    @last_hit = Time.now
    @create_timestamp = Time.now
    @update_timestamp = Time.now
    @refresh_proc = block
  end

  def results
    @last_hit = Time.now
    @total_hits += 1
    @hits_since_update_timestamp += 1
    @results
  end

  def refresh
    if (refresh_proc = @refresh_proc)
      @update_timestamp = Time.now
      @hits_since_update_timestamp = 0_u64
      @results = refresh_proc.call
      return true
    else
      return false
    end
  end
end

module CacheOnFire
  alias CacheScope = Hash(String, CacheRecord)
  @@cache = {} of String => CacheScope

  def self.cache(item, scope = "global", &block : -> String)
    @@cache[scope] = {} of String => CacheRecord unless @@cache[scope]?
    @@cache[scope][item] ||= CacheRecord.new(&block)
    @@cache[scope][item].results
  end

  def self.records
    @@cache
  end

  def self.refresh_cache
    @@cache.each { |_, scope| refresh_scope(scope) }
    return true
  end

  def self.refresh_scope(scope_name : String)
    return false unless scope = @@cache[scope_name]?
    refresh_scope(scope)
  end

  private def self.refresh_scope(scope)
    scope.each { |_, item| item.refresh }
    return true
  end
end

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
