var lines = payload splitBy "\n"
fun getChar(x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (lines[x][y] default "")
fun getRoutes(num:Number,numidx:Number,lineidx:Number) = do {
    var nextNum = num+1
    ---
    if (num ~= 9) [{x:numidx,y:lineidx}]
    else 
        (if (getChar(lineidx-1,numidx) ~= nextNum) getRoutes(nextNum,numidx,lineidx-1) else [])
        ++
        (if (getChar(lineidx+1,numidx) ~= nextNum) getRoutes(nextNum,numidx,lineidx+1) else [])
        ++
        (if (getChar(lineidx,numidx-1) ~= nextNum) getRoutes(nextNum,numidx-1,lineidx) else [])
        ++
        (if (getChar(lineidx,numidx+1) ~= nextNum) getRoutes(nextNum,numidx+1,lineidx) else [])
}
---
flatten(lines map ((line, lineidx) -> 
    (line splitBy "") map ((num, numidx) -> 
        num match {
            case "0" -> sizeOf(getRoutes(0,numidx,lineidx) distinctBy $)
            else -> 0
        }
    )
)) then sum($)