import os
import json

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
     heroes: array[1..4, Hero]
     grid: seq[Tile]

const all_dirs = [ North, South, West, East ]

for dd in pairs(all_dirs):
    let (k,d) = dd
    echo k, $d

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

proc parseHero(node: JsonNode) : Hero =
     result = Hero(name: node["name"].getStr(),
                   elo: (int)node["elo"].getNum())

proc parseMap(js_path: string) : Map =
     let js = parseFile(js_path)
     let g = js["game"]
     var map : Map
     for i in 1..4:
         map.heroes[i] = parseHero(g["heroes"][i-1])

     let b = g["board"]
     let row_size = b["size"].getNum()
     let tiles = b["tiles"].getStr()
     let size:int = tiles.len() div 2
     map.grid = newSeq[Tile](size)
     for i in 0..size-1:
         map.grid[i] = parseTile(tiles[i*2 .. i*2+1])

     return map


let js_path = paramStr(1)

let m = parseMap(js_path)
echo "map is", $m