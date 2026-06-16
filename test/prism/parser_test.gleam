import gleeunit/should
import prism/parser

pub fn tokenizer_test() {
  parser.tokenize("INSERT INTO user VALUES(?, ?, ?);")
  |> should.equal([
    "INSERT",
    "INTO",
    "user",
    "VALUES",
    "(",
    "?",
    ",",
    "?",
    ",",
    "?",
    ")",
    ";",
  ])
}
