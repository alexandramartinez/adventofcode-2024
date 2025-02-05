output application/json
var robots = payload splitBy "\n"
var WIDTH = 101
var HEIGHT = 103
var SECONDS = 100
var widthMiddle = floor(WIDTH/2)
var heightMiddle = floor(HEIGHT/2)
type Coords = {
    x:Number,
    y:Number
}
fun stringToCoord(str:String):Coords = do {
    var split = str splitBy ","
    ---
    {x:split[0] as Number, y:split[1] as Number}
}
fun moveRobot(position:Coords,velocity:Coords):Coords = do {
    var x = position.x + velocity.x
    var y = position.y + velocity.y
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
@TailRec()
fun moveRobotXTimes(position:Coords,velocity:Coords,times=SECONDS):Coords = do {
    times match {
        case 0 -> position
        else -> moveRobotXTimes(
            moveRobot(position, velocity), velocity, times-1
        )
    }
}
var robotsAfterMoving = robots map ((robot) -> do {
    var split = robot splitBy " "
    var position = stringToCoord(split[0][2 to -1])
    var velocity = stringToCoord(split[-1][2 to -1])
    ---
    moveRobotXTimes(position,velocity)
})
---
sizeOf(robotsAfterMoving filter (($.x < widthMiddle) and ($.y < heightMiddle)))
* sizeOf(robotsAfterMoving filter (($.x > widthMiddle) and ($.y < heightMiddle)))
* sizeOf(robotsAfterMoving filter (($.x < widthMiddle) and ($.y > heightMiddle)))
* sizeOf(robotsAfterMoving filter (($.x > widthMiddle) and ($.y > heightMiddle)))