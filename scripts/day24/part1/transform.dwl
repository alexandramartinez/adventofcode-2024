import fromBinary from dw::core::Numbers
import lines from dw::core::Strings
output application/json
var splitPayload = payload splitBy "\n\n"
var wires:Object = (lines(splitPayload[0]) map ($ splitBy ": ")) reduce ((item, a={}) -> 
    a ++ {
        (item[0]): item[1] ~= 1
    }
)
fun getWiresObject(gates:Array<String>, wiresRec) = {
    (gates map ((gate) -> do {
        @Lazy
        var split = gate splitBy " "
        @Lazy
        var wire1 = split[0]
        @Lazy
        var wire2 = split[2]
        @Lazy
        var wire3 = split[-1]
        ---
        if (!isEmpty(wiresRec[wire1]) and !isEmpty(wiresRec[wire2])) {
            (wire3): split[1] match {
                case "AND" -> wiresRec[wire1] and wiresRec[wire2]
                case "OR" -> wiresRec[wire1] or wiresRec[wire2]
                case "XOR" -> wiresRec[wire1] != wiresRec[wire2]
            }
        }
        else {
            keepTrying: gate
        }
    }))
}
fun getWiresTailRec(gates:Array<String>, wiresRec=wires) = do {
    var result = getWiresObject(gates, wiresRec)
    var newGates = result.*keepTrying
    var newWires = wiresRec ++ result
    ---
    if (isEmpty(newGates)) newWires 
    else getWiresTailRec(newGates, newWires - "keepTrying")
}
---
getWiresTailRec(lines(splitPayload[1])) 
filterObject ($$ startsWith "z")
orderBy $$
mapObject (($$): if ($) 1 else 0)
then fromBinary(valuesOf($)[-1 to 0] joinBy "")