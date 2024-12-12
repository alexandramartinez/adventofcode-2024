fun removeExtraZeros(num:String):String = num as Number as String
fun blink(arr) = flatten(arr map ((num, numidx) -> 
    num match {
        case "0" -> "1"
        case n if isEven(sizeOf(n)) -> do {
            var i = sizeOf(n)/2
            ---
            [removeExtraZeros(n[0 to i-1]),removeExtraZeros(n[i to -1])]
        }
        else -> ($ * 2024) as String
    }
))
fun blinkTimes(arr,times:Number=1) = times match {
    case 0 -> arr
    else -> blink(arr) blinkTimes times-1
}
---
sizeOf((payload splitBy " ") blinkTimes 25)