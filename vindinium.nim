import os
import json

import seq2d

type Dir = enum
     North, South, West, East

type Tile = enum
  IMPASS,
  EMPTY,
  HERO_1,
  HERO_2,
  HERO_3,
  HERO_4,
  MINE_0,
  MINE_1,
  MINE_2,
  MINE_3,
  MINE_4,
  TAVERN

type Hero = object
     name: string
     elo: int

type Map = object
     turn, maxTurns: int
     heroes: array[1..4, Hero]
     grid: Seq2D[Tile]

const all_dirs = [ North, South, West, East ]

const str_tile = @{ "##": IMPASS, "  ": EMPTY, "[]": TAVERN, "$-": MINE_0, "$1": MINE_1, "$2": MINE_2, "$3": MINE_3, "$4": MINE_4, "@1": HERO_1, "@2": HERO_2, "@3": HERO_3, "@4": HERO_4 }

proc parseTile(t_str: string): Tile =
     case t_str:
     of "##": result = IMPASS
     of "  ": result = EMPTY
     of "[]": result = TAVERN
     of "$-": result = MINE_0
     of "$1": result = MINE_1
     of "$2": result = MINE_2
     of "$3": result = MINE_3
     of "$4": result = MINE_4
     of "@1": result = HERO_1
     of "@2": result = HERO_2
     of "@3": result = HERO_3
     of "@4": result = HERO_4
     else: raise newException(ValueError, "strange tile")

proc printTile(tile: Tile): string =
     case tile:
     of IMPASS: result = "##"
     of EMPTY: result  = "  "
     of TAVERN: result = "[]"
     of MINE_0: result = "$-"
     of MINE_1: result = "$1"
     of MINE_2: result = "$2"
     of MINE_3: result = "$3"
     of MINE_4: result = "$4"
     of HERO_1: result = "@1"
     of HERO_2: result = "@2"
     of HERO_3: result = "@3"
     of HERO_4: result = "@4"

proc parseHero(node: JsonNode) : Hero =
     result = Hero(name: node["name"].getStr(),
                   elo: if node.hasKey("elo"):
                           (int)node["elo"].getNum()
                        else: 0 )

proc parseMap(js: JsonNode) : Map =
     let g = js["game"]
     var map : Map

     map.turn = int(g["turn"].getNum())
     map.maxTurns = int(g["maxTurns"].getNum())

     for i in 1..4:
         map.heroes[i] = parseHero(g["heroes"][i-1])

     let b = g["board"]
     let tiles = b["tiles"].getStr()
     let size:int = tiles.len() div 2
     let num_rows:int = int(b["size"].getNum())
     let num_cols:int = size div num_rows

     map.grid = newSeq2D[Tile](num_cols, num_rows)

     var k = 0
     for x in 0..num_cols-1:
         for y in 0..num_rows-1:
             map.grid[x,y] = parseTile(tiles[k..k+1])
             k = k + 2

     return map

proc loadMap(path: string): Map =
  let js = json.parseFile(path)
  result = parseMap(js)

#
# Server communications
#
const train_url = "http://vindinium.org/api/training"

import httpclient

proc run_training(key: string) =
  echo ("key=" & key)

  var finished = false
  var game_url = train_url
  var params = "&map=m1&turns=5"
  while not finished:
    let js_str = postContent(url = game_url,
                             extraHeaders = "Content-Type: application/x-www-form-urlencoded",
                             body = "key=" & key & params )
    let js = json.parseJson(js_str)
    echo js_str
    let m = parseMap(js)
    game_url = js["playUrl"].getStr()
    m.grid.Print(printTile)
    params="&dir=Stay"
    finished = m.turn >= m.maxTurns

#let js_path = paramStr(1)

#let m = parseMap(js_path)
#m.grid.Print(printTile)

run_training(readFile("nymph.key"))
