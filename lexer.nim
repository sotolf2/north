import
  std/algorithm,
  std/sequtils,
  std/strutils,
  std/strformat,
  std/sugar

type
  TokenKind* = enum
    Int,
    String,
    Word,
    None

  Token* = tuple
    filename: string
    row: int
    col: int
    token: string
    kind: TokenKind

  Program* = seq[Token]

proc `$`*(self: Token): string =
  fmt"{self.filename}:{self.row}:{self.col}: {self.token} <{self.kind}>"
  
proc findNext(line: string, posIn: int, cond: (char) -> bool): int =
  var pos = posIn
  while pos < line.len:
    if cond(line[pos]):
      return pos
    else: pos += 1
  return line.len

proc getNewLinePos(file: string): seq[int] =
  result.add 0
  var pos = 0
  while pos < file.len:
    if file[pos] == '\n':
      result.add pos
    pos += 1

proc getPos(pos: int, newLines: seq[int]): (int, int) =
  var row: int
  while row < len(newLines) - 1:
    if row != len(newLines) - 1:
      if pos > newLines[row] and pos < newLines[row + 1]:
        break
    else:
      break
    row += 1
  (row, pos - newLines[row])


proc lexFile(file: string, filename: string): seq[Token] =
  let newLines = getNewLinePos(file)
  var pos = 0
  var curWordStart = 0
  pos = findNext(file, pos, (x) => not isSpaceAscii(x))
  while pos < len(file):
    curWordStart = pos
    let (row, col) = getPos(curWordStart, newLines)
    if file[pos] == '"':
      pos += 1
      pos = findNext(file, pos, (x) => x == '"')
      result.add(
        (filename,
        row,
        col,
        file[curWordStart+1..pos-1],
        TokenKind.String
        )
      )
      pos += 1
      pos = findNext(file, pos, (x) => not isSpaceAscii(x))
    else:
      pos = findNext(file, pos, (x) => isSpaceAscii(x))
      var kind: TokenKind
      var token = file[curWordStart..pos-1]
      if token.all(isDigit):
        kind = TokenKind.Int
      else:
        kind = TokenKind.Word
      result.add(
        (filename,
        row,
        col,
        token,
        kind
        )
      )
      pos = findNext(file, pos, (x) => not isSpaceAscii(x))

proc lexLine(line: string, filename: string, lineNum: int): seq[Token] =
  var pos = 0
  var curWordStart = 0
  pos = findNext(line, pos, (x) => not isSpaceAscii(x))
  while pos < len(line):
    curWordStart = pos
    pos = findNext(line, pos, (x) => isSpaceAscii(x))
    #result.add((filename, lineNum, curWordStart, line[curWordStart..pos-1]))
    pos = findNext(line, pos, (x) => not isSpaceAscii(x))


proc lex*(filename: string): Program =
  let content = readFile(filename)
  lexFile(content, filename)
