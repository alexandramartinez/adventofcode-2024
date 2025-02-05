%dw 2.0
import lines from dw::core::Strings
output application/json
type Coords = {
    x:Number,
    y:Number
}
type Plant = {
    char:String,
    coords:Coords
}
var pLines:Array<String> = lines(payload)
fun getChar(arr:Array<String>,x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (arr[y][x] default "")
fun getPlant(x:Number,y:Number):Plant = {
    char: getChar(pLines,x,y),
    coords: {
        x:x,
        y:y
    }
}
fun getStringCoordsFromPlant(plant:Plant):String = 
    (plant.coords.x) ++ "," ++ (plant.coords.y)
var plants:Array<Plant> = flatten(pLines map ((line, y) -> 
    (line splitBy "") map ((plant, x) -> 
        getPlant(x,y)
    )
))
fun getClosePlantsStrings(plants) = plants reduce ((plant,acc={}) -> do {
    var left = getPlant(plant.coords.x-1, plant.coords.y)
    var right = getPlant(plant.coords.x+1, plant.coords.y)
    var up = getPlant(plant.coords.x, plant.coords.y-1)
    var down = getPlant(plant.coords.x, plant.coords.y+1)
    ---
    acc ++ (getStringCoordsFromPlant(plant)): [
        (getStringCoordsFromPlant(left)) if (left.char == plant.char),
        (getStringCoordsFromPlant(right)) if (right.char == plant.char),
        (getStringCoordsFromPlant(up)) if (up.char == plant.char),
        (getStringCoordsFromPlant(down)) if (down.char == plant.char)
    ] 
})
@TailRec()
fun getAllClose(arr, keys, obj) = do {
    var result = flatten(arr map ((item) -> 
        obj[item] -- keys
    )) distinctBy $
    ---
    if (isEmpty(result)) (keys ++ arr) 
    else getAllClose(
        result,
        (keys ++ arr),
        obj
    )
}
var regionsStringCoords = flatten((plants groupBy ($.char) pluck ((plantsByRegion, tempRegion) -> do {
    var obj = (getClosePlantsStrings(plantsByRegion))
    ---
    (obj pluck ((value, key) -> 
        getAllClose(value,[key as String],obj) orderBy $
    )) distinctBy $
})))
var corners = [
  [
    "down",
    "right"
  ],
  [
    "down",
    "left"
  ],
  [
    "left",
    "up"
  ],
  [
    "right",
    "up"
  ]
]
fun countCorners(sides:Array<Plant>,char:String) = do {
    var upleft = 0
    var up = 1
    var upright = 2
    var left = 3
    var right = 4
    var downleft = 5
    var down = 6
    var downright = 7
    ---
    (if ( (sides[left].char != char) and (sides[up].char != char) ) 1 else 0)
    + (if ( (sides[right].char != char) and (sides[up].char != char) ) 1 else 0)
    + (if ( (sides[left].char != char) and (sides[down].char != char) ) 1 else 0)
    + (if ( (sides[right].char != char) and (sides[down].char != char) ) 1 else 0)
    + (if ( (sides[left].char == char) and (sides[up].char == char) and (sides[upleft].char != char)) 1 else 0)
    + (if ( (sides[right].char == char) and (sides[up].char == char) and (sides[upright].char != char)) 1 else 0)
    + (if ( (sides[left].char == char) and (sides[down].char == char) and (sides[downleft].char != char)) 1 else 0)
    + (if ( (sides[right].char == char) and (sides[down].char == char) and (sides[downright].char != char)) 1 else 0)
}
---
regionsStringCoords map ((region) -> do {
    var plants = region map ((str) -> do {
        var strSplit = str splitBy ","
        var plant = getPlant(strSplit[0] as Number, strSplit[1] as Number)
        var left = getPlant(plant.coords.x-1, plant.coords.y)
        var right = getPlant(plant.coords.x+1, plant.coords.y)
        var up = getPlant(plant.coords.x, plant.coords.y-1)
        var down = getPlant(plant.coords.x, plant.coords.y+1)
        var upleft = getPlant(plant.coords.x-1, plant.coords.y-1)
        var upright = getPlant(plant.coords.x+1, plant.coords.y-1)
        var downleft = getPlant(plant.coords.x-1, plant.coords.y+1)
        var downright = getPlant(plant.coords.x+1, plant.coords.y+1)
        var s = [
            upleft, //0
            up, //1
            upright, //2
            left, //3
            right, //4
            downleft, //5
            down, //6
            downright //7
        ]
        ---
        {
            area: 1,
            corners: countCorners(s,plant.char)
        }
    })
    ---
    sum(plants.area) * sum(plants.corners)
}) 
then sum($)