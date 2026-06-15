import gleam/option.{type Option}

pub opaque type TableName {
  TableName(String)
}

pub fn new_table_name(n: String) -> TableName {
  TableName(n)
}

pub fn table_name_to_string(name: TableName) -> String {
  let TableName(n) = name
  n
}

pub opaque type ColumnName {
  ColumnName(String)
}

pub fn new_column_name(n: String) -> ColumnName {
  ColumnName(n)
}

pub fn column_name_to_string(name: ColumnName) -> String {
  let ColumnName(n) = name
  n
}

// --- Schema ------------------------------

pub type Table {
  Table(name: TableName, columns: List(Column))
}

pub type Column {
  Column(
    name: ColumnName,
    sql_type: SqlType,
    is_nullable: Bool,
    custom_type: Option(CustomType),
  )
}

pub type CustomType {
  CustomType(
    /// E.g. "youid/uuid"
    module: String,
    /// E.g. "Uuid"
    type_name: String,
  )
}

pub type SqlType {
  Text
  Integer
  Boolean
  Uuid
  Timestamp
  TimestampTz
  Date
  Float
  Numeric
  Bytea
  Json
  Jsonb
  /// A reference to a user-defined enum type by name. The parser produces
  /// this for any type name it does not recognise; the schema builder
  /// validates it against the declared enums.
  EnumType(name: String)
  /// An array of another type: TEXT[] is Array(Text). Multi-dimensional
  /// arrays nest: TEXT[][] is Array(Array(Text)).
  Array(inner: SqlType)
}

/// A user-defined enum (CREATE TYPE ... AS ENUM). Variants are the SQL string
/// values in declaration order. `EnumType(name:)` references one of these by
/// name; the schema builder validates the reference and codegen emits
/// converters from the variants.
pub type Enum {
  Enum(name: String, variants: List(String))
}

/// --- Query ------------------------------
pub type Query {
  Query(
    /// E.g. "src/my_project/sql/user_queries.prism"
    file_name: String,
    /// E.g. "select_all"
    query_name: String,
    /// E.g. "SELECT * FROM user"
    sql: String,
    query_kind: QueryKind,
    result_columns: List(ResultColumn),
    params: List(Param),
  )
}

pub type Param {
  Param(
    name: String,
    position: Int,
    sql_type: SqlType,
    custom_type: Option(CustomType),
    /// True when the generated function should accept Option(T) and encode
    /// with pog.nullable — INSERT values for nullable columns. WHERE params
    /// are never nullable: `col = NULL` matches nothing in SQL, so an
    /// Option-typed filter would be a footgun.
    is_nullable: Bool,
  )
}

pub type QueryKind {
  /// Returns rows; `columns` describes the result row. This covers SELECT and
  /// any INSERT/UPDATE/DELETE with a RETURNING clause.
  Select
  /// Like `Select`, but the generated function returns at most one row as
  /// Result(Option(Row), _). Set by the `(one)` annotation in query files;
  /// `analyze` itself never produces it.
  SelectOne
  /// Returns no rows; `columns` is empty.
  Execute
}

pub type ColumnSource {
  ColumnSource(table: TableName, column: ColumnName)
}

pub type ResultColumn {
  ResultColumn(
    /// E.g.
    /// 
    /// SELECT u.name, c.name FROM users u JOIN companies c ON c.id = u.company_id
    /// =>
    /// [ResultColumn(field_name: "user_name", ...)
    ///  ResultColumn(field_name: "company_name", ...)]
    field_name: String,
    /// The table + column this result column came from. None when the result
    /// is a computed value (e.g. COUNT(*)) with no single source column.
    source: Option(ColumnSource),
    /// Can be different from column if type cast
    sql_type: SqlType,
    /// EFFECTIVE nullability in THIS result — may be True even when the
    /// underlying column is NOT NULL, because an outer join can NULL it.
    is_nullable: Bool,
    /// Can be different from column if type cast (which drops annotated type)
    custom_type: Option(CustomType),
  )
}
