import divideBy from dw::core::Arrays
var p = (payload splitBy "")
fun repeat(text: String, times: Number): Array =
    if(times <= 0) [] else (1 to times) map text
var files:Array = flatten((p divideBy 2) map ((item, index) -> 
    repeat(index, item[0]) ++ repeat(".", item[1] default 0)
))
var filesClean:Array = files - "."
var thisthing = (files reduce ((item, acc={ r:[], idx:-1 }) -> item match {
    case "." -> {
        r: acc.r + filesClean[acc.idx],
        idx: acc.idx - 1
    }
    else -> {
        r: acc.r + item,
        idx: acc.idx
    }
}))
---
thisthing.r[0 to thisthing.idx] map ($*$$) then sum($)