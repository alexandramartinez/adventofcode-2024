var lines = payload splitBy "\n"
fun getLetter(x:Number,y:Number) = if ((x<0) or (y<0)) "" else (lines[x][y] default "")
var xmas = ["MAS", "SAM"]
---
flatten
(lines map ((lineStr, lineidx) -> 
    (lineStr splitBy "") map ((letter, letteridx) ->
        if (letter=="A") do {
            var topleft = getLetter(lineidx-1, letteridx-1)
            var topright = getLetter(lineidx-1, letteridx+1)
            var bottomleft = getLetter(lineidx+1, letteridx-1)
            var bottomright = getLetter(lineidx+1, letteridx+1)
            var cross1 = topleft ++ letter ++ bottomright
            var cross2 = topright ++ letter ++ bottomleft
            ---
            if ( (xmas contains cross1) and (xmas contains cross2) ) 1 else 0
        }
        else 0
    )
)) then sum($)