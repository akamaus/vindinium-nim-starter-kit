import astar,hashes

import vindinium
import seq2d

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

template astar_path(m:Map, p1:Pos, p2:Pos): Pos =
  path[Map,Pos,int](m, p1, p2)

 
proc nymph_bot(m:Map):Dir =
  var d = 0
  for p in astar_path(m, m.hero.pos, m.heroes[4].pos):
    echo $p
    if d == 1:
      result = getDir(m.hero.pos, p)
    d += 1
  echo "Moving " & $result


let nymph = Bot(
      name: "Nymph",
      key: readFile("nymph.key"),
      decide: nymph_bot)

run_training(nymph)
