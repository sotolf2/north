import 
  clapfn,
  lexer,
  runner,
  std/tables

var parser = ArgumentParser(
  programName: "north",
  fullName: "North Programming Language",
  description: "A Stack based forth-like programming language",
  version: "0.0.0",
  author: "sotolf2"
)

parser.addRequiredArgument(name="in_file", help="Input file.")

let args = parser.parse()

let filename = args["in_file"]
let program = lex(filename)
run(program)
