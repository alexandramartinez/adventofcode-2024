import lines, isAlphanumeric from dw::core::Strings
output application/json
fun getChar(arr:Array<String>,x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (arr[y][x] default "")
fun isAntenna(char:String) = isAlphanumeric(char)
fun getAntinodesBetween(coord1, coord2) = do {
    var x1 = coord1.x + coord1.x - coord2.x
    var y1 = coord1.y + coord1.y - coord2.y
    var x2 = coord2.x + coord2.x - coord1.x
    var y2 = coord2.y + coord2.y - coord1.y
    ---
    [
        {
            antinodeChar: getChar(payloadArr,x1,y1),
            antinodeCoords: {
                x: x1,
                y: y1
            }
        },
        {
            antinodeChar: getChar(payloadArr,x2,y2),
            antinodeCoords: {
                x: x2,
                y: y2
            }
        }
    ]
}
var payloadArr = lines(payload)
var antennas = flatten(payloadArr map ((line, y) -> 
    (line splitBy "") map ((char, x) -> 
        if (isAntenna(char)) {
            char: char,
            coords: {
                x: x,
                y: y,
            }
        } else {}
    ) filter (!isEmpty($))
) filter (!isEmpty($)))
---
antennas groupBy ($.char) 
pluck ((frequencies, frequencyGroup, index) -> do {
    @Lazy
    var sizeOfFrequencies = sizeOf(frequencies)
    @Lazy
    var numbers = 0 to sizeOfFrequencies-1
    ---
    if (sizeOfFrequencies >= 2) 
        flatten(frequencies map ((frequency, fi) -> 
            flatten((numbers - fi) map ((number) -> 
                (getAntinodesBetween(frequency.coords,frequencies[number].coords) filter (!isEmpty($.antinodeChar)))
            ))
        ))
    else []
}) 
then flatten($) distinctBy $ 
then sizeOf($)