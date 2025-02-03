import countBy from dw::core::Arrays
import lines, substringAfter from dw::core::Strings
output application/json
var split = payload splitBy "\n\n"
var patternsList = (split[0] splitBy ", ") 
fun flattenNestedArrays(data) = data match {
    case is Array -> flatten(data map flattenNestedArrays($))
    else -> data
}
fun checkDesign(initialDesign,design,patterns,str="") = do {
    var startsWithPatterns = patterns filter (design startsWith $)
    ---
    if (isEmpty(startsWithPatterns)) if (str == initialDesign) [1] else [0]
    else flatten(startsWithPatterns map ((pattern) -> 
        checkDesign(initialDesign, design substringAfter pattern, patterns, str ++ pattern)
    )) 
}
---
(lines(split[1]) map ((design) -> do { // brwrr
    var availablePatterns = patternsList filter (design contains $) // [r, wr, b, br]
    ---
    // flattenNestedArrays(checkDesign(design,design,availablePatterns)) countBy ($)
    (checkDesign(design,design,availablePatterns)) then sum($)
})) then sum($)