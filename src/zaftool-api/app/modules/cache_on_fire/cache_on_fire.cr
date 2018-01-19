require "./cache_record"

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
