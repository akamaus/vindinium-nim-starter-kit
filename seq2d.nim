type Pos* = object
    x*,y* :int

type Seq2D*[T] = object
     size_x: int
     size_y: int
     grid: seq[T]

proc newSeq2D*[T](x: int, y: int): Seq2D[T] =
     return Seq2D[T](size_x:x, size_y:y, grid: newSeq[T](x*y))

proc Idx*(arr: Seq2D, x:int, y:int): int {.inline.} =
     return y * arr.size_y + x

proc Idx*(arr: Seq2D, p: Pos): int {.inline.} =
     return p.y * arr.size_y + p.x

proc `[]`*[T](arr: Seq2D[T], x:int, y:int):T =
     return arr.grid[arr.Idx(x,y)]

proc `[]`*[T](arr: Seq2D[T], p:Pos):T =
  return arr.grid[arr.Idx(p)]

proc `[]=`*[T](arr: var Seq2D[T], x:int, y:int, value:T): void =
     assert(x < arr.size_x)
     assert(y < arr.size_y)
     arr.grid[arr.Idx(x,y)] = value

proc Print*[T](arr: Seq2D[T], prn: proc(elt:T): string): void =
  for x in 0..arr.size_x-1:
    for y in 0..arr.size_y-1:
      stdout.write(prn(arr[x,y]))
      stdout.write(" ")
    stdout.write("\n")

iterator neighs*[T](g:Seq2D[T], p: Pos): Pos =
  let inc_x = p.x + 1
  let dec_x = p.x - 1
  let inc_y = p.y + 1
  let dec_y = p.y - 1

  if dec_x >= 0:
    yield Pos(x:dec_x, y:p.y)
  if inc_x < g.size_x:
    yield Pos(x:inc_x, y:p.y)
  if dec_y >= 0:
    yield Pos(x:p.x, y:dec_y)
  if inc_y < g.size_y:
    yield Pos(x:p.x, y:inc_y)

when isMainModule:
     var s = newSeq2D[string](3,3)
     s[2,2] = "aaa"
     s[1,2] = "bbb"
     doAssert(s[2,2] == "aaa")
     doAssert(s[1,2] == "bbb")
