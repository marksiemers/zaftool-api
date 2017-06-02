require "./zaftool-api/environment.cr"

at_exit { PG_DB.close }
Kemal.run
PG_DB.close
