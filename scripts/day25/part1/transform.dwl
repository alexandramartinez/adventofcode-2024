import every, countBy from dw::core::Arrays
output application/json
fun getMap(arr) = arr map ((item) -> do {
    var lines = (item splitBy "\n")[1 to -2]
    ---
    (0 to sizeOf(lines)-1) map (
        sum(lines map ((line) -> 
            if (line[$] == "#") 1 else 0
        ))
    )
})
var arr = (payload splitBy "\n\n")
var locks = getMap(arr filter ($ startsWith "#####"))
var keys = getMap(arr filter ($ startsWith "....."))
---
sum(locks map ((lock, locki) -> 
    (keys map ((key, keyi) -> 
        (key map ((keypin, keypini) -> 
            5-keypin >= lock[keypini]
        )) every $
    )) countBy $
))