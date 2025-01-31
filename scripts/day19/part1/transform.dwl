import countBy from dw::core::Arrays
import lines, substringAfter from dw::core::Strings
output application/json
var split = payload splitBy "\n\n"
var patternsList = split[0] splitBy ", "
fun checkDesign(initialDesign:String, currentDesign:String, acc="") = do {
    var filtered = patternsList filter (currentDesign startsWith $)
    ---
    if (isEmpty(currentDesign))
        initialDesign == acc
    else if (isEmpty(filtered)) false
    else filtered 
    reduce ((pattern, matches=false) -> 
        if (matches) true
        else checkDesign(
            initialDesign,
            currentDesign substringAfter pattern,
            acc ++ pattern
        ) 
    )
}
---
(lines(split[1]) map ((design) -> 
    checkDesign(design,design)
)) countBy $