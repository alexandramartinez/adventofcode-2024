var lines = payload splitBy "\n"
var XMAS = "XMAS"
fun getLetter(x:Number,y:Number) = if ((x<0) or (y<0)) "" else (lines[x][y] default "")
fun getStr(str:String,x:Number,y:Number) = if ((x<0) or (y<0)) "" else (str[x to y])
---
flatten
(lines map ((lineStr, lineidx) -> 
    (lineStr splitBy "") map ((letter, letteridx) ->
        if (letter=="X") (
            // right
            (if (XMAS == getStr(lineStr,letteridx,letteridx+3)) 1 else 0)
            // left
            + (if (XMAS == getStr(lineStr,letteridx,letteridx-3)) 1 else 0)
            // down
            + (if (XMAS == (letter ++ getLetter(lineidx+1,letteridx) ++ getLetter(lineidx+2,letteridx) ++ getLetter(lineidx+3,letteridx))) 1 else 0)
            // // up
            + (if (XMAS == (letter ++ getLetter(lineidx-1,letteridx) ++ getLetter(lineidx-2,letteridx) ++ getLetter(lineidx-3,letteridx))) 1 else 0)
            // down-right
            + (if (XMAS == (letter ++ getLetter(lineidx+1,letteridx+1) ++ getLetter(lineidx+2,letteridx+2) ++ getLetter(lineidx+3,letteridx+3))) 1 else 0)
            // down-left
            + (if (XMAS == (letter ++ getLetter(lineidx+1,letteridx-1) ++ getLetter(lineidx+2,letteridx-2) ++ getLetter(lineidx+3,letteridx-3))) 1 else 0)
            // up-right
            + (if (XMAS == (letter ++ getLetter(lineidx-1,letteridx+1) ++ getLetter(lineidx-2,letteridx+2) ++ getLetter(lineidx-3,letteridx+3))) 1 else 0)
            // up-left
            + (if (XMAS == (letter ++ getLetter(lineidx-1,letteridx-1) ++ getLetter(lineidx-2,letteridx-2) ++ getLetter(lineidx-3,letteridx-3))) 1 else 0)
        )
        else 0
    )
)) then sum($)