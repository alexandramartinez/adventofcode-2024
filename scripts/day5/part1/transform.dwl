import every from dw::core::Arrays
import substringBefore, substringAfter from dw::core::Strings
var p = payload splitBy "\n\n"
var orderingRules = p[0]
var updatesLines = p[1]splitBy "\n"
fun flatScan(a,b) = flatten(a scan b)
---
updatesLines map ((line, lineidx) -> do {
    var arr = (line splitBy ",")
    var isCorrect = (arr map ((num, numindex) -> 
        ((orderingRules flatScan "$(num)\|\d+|\d+\|$(num)") map (
            ((arr[numindex+1 to -1] default "") contains ($ substringBefore "|"))
            or ((if(numindex==0) "" else arr[numindex-1 to 0]) contains ($ substringAfter "|"))
        )) every (!$)
    )) every ($)
    ---
    if (isCorrect) arr[round(sizeOf(arr)/2)-1] as Number
    else 0
}) then sum($)