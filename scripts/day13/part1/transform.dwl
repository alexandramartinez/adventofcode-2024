output application/json
var machines = payload splitBy "\n\n"
---
machines map ((machine) -> do {
    var split = machine splitBy "\n"
    var prize = {
        x: (split[-1] splitBy " ")[1][2 to -2] as Number,
        y: (split[-1] splitBy " ")[-1][2 to -1] as Number
    }
    var buttonA = {
        x: (split[0] splitBy " ")[-2][2 to -2] as Number,
        y: (split[0] splitBy " ")[-1][2 to -1] as Number
    }
    var buttonB = {
        x: (split[1] splitBy " ")[-2][2 to -2] as Number,
        y: (split[1] splitBy " ")[-1][2 to -1] as Number
    }
    var D = (buttonA.x * buttonB.y) - (buttonA.y * buttonB.x)
    var Dx = (prize.x * buttonB.y) - (prize.y * buttonB.x)
    var Dy = (buttonA.x * prize.y) - (buttonA.y * prize.x)
    var A = Dx / D
    var B = Dy / D
    ---
    (if (isInteger(A)) A * 3 else 0) + (if (isInteger(B)) B else 0)
})
then sum($)