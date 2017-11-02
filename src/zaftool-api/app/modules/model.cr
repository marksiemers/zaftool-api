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
    search_query(model)
  end

  def search_query(model)
    results = [] of NamedTuple(id: Int32, name: String, similarity: Float32)
    query = <<-SQL
      SELECT id, full_name, similarity($2, make_and_model_name) AS similarity
      FROM model_years_matview
      WHERE (make_and_model_name ILIKE $1)
      ORDER BY similarity($2, make_and_model_name)
      DESC LIMIT 10
      SQL

    PG_DB.query(query, ["%#{model}%", model]) do |rs|
      rs.each do
        result = { id: rs.read(Int32), name: rs.read(String), similarity: rs.read(Float32) }
        results << result
      end
    end
    results
  end
end
