module Make
  extend self
  extend DbToJSON

  def all_as_json
    PG_DB.query("SELECT * FROM makes") do |rs|
      result_set_to_json(rs)
    end
  end

  def all_as_ndjson(output)
    PG_DB.query("SELECT * FROM makes") do |rs|
      rs.each do
        write_ndjson(output, rs.column_names, rs)
        output.flush
      end
    end
  end

  def search(make)
    search_query(make)
  end

  def search_query(make)
    results = [] of NamedTuple(id: Int32, name: String, type: String)
    PG_DB.query("SELECT id, name FROM makes WHERE name % $1 LIMIT 10", make) do |rs|
      rs.each do
        result = {id: rs.read(Int32), name: rs.read(String), type: "make"}
        results << result
      end
    end
    results
  end
end
