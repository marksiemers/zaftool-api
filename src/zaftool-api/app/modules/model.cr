module Model
  extend self
  extend DbToJSON

  def all_as_json
    PG_DB.query("SELECT * FROM models") do |rs|
      result_set_to_json(rs)
    end
  end

  def all_as_ndjson(output)
    PG_DB.query("SELECT * FROM models") do |rs|
      rs.each do
        write_ndjson(output, rs.column_names, rs)
        output.flush
      end
    end
  end

  def search(model)
    results = [] of NamedTuple(name: String, type: String)
    PG_DB.query("SELECT name FROM models WHERE name % $1 LIMIT 10", model) do |rs|
      rs.each do
        result = { name: rs.read(String), type: "model" }
        results << result
      end
    end
    results
  end
end
