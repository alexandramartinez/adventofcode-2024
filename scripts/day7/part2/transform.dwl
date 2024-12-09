%dw 2.0
import drop from dw::core::Arrays
import lines from dw::core::Strings
fun flatScan(a, b) = flatten(a scan b)
fun getResults(values, r=0) = do {
    var this = values[0]
    var next = values[1]
    var newValues = values drop 1
    ---
    if (isEmpty(next)) r
    else if (r==0) flatten([getResults(newValues, this+next), getResults(newValues, this*next), getResults(newValues, "$this$next" as Number)])
    else flatten([getResults(newValues, r+next),  getResults(newValues, r*next), getResults(newValues, "$r$next" as Number)])
}
---
lines(payload) map ((equation, equationIndex) -> do {
    var nums = equation flatScan /\d+/
    var result = nums[0] as Number
    var values = nums[1 to -1] map ($ as Number)
    ---
    if (getResults(values) contains result) result else 0
}) then sum($)