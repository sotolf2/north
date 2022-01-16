import
  lexer,
  std/deques,
  std/strutils,
  std/sugar

type
  Op = enum
    Dump,
    Plus,
    Push,
  Instruction = tuple
    op: Op
    value: NorthType
    token: Token
  
  Word = seq[Instruction]

  NorthKind = enum
    nkInt,
    nkString,
    nkWord,
    nkBuiltin,
  NorthType = object
    case kind: Northkind
    of nkInt: intVal:int
    of nkWord: wordVal: Word
    of nkBuiltin: builtInVal: string
    of nkString: stringVal: string

proc toInstructions(program: Program): Deque[Instruction] =
  result = initDeque[Instruction]()
  for token in program:
    case token.kind 
    of TokenKind.Word:
      case token.token
      of "+":
        result.addLast((Op.Plus, NorthType(kind: nkBuiltin, builtInVal: token.token), token))
      of ".":
        result.addLast((Op.Dump, NorthType(kind: nkBuiltin, builtInVal: token.token), token))
    of TokenKind.Int:
      result.addLast((Op.Push, NorthType(kind: nkInt, intVal: parseInt(token.token)), token))
    of TokenKind.String:
      result.addLast((Op.Push, NorthType(kind: nkString, stringVal: token.token), token))
    else:
      doassert false, "Unknown Token kind " & $token.kind


proc run*(progIn: Program) =
  var stack = initDeque[NorthType]()
  var program = toInstructions(progIn)
  var isCompiling = false
  for inst in program:
    case inst.op
    of Push:
      stack.addFirst(inst.value)
    of Plus:
      let a = stack.popFirst()
      doassert a.kind == nkInt, $inst.token & " Use plus on a non-number"
      let b = stack.popFirst()
      assert b.kind == nkInt, $inst.token & " Use of plus on a non-number"
      stack.addFirst(NorthType(kind: nkint, intVal: a.intVal+b.intVal))
    of Dump:
      let val = stack.popFirst()
      case val.kind
      of nkInt: echo val.intVal
      of nkString: echo val.stringVal
      else:
        echo "can't dump the type " & $val.kind

  
