import os
import json

import seq2d

#
# Types
#

type Tile* = enum
  tIMPASS,
  tEMPTY,
  tHERO_1,
  tHERO_2,
  tHERO_3,
  tHERO_4,
  tMINE_0,
  tMINE_1,
  tMINE_2,
  tMINE_3,
  tMINE_4,
  tTAVERN

proc isHero*(t:Tile):bool {.inline.} =
  case t:
    of tHERO_1..tHERO_4:
      result = true
    else:
      result = false

type Hero* = object
    name*: string
    elo*: int
    life*, gold*, mineCount*: int
    pos*, spawnPos*: Pos
    lastDir*: string

type Mine* = object
  pos*: Pos
  owner*: int

type Tavern* = object
  pos*: Pos

type Map* = object
    turn*, maxTurns*: int
    heroes*: array[1..4, Hero]
    hero*: Hero
    mines*: seq[Mine]
    taverns*: seq[Tavern]
    grid*: Seq2D[Tile]

type Dir* = enum
  Stay, North, South, West, East

const allDirs* = [ Stay, North, South, West, East ]

proc getDir*(p1,p2:Pos): Dir =
  if p2.x == p1.x - 1 and p2.y == p1.y:
    result = North
  elif p2.x == p1.x + 1 and p2.y == p1.y:
    result = South
  elif p2.x == p1.x and p2.y == p1.y - 1:
    result = West
  elif p2.x == p1.x and p2.y == p1.y + 1:
    result = East
  else: raise newException(ValueError, "leap detected: " & $p1 & " to " & $p2)

#
# Parsing
#

import macros

const str_tile:seq[(string, Tile)] = @{ "##": tIMPASS, "  ": tEMPTY, "[]": tTAVERN, "$-": tMINE_0, "$1": tMINE_1, "$2": tMINE_2, "$3": tMINE_3, "$4": tMINE_4, "@1": tHERO_1, "@2": tHERO_2, "@3": tHERO_3, "@4": tHERO_4 }

proc parseTile(t_str: string): Tile =
  for p in items(str_tile):
    if t_str == p[0]:
      return p[1]
  raise newException(ValueError, "strange tile str" & t_str)

proc printTile(tile: Tile): string =
  for p in items(str_tile):
      if tile == p[1]:
        return p[0]
  raise newException(ValueError, "strange tile")

macro stringify(n: expr): string =
  result = newNimNode(nnkStmtList, n)
  result.add(toStrLit(n))

template parse_int(obj: untyped, field: untyped, node: JsonNode) =
  obj.field = int(node[stringify(field)].getNum())

template parse_str(obj: untyped, field: untyped, node: JsonNode) =
  obj.field = node[stringify(field)].getStr()

proc parsePos(node:JsonNode): Pos =
  parse_int(result, x, node)
  parse_int(result, y, node)

proc parseHero(node: JsonNode): Hero =
  parse_str(result, name, node)
  if node.hasKey("elo"):
    parse_int(result, elo, node)
  if node.hasKey("lastDir"):
    parse_str(result, lastDir, node)
  else:
    result.lastDir = ""
  result.pos = parsePos(node["pos"])
  result.spawnPos = parsePos(node["spawnPos"])

proc parseMap(js: JsonNode) : Map =
     let g = js["game"]
     var map : Map

     # turns
     parse_int(map, turn, g)
     parse_int(map, maxTurns, g)

     # heroes
     for i in 1..4:
         map.heroes[i] = parseHero(g["heroes"][i-1])
     map.hero = map.heroes[js["hero"]["id"].getNum()]

     #grid
     let b = g["board"]
     let tiles = b["tiles"].getStr()
     let size:int = tiles.len() div 2
     let num_rows:int = int(b["size"].getNum())
     let num_cols:int = size div num_rows

     map.grid = newSeq2D[Tile](num_cols, num_rows)
     map.mines = @[]
     map.taverns = @[]

     var k = 0
     for xx in 0..num_cols-1:
       for yy in 0..num_rows-1:
         let tile = parseTile(tiles[k..k+1])
         map.grid[xx,yy] = tile
         case tile:
           of tMINE_0..tMINE_4:
             map.mines.add(Mine(pos: Pos(x:xx,y:yy), owner: ord(tile) - ord(tMINE_0)))
           of tTavern:
             map.taverns.add(Tavern(pos: Pos(x:xx,y:yy)))
           else: discard

         k = k + 2

     return map

proc loadMap(path: string): Map =
  let js = json.parseFile(path)
  result = parseMap(js)

#
# Convenience
#

# Server communications
#

type Decide* = proc(m:Map):Dir

type Bot* = object
     name*: string
     key*: string
     decide*: Decide

const train_url = "http://vindinium.org/api/training"

import httpclient

proc run_training*(bot: Bot) =
  var finished = false
  var game_url = train_url
  var params = "&map=m1&turns=50"
  while not finished:
    let js_str = postContent(url = game_url,
                             extraHeaders = "Content-Type: application/x-www-form-urlencoded",
                             body = "key=" & bot.key & params )
    let js = json.parseJson(js_str)
    echo js_str
    let m = parseMap(js)
    game_url = js["playUrl"].getStr()
    m.grid.Print(printTile)
    echo $m.hero
    echo $m.heroes[4]
    let dir = bot.decide(m)
    params="&dir=" & $dir
    finished = m.turn >= m.maxTurns

