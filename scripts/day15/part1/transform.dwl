import mapString from dw::core::Strings
output application/json
type Coords = {x:Number,y:Number}
var lines = payload splitBy "\n\n"
var initialMap = do {
    var thismap = lines[0] splitBy "\n"
    ---
    {
        map: thismap,
        robot: (flatten(thismap map ((line, y) -> 
            (line splitBy "") map ((char, x) -> 
                char match {
                    case "@" -> {x:x,y:y}
                    else -> null
                }
            )
        )) filter (!isEmpty($)))[0] as Coords
    }
}
var movements = lines[1] replace "\n" with "" splitBy ""
fun getChar(arr:Array<String>,x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (arr[y][x] default "")
@TailRec()
fun moveBoxes(thisMap, boxes:Array<Coords>, direction:String) = direction match {
    case "<" -> getChar(thisMap.map, boxes[-1].x-1, boxes[-1].y) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, boxes + {x:boxes[-1].x-1, y:boxes[-1].y}, direction)
        case "." -> thisMap update {
            case .robot.x -> boxes[0].x
            case .map[thisMap.robot.y] -> $ mapString ((character, index) -> 
                index match {
                    case x if (thisMap.robot.x == x) -> "."
                    case x if (boxes[0].x == x) -> "@"
                    case x if (boxes[-1].x-1 == x) -> "O"
                    else -> character
                }
            )
        }
    }
    case ">" -> getChar(thisMap.map, boxes[-1].x+1, boxes[-1].y) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, boxes + {x:boxes[-1].x+1, y:boxes[-1].y}, direction)
        case "." -> thisMap update {
            case .robot.x -> boxes[0].x
            case .map[thisMap.robot.y] -> $ mapString ((character, index) -> 
                index match {
                    case x if (thisMap.robot.x == x) -> "."
                    case x if (boxes[0].x == x) -> "@"
                    case x if (boxes[-1].x+1 == x) -> "O"
                    else -> character
                }
            )
        }
    }
    case "^" -> getChar(thisMap.map, boxes[-1].x, boxes[-1].y-1) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, boxes + {x:boxes[-1].x, y:boxes[-1].y-1}, direction)
        case "." -> thisMap update {
            case .robot.y -> boxes[0].y
            case .map[thisMap.robot.y] -> $ replace "@" with "."
            case .map[boxes[0].y] -> $[0 to boxes[0].x-1] ++ "@" ++ $[boxes[0].x+1 to -1]
            case .map[boxes[-1].y-1] -> $[0 to boxes[-1].x-1] ++ "O" ++ $[boxes[-1].x+1 to -1]
        }
    }
    case "v" -> getChar(thisMap.map, boxes[-1].x, boxes[-1].y+1) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, boxes + {x:boxes[-1].x, y:boxes[-1].y+1}, direction)
        case "." -> thisMap update {
            case .robot.y -> boxes[0].y
            case .map[thisMap.robot.y] -> $ replace "@" with "."
            case .map[boxes[0].y] -> $[0 to boxes[0].x-1] ++ "@" ++ $[boxes[0].x+1 to -1]
            case .map[boxes[-1].y+1] -> $[0 to boxes[-1].x-1] ++ "O" ++ $[boxes[-1].x+1 to -1]
        }
    }
}
fun moveRobot(thisMap, moveTo:String) = moveTo match {
    case "<" -> getChar(thisMap.map, thisMap.robot.x-1, thisMap.robot.y) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, [{x:thisMap.robot.x-1, y:thisMap.robot.y}], moveTo) 
        case "." -> thisMap update {
            case .robot.x -> $-1
            case .map[thisMap.robot.y] -> $ mapString ((character, index) -> 
                index match {
                    case x if (thisMap.robot.x == x) -> "."
                    case x if (thisMap.robot.x-1 == x) -> "@"
                    else -> character
                }
            )
        }
    }
    case ">" -> getChar(thisMap.map, thisMap.robot.x+1, thisMap.robot.y) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, [{x:thisMap.robot.x+1, y:thisMap.robot.y}], moveTo) 
        case "." -> thisMap update {
            case .robot.x -> $+1
            case .map[thisMap.robot.y] -> $ mapString ((character, index) -> 
                index match {
                    case x if (thisMap.robot.x == x) -> "."
                    case x if (thisMap.robot.x+1 == x) -> "@"
                    else -> character
                }
            )
        }
    }
    case "^" -> getChar(thisMap.map, thisMap.robot.x, thisMap.robot.y-1) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, [{x:thisMap.robot.x, y:thisMap.robot.y-1}], moveTo) 
        case "." -> thisMap update {
            case .robot.y -> $-1
            case .map[thisMap.robot.y] -> $ replace "@" with "."
            case .map[thisMap.robot.y-1] -> $[0 to thisMap.robot.x-1] ++ "@" ++ $[thisMap.robot.x+1 to -1]
        }
    }
    case "v" -> getChar(thisMap.map, thisMap.robot.x, thisMap.robot.y+1) match {
        case "#" -> thisMap
        case "O" -> moveBoxes(thisMap, [{x:thisMap.robot.x, y:thisMap.robot.y+1}], moveTo) 
        case "." -> thisMap update {
            case .robot.y -> $+1
            case .map[thisMap.robot.y] -> $ replace "@" with "."
            case .map[thisMap.robot.y+1] -> $[0 to thisMap.robot.x-1] ++ "@" ++ $[thisMap.robot.x+1 to -1]
        }
    }
}
@TailRec()
fun keepMoving(movementsList:Array<String>, thisMap) = movementsList match {
    case [headMovement ~ tailMovements] -> keepMoving(
        tailMovements,
        thisMap moveRobot headMovement
    )
    case [] -> thisMap
}
---
keepMoving(movements,initialMap).map map ((line, y) -> 
    sum((line splitBy "") map ((char, x) -> 
        if (char == "O") 100 * y + x
        else 0
    ))
) then sum($)