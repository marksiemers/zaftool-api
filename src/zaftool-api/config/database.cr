CONN = ENV["DATABASE_URL"]? || "postgres://postgres@localhost:5432/zaftool_development"
PG_DB = DB.open(CONN)
