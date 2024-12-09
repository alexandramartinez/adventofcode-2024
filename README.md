# Advent of Code 2024

DataWeave scripts used in the [adventofcode.com](https://adventofcode.com/) site for 2024.

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