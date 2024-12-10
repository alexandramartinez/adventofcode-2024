output application/json
type Coordinates = {x:Number,y:Number}
var matrix = (payload splitBy "\n") map ($ splitBy "")
var guardPositions = ["^", "<", ">", "v"]
fun getChar(matrix:Array<Array<String>>,y:Number,x:Number):String = if ((x<0) or (y<0)) "" else (matrix[y][x] default "")
fun turnGuard(guard:String):String = guard match {
    case "^" -> ">"
    case ">" -> "v"
    case "v" -> "<"
    case "<" -> "^"
}
fun getInFrontCoord(guard:String,y:Number,x:Number):Coordinates = guard match {
    case "^" -> {y:y-1,x:x}
    case ">" -> {y:y,x:x+1}
    case "<" -> {y:y,x:x-1}
    case "v" -> {y:y+1,x:x}
}
fun getRoute(matrix:Array, coords=[]) = flatten(matrix map ((line, lineindex) -> 
    flatten(line map ((char, charindex) -> do {
        @Lazy
        var inFrontCoords = getInFrontCoord(char, lineindex, charindex)
        @Lazy
        var inFrontChar = getChar(matrix,inFrontCoords.y, inFrontCoords.x)
        @Lazy
        var guardCoords:Coordinates = {x:charindex,y:lineindex}
        ---
        if (guardPositions contains char) inFrontChar match {
            case "." -> getRoute(matrix update {
                case c at [inFrontCoords.y][inFrontCoords.x] -> char
                case g at [guardCoords.y][guardCoords.x] -> "."
            }, coords + guardCoords)
            case "#" -> getRoute(matrix update {
                case g at [guardCoords.y][guardCoords.x] -> turnGuard(char)
            }, coords)
            else -> coords
        }
        else null
    }))
))
---
sizeOf(getRoute(matrix) distinctBy $)