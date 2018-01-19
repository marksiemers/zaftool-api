class CacheOnFire::CacheRecord
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
