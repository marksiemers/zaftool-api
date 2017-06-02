module Make
  extend self

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
