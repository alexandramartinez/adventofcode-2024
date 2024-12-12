# Advent of Code 2024

DataWeave scripts used in the [adventofcode.com](https://adventofcode.com/) site for 2024.

I used the [DataWeave extension for VS Code](https://marketplace.visualstudio.com/items?itemName=MuleSoftInc.dataweave) to create these scripts. Most of them should run in the [DataWeave Playground](https://dataweave.mulesoft.com/learn/dataweave) with no issue. However, some of the more complex examples have to run with the [DataWeave CLI](https://github.com/mulesoft-labs/data-weave-cli).

To run any script with the CLI, you can use the following syntax:

```shell
dw run -i payload=<path to payload file> -f <path to transform.dwl file>
```

For example:

```shell
dw run -i payload=scripts/day1/part1/inputs/payload.csv -f scripts/day1/part1/transform.dwl
```

If there's no input, just remove the `-i payload=<file>` part.

> [!TIP]
> Check out [Ryan's private leaderboard](https://adventofcode.com/2024/leaderboard/private/view/1739830)!

### Other Muleys doing DataWeave

- [Ryan Hoegg](https://github.com/rhoegg/adventofcode2024)
- [Pranav Davar](https://github.com/pranav-davar/advent-of-code-2024-dw)
- [Matthias Transier](https://github.com/mtransier/AdventOfCode2024)

## Similar repos

[![](https://github-readme-stats.vercel.app/api/pin/?username=alexandramartinez&repo=adventofcode-2023&theme=neon)](https://github.com/alexandramartinez/adventofcode-2023)
[![](https://github-readme-stats.vercel.app/api/pin/?username=alexandramartinez&repo=adventofcode-2022&theme=neon)](https://github.com/alexandramartinez/adventofcode-2022)

## 🔹 Day 1

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

Horrible code. But I did what I had to do :(

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

## 🔹 Day 6

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

## 🔹 Day 7

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

## 🔹 Day 9

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

## 🔹 Day 10

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