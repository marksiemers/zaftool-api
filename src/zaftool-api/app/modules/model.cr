module Model
  extend self

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
