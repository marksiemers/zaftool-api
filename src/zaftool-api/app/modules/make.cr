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
    results = [] of NamedTuple(name: String, type: String)
    PG_DB.query("SELECT name FROM makes WHERE name % $1 LIMIT 10", make) do |rs|
      rs.each do
        result = { name: rs.read(String), type: "make" }
        results << result
      end
    end
    results
  end
end
