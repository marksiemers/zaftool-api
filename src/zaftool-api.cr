require "kemal"
require "json"
require "pg"
require "./zaftool-api/*"

PG_DB = DB.open("postgres://postgres@localhost:5432/zaftool_development")
at_exit { PG_DB.close }

get "/" do |env|
  env.response.content_type = "application/json"
  users = [] of NamedTuple(name: String, email: String)
  sql = "SELECT name, email FROM users"
  PG_DB.query(sql) do |rs|
    rs.each do
      user = { name: rs.read(String), email: rs.read(String) }
      users << user
    end
  end
  users.to_json
end

def search_for_make(make)
  results = [] of NamedTuple(name: String, type: String)
  PG_DB.query("SELECT name FROM makes WHERE name % $1 LIMIT 10", make) do |rs|
    rs.each do
      result = { name: rs.read(String), type: "make" }
      results << result
    end
  end
  results
end

def search_for_model(model)
  results = [] of NamedTuple(name: String, type: String)
  PG_DB.query("SELECT name FROM models WHERE name % $1 LIMIT 10", model) do |rs|
    rs.each do
      result = { name: rs.read(String), type: "model" }
      results << result
    end
  end
  results
end

get "/search" do |env|
  env.response.content_type = "application/json"
  results = [] of NamedTuple(name: String, type: String)
  if env.params.query["make"]?
    results = search_for_make(env.params.query["make"])
  elsif env.params.query["model"]?
    results = search_for_model(env.params.query["model"])
  end
  results.to_json
end

Kemal.run
PG_DB.close
