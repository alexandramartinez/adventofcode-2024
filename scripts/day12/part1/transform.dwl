import some from dw::core::Arrays
output application/json
var lines = payload splitBy "\n"
var sizeOfLine = sizeOf(lines[0])
fun getChar(x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (lines[y][x] default "")
var list = flatten(lines map ((line, y) -> 
    (line splitBy "") map ((plant, x) -> do {
        @Lazy
        var left = plant == getChar(x-1,y)
        @Lazy
        var right = plant == getChar(x+1,y)
        @Lazy
        var up = plant == getChar(x,y-1)
        @Lazy
        var down = plant == getChar(x,y+1)
        @Lazy
        var p = (if (left) 0 else 1)
            + (if (right) 0 else 1)
            + (if (up) 0 else 1)
            + (if (down) 0 else 1)
        ---
        {

            id: (sizeOfLine*y)+x+1,
            plant: if (p != 4) plant else "$plant-$(uuid())",
            area: 1,
            perimeter: p,
            coords: {
                x: x,
                y: y
            },
            nearbyCoords: [
                ({x: x-1, y: y}) if left,
                ({x: x+1, y: y}) if right,
                ({x: x, y: y-1}) if up,
                ({x: x, y: y+1}) if down
            ],
        }
    })
))
---
list