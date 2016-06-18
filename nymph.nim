import vindinium

#let js_path = paramStr(1)

echo Dir.high()

proc nymph_bot(m:Map):Dir =
     result = Stay

let nymph = Bot(
      name: "Nymph",
      key: readFile("nymph.key"),
      decide: nymph_bot)

run_training(nymph)
