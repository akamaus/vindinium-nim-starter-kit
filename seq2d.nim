type Seq2D*[T] = object
     size_x: int
     size_y: int
     grid: seq[T]

proc newSeq2D*[T](x: int, y: int): Seq2D[T] =
     return Seq2D[T](size_x:x, size_y:y, grid: newSeq[T](x*y))

proc Idx*(arr: Seq2D, x:int, y:int): int {.inline.} =
     return y * arr.size_y + x

proc `[]`*[T](arr: Seq2D[T], x:int, y:int):T =
     return arr.grid[arr.Idx(x,y)]

proc `[]=`*[T](arr: var Seq2D[T], x:int, y:int, value:T): void =
     assert(x < arr.size_x)
     assert(y < arr.size_y)
     arr.grid[arr.Idx(x,y)] = value

proc Print*[T](arr: Seq2D[T], prn: proc(elt:T): string): void =
     for y in 0..arr.size_y-1:
          for x in 0..arr.size_x-1:
              stdout.write(prn(arr[x,y]))
              stdout.write(" ")
          stdout.write("\n")

when isMainModule:
     var s = newSeq2D[string](3,3)
     s[2,2] = "aaa"
     s[1,2] = "bbb"
     doAssert(s[2,2] == "aaa")
     doAssert(s[1,2] == "bbb")