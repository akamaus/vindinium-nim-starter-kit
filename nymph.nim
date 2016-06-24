import astar,hashes
import strutils

import vindinium, seq2d

# for A-Star
proc hash(p:Pos): Hash =
  var h: Hash = 0
  h = h !& hash(p.x)
  h = h !& hash(p.y)
  result = !$h

iterator neighbors(m:Map, p:Pos): Pos =
  for n in m.grid.neighs(p):
    if m.grid[n] == tEmpty or m.grid[n].isHero():
      yield n

proc cost(m:Map, p1:Pos, p2:Pos): int =
  result = 1
proc heuristic(m:Map, p1:Pos, p2:Pos): int =
  result = manhattan[Pos,int](p1,p2)

proc astar_path(m:Map, p1:Pos, p2:Pos): seq[Pos] =
  result = newSeq[Pos]()
  var d = 0
  for p in path[Map,Pos,int](m, p1, p2):
    if d >= 1:
      result.add(p)
    d += 1

# General logic

proc find_nearest[T](m:Map, p: Pos, objs:openArray[T], pred:proc(o:T):bool): T =
  var nearest:T
  var nearest_dist = 100000
  for o in objs:
    if not pred(o):
      continue
    let p = astar_path(m,p, o.pos)
    if p.len < nearest_dist:
      nearest = o
      nearest_dist = p.len
  result = nearest

proc nymph_bot(m:Map):Dir =
  let me = m.hero

  let tgt = find_nearest[Hero](m, me.pos, m.heroes, proc(h:Hero): bool = me.id != h.id )

  let path = astar_path(m, m.hero.pos, tgt.pos)
  let d = getDir(m.hero.pos, path[0])
  echo format("Chasing $1; Moving $2", tgt.id, d)
  result = d

  proc printer(pos:Pos, t:Tile): string =
    result = printTile(t)
    if t == tEmpty:
      for i,p in path:
        if p == pos:
          result = $(i+1)
          break

  Print(m.grid,printer)

let nymph = Bot(
      name: "Nymph",
      key: readFile("nymph.key"),
      decide: nymph_bot)

run_training(nymph)
