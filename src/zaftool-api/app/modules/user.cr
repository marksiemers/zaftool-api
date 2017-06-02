module User
  extend self

  def all
    users = [] of NamedTuple(name: String, email: String)
    sql = "SELECT name, email FROM users"
    PG_DB.query(sql) do |rs|
      rs.each do
        user = { name: rs.read(String), email: rs.read(String) }
        users << user
      end
    end
    users
  end

end
