import argv
import gleam/io
import gleam/list

/// Converts between a domain type and the raw database type for a column.
/// Users construct one per custom type and inject them via the generated
/// `Adapters` record in the shared `sql.gleam` module.
pub type ColumnAdapter(domain_type, db_type) {
  ColumnAdapter(
    decode: fn(db_type) -> Result(domain_type, String),
    encode: fn(domain_type) -> db_type,
  )
}

/// The error type of generated query functions. `db_error` is generic
/// as the ambition is to support additional SQL dialects in the future.
pub type QueryError(db_error) {
  /// The database driver returned an error.
  DatabaseError(db_error)
  /// A ColumnAdapter failed to decode a database value into its domain type.
  AdapterError(column: String, message: String)
}

pub fn main() -> Nil {
  case argv.load().arguments {
    [] ->
      case generate() {
        Ok(written) ->
          list.each(written, fn(p) { io.println("generated " <> p) })
        Error(e) -> fail(e)
      }
    ["check"] ->
      case check() {
        Ok([]) -> io.println("all generated files are up to date")
        Ok(stale) -> {
          list.each(stale, fn(p) { io.println_error("stale: " <> p) })
          fail("generated files are out of date — run `gleam run -m prism`")
        }
        Error(e) -> fail(e)
      }
    _ -> fail("usage: gleam run -m prism [check]")
  }
}

fn fail(message: String) -> Nil {
  io.println_error("error: " <> message)
  halt(1)
}

@external(erlang, "erlang", "halt")
fn halt(code: Int) -> Nil

/// Runs the main codegen, deriving the DB schema from migrations,
/// parses all query files, and generates .gleam files with
/// functions and types for all queries.
///
/// Returns a list of filenames of the files that were generated, or an error.
pub fn generate() -> Result(List(String), String) {
  Ok([])
}

/// Dry run of codegen, returns a list of generated files that differ
/// from the stored ones.
/// 
/// Returns a list of filenames of the files that were different, or an error.
pub fn check() -> Result(List(String), String) {
  Ok([])
}
