output application/json
import countBy from dw::core::Arrays
var lines = payload splitBy "\n"
var WIDTH = 101
var HEIGHT = 103
type Coords = {
    x:Number,
    y:Number
}
type Robot = {
    position: Coords,
    velocity: Coords
}
type Direction = "left" | "up" | "down" | "right"
fun stringToCoord(str:String):Coords = do {
    var split = str splitBy ","
    ---
    {x:split[0] as Number, y:split[1] as Number}
}
fun moveRobot(robot:Robot):Coords = do {
    var x = robot.position.x + robot.velocity.x
    var y = robot.position.y + robot.velocity.y
    ---
    {
        x: if (x > WIDTH-1) x-WIDTH 
            else if (x < 0) WIDTH+x
            else x,
        y: if (y > HEIGHT-1) y-HEIGHT
            else if (y < 0) HEIGHT+y
            else y
    }
}
fun getNewCoords(from:Coords, direction:Direction):Coords = direction match {
    case "left" -> {x: from.x-1, y:from.y}
    case "right" -> {x: from.x+1, y:from.y}
    case "up" -> {x: from.x, y: from.y-1}
    case "down" -> {x: from.x, y: from.y+1}
}
fun areMostTouchingOthers(arr):Boolean = do {
    ((arr map ((item) -> 
        (arr contains getNewCoords(item,"left"))
        or (arr contains getNewCoords(item,"right"))
        or (arr contains getNewCoords(item,"up"))
        or (arr contains getNewCoords(item,"down"))
    )) countBy $) >= 350 // 70% of 500
}
var robots:Array<Robot> = lines map ((robot) -> do {
    var split = robot splitBy " "
    var position = stringToCoord(split[0][2 to -1])
    var velocity = stringToCoord(split[-1][2 to -1])
    ---
    {
        position:position,
        velocity:velocity
    }
})
@TailRec()
fun keepMovingRobots(robots,counter=0) = do {
    if (areMostTouchingOthers(robots.position)) counter
    else keepMovingRobots(
        robots map ((robot, index) -> 
            {
                position: moveRobot(robot),
                velocity: robot.velocity
            }
        )
        ,counter+1
    )
}
---
keepMovingRobots(robots)