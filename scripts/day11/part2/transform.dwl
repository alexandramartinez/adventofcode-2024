output application/json
fun removeExtraZeros(num:String):String = num as Number as String
fun blink(obj:Object) = namesOf(obj) reduce ((item, result={}) -> do {
    var itemValue = obj."$item"
    ---
    item match {
        case "0" -> result update {
            case new at ."1"! -> (new default 0) + itemValue
        }
        case n if isEven(sizeOf(n)) -> do {
            var i = sizeOf(n)/2
            var n1 = removeExtraZeros(n[0 to i-1])
            var n2 = removeExtraZeros(n[i to -1])
            var isSame = n1 == n2
            ---
            if (isSame) result update {
                case new at ."$n1"! -> (new default 0) + (itemValue * 2)
            } 
            else result update {
                case new1 at ."$n1"! -> (new1 default 0) + itemValue
                case new2 at ."$n2"! -> (new2 default 0) + itemValue
            }
        }
        else -> result update {
            case new at ."$($ * 2024)"! -> (new default 0) + itemValue
        }
    }
})
fun blinkTimes(obj:Object,times:Number) = times match {
    case 0 -> obj
    else -> blink(obj) blinkTimes times-1
}
fun arrToObj(arr:Array,result={}) = arr match {
    case [head ~ tail] -> tail arrToObj (result update {
        case x at ."$head"! -> (x default 0) + 1
    })
    case [] -> result
}
---
arrToObj(payload splitBy " ") blinkTimes 75
then sum(valuesOf($))