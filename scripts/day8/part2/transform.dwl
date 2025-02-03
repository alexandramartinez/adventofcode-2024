import lines, isAlphanumeric from dw::core::Strings
output application/json
type Coords = {
    x:Number,
    y:Number
}
type Frequency = {
    char:String,
    coords:Coords
}
fun getChar(arr:Array<String>,x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (arr[y][x] default "")
fun isAntenna(char:String):Boolean = isAlphanumeric(char)
fun getAntinodesBetween(coord1:Coords, coord2:Coords, times:Number) = do {
    var x = coord1.x + ((times+1) * (coord2.x - coord1.x))
    var y = coord1.y + ((times+1) * (coord2.y - coord1.y))
    var char = getChar(payloadArr,x,y)
    ---
    [
        ({
            char: char,
            coords: {
                x: x,
                y: y
            }
        }) if (!isEmpty(char)),
    ] 
}
var payloadArr:Array<String> = lines(payload)
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
fun getAntinodes(frequencies,times=1,acc=[]) = do {
    @Lazy
    var sizeOfFrequencies = sizeOf(frequencies)
    @Lazy
    var numbers = 0 to sizeOfFrequencies-1
    @Lazy
    var newFrequencies = flatten(frequencies map ((frequency, fi) -> 
            flatten((numbers - fi) map ((number) -> 
                (getAntinodesBetween(frequency.coords, frequencies[number].coords, times))
            ))
        ))
    ---
    if ((sizeOfFrequencies >= 2) and !isEmpty(newFrequencies))
        getAntinodes(frequencies,times+1,acc ++ newFrequencies)
    else acc
}
---
antennas groupBy ($.char) 
pluck ((frequencies) -> do {
    frequencies ++ getAntinodes(frequencies)
}) 
then flatten($) distinctBy $ 
then sizeOf($)