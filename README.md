# Advent of Code 2024

DataWeave scripts used in the [adventofcode.com](https://adventofcode.com/) site for 2024.

I used the [DataWeave extension for VS Code](https://marketplace.visualstudio.com/items?itemName=MuleSoftInc.dataweave) to create these scripts. Most of them should run in the [DataWeave Playground](https://dataweave.mulesoft.com/learn/dataweave) with no issue. However, some of the more complex examples have to run with the [DataWeave CLI](https://github.com/mulesoft-labs/data-weave-cli).

To run any script with the CLI, you can use the following syntax (or use my [ProstDev Tools](https://marketplace.visualstudio.com/items?itemName=ProstDev.prostdev-tools) VSCode extension):

```shell
dw run -i payload=<path to payload file> -f <path to transform.dwl file>
```

For example:

```shell
dw run -i payload=scripts/day1/part1/inputs/payload.csv -f scripts/day1/part1/transform.dwl
```

If there's no input, just remove the `-i payload=<file>` part.

You can filter the challenges using one of the following keywords (ctrl+F or cmd+F):
- Keywords: `csv`, `math`, `regex`, `reduce`, `strings`, `lines`, `matrix`, `ordering`, `two inputs`, `rules`, `navigation`, `recursive`, `tree`, `comparisons/matching`

> [!TIP]
> Check out [Ryan's private leaderboard](https://adventofcode.com/2024/leaderboard/private/view/1739830)!

## Similar repos

[![](https://github-readme-stats.vercel.app/api/pin/?username=alexandramartinez&repo=adventofcode-2023&theme=neon)](https://github.com/alexandramartinez/adventofcode-2023)
[![](https://github-readme-stats.vercel.app/api/pin/?username=alexandramartinez&repo=adventofcode-2022&theme=neon)](https://github.com/alexandramartinez/adventofcode-2022)

## Table of Contents

Total stars: ⭐️ 25 / 50 

![](https://progress-bar.xyz/50?width=500)

- ⭐️⭐️ [Day 1](#-day-1)
- ⭐️⭐️ [Day 2](#-day-2)
- ⭐️⭐️ [Day 3](#-day-3)
- ⭐️⭐️ [Day 4](#-day-4)
- ⭐️ [Day 5](#-day-5)
- ⭐️ [Day 6](#-day-6)
- ⭐️⭐️ [Day 7](#-day-7)
- ⭐️⭐️ [Day 8](#-day-8)
- ⭐️ [Day 9](#-day-9)
- ⭐️⭐️ [Day 10](#-day-10)
- ⭐️⭐️ [Day 11](#-day-11)
- ⭐️ [Day 12](#-day-12)
- Day 13
- Day 14
- Day 15
- Day 16
- Day 17
- Day 18
- ⭐️ [Day 19](#-day-19)
- Day 20
- Day 21
- Day 22
- ⭐️⭐️ [Day 23](#-day-23)
- ⭐️ [Day 24](#-day-24)
- ⭐️ [Day 25](#-day-25)

## 🔹 Day 1

- Challenge: [Historian Hysteria](https://adventofcode.com/2024/day/1)
- Keywords: `csv`, `math`
- Example input:

    ```
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    ```

</details>

### Part 1

<details>
  <summary>Script</summary>

```dataweave
%dw 2.0
input payload application/csv separator=" ", header=false
output application/json
var a = payload.column_0 orderBy $
var b = payload.column_3 orderBy $
---
(0 to sizeOf(a)-1) map (abs(a[$] - b[$])) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday1%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
import countBy from dw::core::Arrays
var p = read(payload, "application/csv", {header:false,separator:" "})
var a = p.column_0
var b = p.column_3
---
a map ((item) -> 
    (b countBy ($==item)) * item
) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday1%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 2

- Challenge: [Red-Nosed Reports](https://adventofcode.com/2024/day/2)
- Keywords: `reduce`, `lines`
- Example input:

```
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
import every, countBy from dw::core::Arrays
var decreasing = "decreasing"
var increasing = "increasing"
---
((payload splitBy "\n") map (
    (($ splitBy " ") reduce ((number, a=[]) -> 
        if (isEmpty(a)) a+{
            prevNum: number,
            operation: null,
            isSafe: true
        } else (a[-1].operation match {
            case null -> a+{
                prevNum: number,
                operation: if (a[-1].prevNum-number > 0) decreasing else increasing,
                isSafe: [1, 2, 3] contains abs(a[-1].prevNum - number) 
            }
            case "$(decreasing)" -> a+{
                prevNum: number,
                operation: a[-1].operation,
                isSafe: [1, 2, 3] contains (a[-1].prevNum - number)
            }
            else -> a+{
                prevNum: number,
                operation: a[-1].operation,
                isSafe: [1, 2, 3] contains (number - a[-1].prevNum)
            }
        })
    )).isSafe every $
)) countBy $
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday2%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

> Horrible code. But I did what I had to do :(

<details>
  <summary>Script</summary>

```dataweave
import every, countBy from dw::core::Arrays
var decreasing = "decreasing"
var increasing = "increasing"
var newp = ((payload splitBy "\n") map (
    (($ splitBy " ") reduce ((number, a=[]) -> 
        if (isEmpty(a)) a+{
            prevNum: number,
            operation: null,
            isSafe: true
        } else (a[-1].operation match {
            case null -> a+{
                prevNum: number,
                operation: if (a[-1].prevNum-number > 0) decreasing else increasing,
                isSafe: [1, 2, 3] contains abs(a[-1].prevNum - number) 
            }
            case "$(decreasing)" -> a+{
                prevNum: number,
                operation: a[-1].operation,
                isSafe: [1, 2, 3] contains (a[-1].prevNum - number)
            }
            else -> a+{
                prevNum: number,
                operation: a[-1].operation,
                isSafe: [1, 2, 3] contains (number - a[-1].prevNum)
            }
        })
    ))
))
var safeOnes = newp filter ((item) -> item.isSafe every $)
var unsafeOnes = newp -- safeOnes
fun getScenarios(data) = data map ($ reduce ((number, a=[]) ->
    if (isEmpty(a)) a+{
        prevNum: number,
        operation: null,
        isSafe: true
    } else (a[-1].operation match {
        case null -> a+{
            prevNum: number,
            operation: if (a[-1].prevNum-number > 0) decreasing else increasing,
            isSafe: [1, 2, 3] contains abs(a[-1].prevNum - number) 
        }
        case "$(decreasing)" -> a+{
            prevNum: number,
            operation: a[-1].operation,
            isSafe: [1, 2, 3] contains (a[-1].prevNum - number)
        }
        else -> a+{
            prevNum: number,
            operation: a[-1].operation,
            isSafe: [1, 2, 3] contains (number - a[-1].prevNum)
        }
    })
))
---
unsafeOnes map ((firstArray) -> 
    getScenarios(firstArray.prevNum map ((number, numIndex) -> 
        firstArray.prevNum filter ((item, index) -> index != numIndex)
    )) filter ((item) -> item.isSafe every $)
) filter (!isEmpty($)) 
then sizeOf($)+sizeOf(safeOnes)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday2%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 3

- Challenge: [Mull It Over](https://adventofcode.com/2024/day/3)
- Keywords: `regex`, `reduce`, `strings`
- Example inputs:

```
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
```

```
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
(flatten(payload scan /mul\(\d+,\d+\)/)) map do {
    var nums = flatten($ scan /\d+/)
    ---
    nums[0] * nums[1]
} then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday3%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
(payload scan /(mul|don't|do)\(\d*,?\d*\)/) reduce ((op, a={r:0,"do":true}) -> 
    op[0][0 to 2] match {
        case "mul" -> do {
            var nums = flatten(op[0] scan /\d+/)
            var newR = a.r + ((nums[0] default 0) * (nums[1] default 0))
            ---
            {
                r: if (a."do") newR else a.r,
                "do": a."do"
            }
        }
        case "don" -> { r: a.r, "do": false }
        else -> { r: a.r, "do": true }
    }
) then $.r
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday3%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 4

- Challenge: [Ceres Search](https://adventofcode.com/2024/day/4)
- Keywords: `matrix`
- Example inputs:

```
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
```

```
M.S
.A.
M.S
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
var lines = payload splitBy "\n"
var XMAS = "XMAS"
fun getLetter(x:Number,y:Number) = if ((x<0) or (y<0)) "" else (lines[x][y] default "")
fun getStr(str:String,x:Number,y:Number) = if ((x<0) or (y<0)) "" else (str[x to y])
---
flatten
(lines map ((lineStr, lineidx) -> 
    (lineStr splitBy "") map ((letter, letteridx) ->
        if (letter=="X") (
            // right
            (if (XMAS == getStr(lineStr,letteridx,letteridx+3)) 1 else 0)
            // left
            + (if (XMAS == getStr(lineStr,letteridx,letteridx-3)) 1 else 0)
            // down
            + (if (XMAS == (letter ++ getLetter(lineidx+1,letteridx) ++ getLetter(lineidx+2,letteridx) ++ getLetter(lineidx+3,letteridx))) 1 else 0)
            // // up
            + (if (XMAS == (letter ++ getLetter(lineidx-1,letteridx) ++ getLetter(lineidx-2,letteridx) ++ getLetter(lineidx-3,letteridx))) 1 else 0)
            // down-right
            + (if (XMAS == (letter ++ getLetter(lineidx+1,letteridx+1) ++ getLetter(lineidx+2,letteridx+2) ++ getLetter(lineidx+3,letteridx+3))) 1 else 0)
            // down-left
            + (if (XMAS == (letter ++ getLetter(lineidx+1,letteridx-1) ++ getLetter(lineidx+2,letteridx-2) ++ getLetter(lineidx+3,letteridx-3))) 1 else 0)
            // up-right
            + (if (XMAS == (letter ++ getLetter(lineidx-1,letteridx+1) ++ getLetter(lineidx-2,letteridx+2) ++ getLetter(lineidx-3,letteridx+3))) 1 else 0)
            // up-left
            + (if (XMAS == (letter ++ getLetter(lineidx-1,letteridx-1) ++ getLetter(lineidx-2,letteridx-2) ++ getLetter(lineidx-3,letteridx-3))) 1 else 0)
        )
        else 0
    )
)) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday4%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
var lines = payload splitBy "\n"
fun getLetter(x:Number,y:Number) = if ((x<0) or (y<0)) "" else (lines[x][y] default "")
var xmas = ["MAS", "SAM"]
---
flatten
(lines map ((lineStr, lineidx) -> 
    (lineStr splitBy "") map ((letter, letteridx) ->
        if (letter=="A") do {
            var topleft = getLetter(lineidx-1, letteridx-1)
            var topright = getLetter(lineidx-1, letteridx+1)
            var bottomleft = getLetter(lineidx+1, letteridx-1)
            var bottomright = getLetter(lineidx+1, letteridx+1)
            var cross1 = topleft ++ letter ++ bottomright
            var cross2 = topright ++ letter ++ bottomleft
            ---
            if ( (xmas contains cross1) and (xmas contains cross2) ) 1 else 0
        }
        else 0
    )
)) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday4%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 5

- Challenge: [Print Queue](https://adventofcode.com/2024/day/5)
- Keywords: `lines`, `ordering`, `two inputs`, `rules`
- Example input:

```
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
import every from dw::core::Arrays
import substringBefore, substringAfter from dw::core::Strings
var p = payload splitBy "\n\n"
var orderingRules = p[0]
var updatesLines = p[1]splitBy "\n"
fun flatScan(a,b) = flatten(a scan b)
---
updatesLines map ((line, lineidx) -> do {
    var arr = (line splitBy ",")
    var isCorrect = (arr map ((num, numindex) -> 
        ((orderingRules flatScan "$(num)\|\d+|\d+\|$(num)") map (
            ((arr[numindex+1 to -1] default "") contains ($ substringBefore "|"))
            or ((if(numindex==0) "" else arr[numindex-1 to 0]) contains ($ substringAfter "|"))
        )) every (!$)
    )) every ($)
    ---
    if (isCorrect) arr[round(sizeOf(arr)/2)-1] as Number
    else 0
}) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday5%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2 (unsolved)

tbd

## 🔹 Day 6

- Challenge: [Guard Gallivant](https://adventofcode.com/2024/day/6)
- Keywords: `matrix`, `navigation`, `recursive`
- Example input:

```
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
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
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday6%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2 (unsolved)

tbd

## 🔹 Day 7

- Challenge: [Bridge Repair](https://adventofcode.com/2024/day/7)
- Keywords: `math`, `lines`, `recursive`, `tree`
- Example input:

```
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
%dw 2.0
import drop from dw::core::Arrays
import lines from dw::core::Strings
fun flatScan(a, b) = flatten(a scan b)
fun getResults(values, r=0) = do {
    var this = values[0]
    var next = values[1]
    var newValues = values drop 1
    ---
    if (isEmpty(next)) r
    else if (r==0) flatten([getResults(newValues, this+next), getResults(newValues, this*next)])
    else flatten([getResults(newValues, r+next),  getResults(newValues, r*next)])
}
---
lines(payload) map ((equation, equationIndex) -> do {
    var nums = equation flatScan /\d+/
    var result = nums[0] as Number
    var values = nums[1 to -1] map ($ as Number)
    ---
    if (getResults(values) contains result) result else 0
}) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday7%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
%dw 2.0
import drop from dw::core::Arrays
import lines from dw::core::Strings
fun flatScan(a, b) = flatten(a scan b)
fun getResults(values, r=0) = do {
    var this = values[0]
    var next = values[1]
    var newValues = values drop 1
    ---
    if (isEmpty(next)) r
    else if (r==0) flatten([getResults(newValues, this+next), getResults(newValues, this*next), getResults(newValues, "$this$next" as Number)])
    else flatten([getResults(newValues, r+next),  getResults(newValues, r*next), getResults(newValues, "$r$next" as Number)])
}
---
lines(payload) map ((equation, equationIndex) -> do {
    var nums = equation flatScan /\d+/
    var result = nums[0] as Number
    var values = nums[1 to -1] map ($ as Number)
    ---
    if (getResults(values) contains result) result else 0
}) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday7%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 8

- Challenge: [Resonant Collinearity](https://adventofcode.com/2024/day/8)
- Keywords: `matrix`, `recursive`
- Example input:

```
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
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
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday8%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
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
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday8%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 9

- Challenge: [Disk Fragmenter](https://adventofcode.com/2024/day/9)
- Keywords: `reduce`, `strings`, `lines`
- Example input:

```
2333133121414131402
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
import divideBy from dw::core::Arrays
var p = (payload splitBy "")
fun repeat(text: String, times: Number): Array =
    if(times <= 0) [] else (1 to times) map text
var files:Array = flatten((p divideBy 2) map ((item, index) -> 
    repeat(index, item[0]) ++ repeat(".", item[1] default 0)
))
var filesClean:Array = files - "."
var thisthing = (files reduce ((item, acc={ r:[], idx:-1 }) -> item match {
    case "." -> {
        r: acc.r + filesClean[acc.idx],
        idx: acc.idx - 1
    }
    else -> {
        r: acc.r + item,
        idx: acc.idx
    }
}))
---
thisthing.r[0 to thisthing.idx] map ($*$$) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday9%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2 (unsolved)

tbd

## 🔹 Day 10

- Challenge: [Hoof It](https://adventofcode.com/2024/day/10)
- Keywords: `matrix`, `navigation`, `recursive`
- Example input:

```
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
var lines = payload splitBy "\n"
fun getChar(x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (lines[x][y] default "")
fun getRoutes(num:Number,numidx:Number,lineidx:Number) = do {
    var nextNum = num+1
    ---
    if (num ~= 9) [{x:numidx,y:lineidx}]
    else 
        (if (getChar(lineidx-1,numidx) ~= nextNum) getRoutes(nextNum,numidx,lineidx-1) else [])
        ++
        (if (getChar(lineidx+1,numidx) ~= nextNum) getRoutes(nextNum,numidx,lineidx+1) else [])
        ++
        (if (getChar(lineidx,numidx-1) ~= nextNum) getRoutes(nextNum,numidx-1,lineidx) else [])
        ++
        (if (getChar(lineidx,numidx+1) ~= nextNum) getRoutes(nextNum,numidx+1,lineidx) else [])
}
---
flatten(lines map ((line, lineidx) -> 
    (line splitBy "") map ((num, numidx) -> 
        num match {
            case "0" -> sizeOf(getRoutes(0,numidx,lineidx) distinctBy $)
            else -> 0
        }
    )
)) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday10%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
var lines = payload splitBy "\n"
fun getChar(x:Number,y:Number):String = if ((x<0) or (y<0)) "" else (lines[x][y] default "")
fun getRoutes(num:Number,numidx:Number,lineidx:Number) = do {
    var nextNum = num+1
    ---
    if (num ~= 9) 1
    else 
        (if (getChar(lineidx-1,numidx) ~= nextNum) getRoutes(nextNum,numidx,lineidx-1) else 0)
        +
        (if (getChar(lineidx+1,numidx) ~= nextNum) getRoutes(nextNum,numidx,lineidx+1) else 0)
        +
        (if (getChar(lineidx,numidx-1) ~= nextNum) getRoutes(nextNum,numidx-1,lineidx) else 0)
        +
        (if (getChar(lineidx,numidx+1) ~= nextNum) getRoutes(nextNum,numidx+1,lineidx) else 0)
}
---
flatten(lines map ((line, lineidx) -> 
    (line splitBy "") map ((num, numidx) -> 
        num match {
            case "0" -> getRoutes(0,numidx,lineidx)
            else -> 0
        }
    )
)) then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday10%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 11

- Challenge: [Plutonian Pebbles](https://adventofcode.com/2024/day/11)
- Keywords: `recursive`
- Example input:

```
Initial arrangement:
125 17

After 1 blink:
253000 1 7

After 2 blinks:
253 0 2024 14168

After 3 blinks:
512072 1 20 24 28676032

After 4 blinks:
512 72 2024 2 0 2 4 2867 6032

After 5 blinks:
1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32

After 6 blinks:
2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
fun removeExtraZeros(num:String):String = num as Number as String
fun blink(arr) = flatten(arr map ((num, numidx) -> 
    num match {
        case "0" -> "1"
        case n if isEven(sizeOf(n)) -> do {
            var i = sizeOf(n)/2
            ---
            [removeExtraZeros(n[0 to i-1]),removeExtraZeros(n[i to -1])]
        }
        else -> ($ * 2024) as String
    }
))
fun blinkTimes(arr,times:Number=1) = times match {
    case 0 -> arr
    else -> blink(arr) blinkTimes times-1
}
---
sizeOf((payload splitBy " ") blinkTimes 25)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday11%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
output application/json
fun removeExtraZeros(num:String):String = num as Number as String
fun blink(obj:Object) = namesOf(obj) reduce ((item, result={}) -> do {
    var itemValue = obj."$item"
    ---
    item match {
        case "0" -> result update {
            case new at ."1"! -> (new default 0) + itemValue
        }
        case n if isEven(sizeOf(n)) -> do {
            var i = sizeOf(n)/2
            var n1 = removeExtraZeros(n[0 to i-1])
            var n2 = removeExtraZeros(n[i to -1])
            var isSame = n1 == n2
            ---
            if (isSame) result update {
                case new at ."$n1"! -> (new default 0) + (itemValue * 2)
            } 
            else result update {
                case new1 at ."$n1"! -> (new1 default 0) + itemValue
                case new2 at ."$n2"! -> (new2 default 0) + itemValue
            }
        }
        else -> result update {
            case new at ."$($ * 2024)"! -> (new default 0) + itemValue
        }
    }
})
fun blinkTimes(obj:Object,times:Number) = times match {
    case 0 -> obj
    else -> blink(obj) blinkTimes times-1
}
fun arrToObj(arr:Array,result={}) = arr match {
    case [head ~ tail] -> tail arrToObj (result update {
        case x at ."$head"! -> (x default 0) + 1
    })
    case [] -> result
}
---
arrToObj(payload splitBy " ") blinkTimes 75
then sum(valuesOf($))
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday11%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 12

- Challenge: [Garden Groups](https://adventofcode.com/2024/day/12)
- Keywords: `matrix`, `navigation`, `recursive`, `reduce`
- Example input:

```
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
```

### Part 1

> Ran with the full input in the DW CLI online [here](https://github.com/alexandramartinez/dwcli-github-actions/actions/runs/13143859945). Took less than 4 min. Not my best code :')

<details>
  <summary>Script</summary>

```dataweave
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
---
regionsStringCoords map ((region) -> do {
    var plants = region map ((str) -> do {
        var strSplit = str splitBy ","
        var plant = getPlant(strSplit[0] as Number, strSplit[1] as Number)
        var left = getPlant(plant.coords.x-1, plant.coords.y).char
        var right = getPlant(plant.coords.x+1, plant.coords.y).char
        var up = getPlant(plant.coords.x, plant.coords.y-1).char
        var down = getPlant(plant.coords.x, plant.coords.y+1).char
        var p = [
            (left) if (left == plant.char),
            (right) if (right == plant.char),
            (up) if (up == plant.char),
            (down) if (down == plant.char)
        ]
        ---
        {
            (plant),
            area: 1,
            perimeter: 4-sizeOf(p)
        }
    })
    ---
    sum(plants.area) * sum(plants.perimeter)
}) 
then sum($)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday12%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 19

- Challenge: [Linen Layout](https://adventofcode.com/2024/day/19)
- Keywords: `strings`, `lines`, `two inputs`, `rules`, `recursive`
- Example input:

```
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
import countBy from dw::core::Arrays
import lines, substringAfter from dw::core::Strings
output application/json
var split = payload splitBy "\n\n"
var patternsList = split[0] splitBy ", "
fun checkDesign(initialDesign:String, currentDesign:String, acc="") = do {
    var filtered = patternsList filter (currentDesign startsWith $)
    ---
    if (isEmpty(currentDesign))
        initialDesign == acc
    else if (isEmpty(filtered)) false
    else filtered 
    reduce ((pattern, matches=false) -> 
        if (matches) true
        else checkDesign(
            initialDesign,
            currentDesign substringAfter pattern,
            acc ++ pattern
        ) 
    )
}
---
(lines(split[1]) map ((design) -> 
    checkDesign(design,design)
)) countBy $
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday19%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2 (unsolved)

tbd

## 🔹 Day 23

- Challenge: [LAN Party](https://adventofcode.com/2024/day/23)
- Keywords: `lines`, `comparisons/matching`
- Example input:

```
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
import lines from dw::core::Strings
output application/json
var connections = lines(payload) map ($ splitBy "-") reduce ((item, a={}) -> 
    a update {
        case x at ."$(item[0])"! -> (a[item[0]] default []) + item[1]
        case y at ."$(item[1])"! -> (a[item[1]] default []) + item[0]
    }
)
var matches = flatten(namesOf(connections) map ((computer1) -> 
    flatten(connections[computer1] map ((computer2) -> do {
        var threeMatchesOne = (connections[computer2] filter ((computer3) -> connections[computer3] contains computer1))
        ---
        if (!isEmpty(threeMatchesOne)) 
            threeMatchesOne filter ((computer3) -> (computer1 startsWith "t") or (computer2 startsWith "t") or (computer3 startsWith "t"))
            map ((computer3) ->
                [computer1, computer2, computer3] orderBy $
            )
        else []
    })) 
)) distinctBy $
---
sizeOf(matches)
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday23%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

<details>
  <summary>Script</summary>

```dataweave
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
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday23%2Fpart2"><img width="300" src="/images/dwplayground-button.png"><a>

## 🔹 Day 24

- Challenge: [Crossed Wires](https://adventofcode.com/2024/day/24)
- Keywords: `strings`, `lines`, `two inputs`, `rules`, `recursive`, `comparisons/matching`
- Example input:

```
x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj
```

### Part 1

<details>
  <summary>Script</summary>

```dataweave
import fromBinary from dw::core::Numbers
import lines from dw::core::Strings
output application/json
var splitPayload = payload splitBy "\n\n"
var wires:Object = (lines(splitPayload[0]) map ($ splitBy ": ")) reduce ((item, a={}) -> 
    a ++ {
        (item[0]): item[1] ~= 1
    }
)
fun getWiresObject(gates:Array<String>, wiresRec) = {
    (gates map ((gate) -> do {
        @Lazy
        var split = gate splitBy " "
        @Lazy
        var wire1 = split[0]
        @Lazy
        var wire2 = split[2]
        @Lazy
        var wire3 = split[-1]
        ---
        if (!isEmpty(wiresRec[wire1]) and !isEmpty(wiresRec[wire2])) {
            (wire3): split[1] match {
                case "AND" -> wiresRec[wire1] and wiresRec[wire2]
                case "OR" -> wiresRec[wire1] or wiresRec[wire2]
                case "XOR" -> wiresRec[wire1] != wiresRec[wire2]
            }
        }
        else {
            keepTrying: gate
        }
    }))
}
fun getWiresTailRec(gates:Array<String>, wiresRec=wires) = do {
    var result = getWiresObject(gates, wiresRec)
    var newGates = result.*keepTrying
    var newWires = wiresRec ++ result
    ---
    if (isEmpty(newGates)) newWires 
    else getWiresTailRec(newGates, newWires - "keepTrying")
}
---
getWiresTailRec(lines(splitPayload[1])) 
filterObject ($$ startsWith "z")
orderBy $$
mapObject (($$): if ($) 1 else 0)
then fromBinary(valuesOf($)[-1 to 0] joinBy "")
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday24%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2 (unsolved)

tbd

## 🔹 Day 25

- Challenge: [Code Chronicle](https://adventofcode.com/2024/day/25)
- Keywords: `matrix`, `two inputs`, `comparisons/matching`
- Example input:

```
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
```

### Part 1 

<details>
  <summary>Script</summary>

```dataweave
import every, countBy from dw::core::Arrays
output application/json
fun getMap(arr) = arr map ((item) -> do {
    var lines = (item splitBy "\n")[1 to -2]
    ---
    (0 to sizeOf(lines)-1) map (
        sum(lines map ((line) -> 
            if (line[$] == "#") 1 else 0
        ))
    )
})
var arr = (payload splitBy "\n\n")
var locks = getMap(arr filter ($ startsWith "#####"))
var keys = getMap(arr filter ($ startsWith "....."))
---
sum(locks map ((lock, locki) -> 
    (keys map ((key, keyi) -> 
        (key map ((keypin, keypini) -> 
            5-keypin >= lock[keypini]
        )) every $
    )) countBy $
))
```
</details>

<a href="https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2024&path=scripts%2Fday25%2Fpart1"><img width="300" src="/images/dwplayground-button.png"><a>

### Part 2

> Need to finish the rest of the challenges to be unlocked x-x