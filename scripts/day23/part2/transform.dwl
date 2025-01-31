import lines from dw::core::Strings
output application/json
var connections = lines(payload) map ($ splitBy "-") reduce ((item, a={}) -> 
    a update {
        case x at ."$(item[0])"! -> (a[item[0]] default []) + item[1]
        case y at ."$(item[1])"! -> (a[item[1]] default []) + item[0]
    }
)
var list = namesOf(connections) map ((computer1) -> do {
    var cc1 = connections[computer1]
    var list = (cc1 + computer1) orderBy $
    var strings = (cc1 map ((computer2) -> do {
        var tocompare = (connections[computer2] + computer2) orderBy $
        ---
        (tocompare filter (list contains $)) joinBy ","
    })) orderBy $
    ---
    ((strings orderBy $) groupBy $) filterObject (sizeOf($) >= 2)
    mapObject ((value, key, index) -> {
        size: sizeOf(value),
        str: key
    })
})
---
((list filter (!isEmpty($))) orderBy -($.size))[0].str