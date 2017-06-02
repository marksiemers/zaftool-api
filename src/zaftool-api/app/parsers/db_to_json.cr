module DbToJSON
  def result_set_to_json(rs)
    JSON.build do |json|
      json.array do
        rs.each{ result_row_insert_in_json(json, rs) }
      end
    end
  end

  def result_row_insert_in_json(json, rs)
    col_names = rs.column_names
    json.object do
      col_names.each{|col| json_encode_field json, col, rs.read }
    end
  end

  def write_json(io, cols, rs)
    JSON.build(io) do |json|
      json.object do
        cols.each{|col| json_encode_field(json, col, rs.read) }
      end
    end
  end

  def write_ndjson(io, cols, rs)
    write_json(io, cols, rs)
    io << "\n"
  end

  def custom_encode(json, col, value)
    json.field col do
      json.array do
        value.each{|e| json.scalar e }
      end
    end
  end

  def json_encode_field(json, col, value)
    case value
    when Bytes
      custom_encode(json, col, value)
    when NotSupported
      # skip
    else
      json.field(col){ value.to_json(json) }
    end
  end

  alias NotSupported = PG::Geo::Point | PG::Geo::Box | PG::Geo::Circle |
                       PG::Geo::Line | PG::Geo::LineSegment | PG::Geo::Path |
                       PG::Geo::Polygon | PG::Numeric |
                       Array(PG::BoolArray) | Array(PG::CharArray) | Array(PG::Float32Array) |
                       Array(PG::Float64Array) | Array(PG::Int16Array) | Array(PG::Int32Array) |
                       Array(PG::Int64Array) | Array(PG::StringArray) | Char | JSON::Any
end
