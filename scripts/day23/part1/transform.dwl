import lines from dw::core::Strings
output application/json
var connections = lines(payload) map ($ splitBy "-") reduce ((item, a={}) -> 
    a update {
        case x at ."$(item[0])"! -> (a[item[0]] default []) + item[1]
        case y at ."$(item[1])"! -> (a[item[1]] default []) + item[0]
    }
)
var matches = flatten(namesOf(connections) map ((computer1) -> 
    flatten(connections[computer1] map ((computer2) -> do {
        var threeMatchesOne = (connections[computer2] filter ((computer3) -> connections[computer3] contains computer1))
        ---
        if (!isEmpty(threeMatchesOne)) 
            threeMatchesOne filter ((computer3) -> (computer1 startsWith "t") or (computer2 startsWith "t") or (computer3 startsWith "t"))
            map ((computer3) ->
                [computer1, computer2, computer3] orderBy $
            )
        else []
    })) 
)) distinctBy $
---
sizeOf(matches)