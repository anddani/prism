import gleam/list
import gleam/string

pub fn tokenize(text: String) -> List(String) {
  text
  |> string.replace(",", " , ")
  |> string.replace("(", " ( ")
  |> string.replace(")", " ) ")
  |> string.replace("=", " = ")
  |> string.replace(";", " ; ")
  |> string.split(" ")
  |> list.filter_map(fn(s) {
    case string.trim(s) {
      "" -> Error(Nil)
      trimmed -> Ok(trimmed)
    }
  })
}
