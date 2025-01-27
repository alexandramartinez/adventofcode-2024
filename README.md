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

Challenge: [Historian Hysteria](https://adventofcode.com/2024/day/1)

Example input:

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

Within each pair, figure out how far apart the two numbers are; you'll need to add up all of those distances. For example, if you pair up a 3 from the left list with a 7 from the right list, the distance apart is 4; if you pair up a 9 with a 3, the distance apart is 6.

To find the total distance between the left list and the right list, add up the distances between all of the pairs you found. In the example above, this is 2 + 1 + 0 + 1 + 2 + 5, a total distance of 11!

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

This time, you'll need to figure out exactly how often each number from the left list appears in the right list. Calculate a total similarity score by adding up each number in the left list after multiplying it by the number of times that number appears in the right list.

So, for these example lists, the similarity score at the end of this process is 31 (9 + 4 + 0 + 0 + 9 + 9).

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

Challenge: [Red-Nosed Reports](https://adventofcode.com/2024/day/2)

Example input:

```
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
```

### Part 1

The engineers are trying to figure out which reports are safe. The Red-Nosed reactor safety systems can only tolerate levels that are either gradually increasing or gradually decreasing. So, a report only counts as safe if both of the following are true:

- The levels are either all increasing or all decreasing.
- Any two adjacent levels differ by at least one and at most three.

So, in this example, 2 reports are safe.

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

Now, the same rules apply as before, except if removing a single level from an unsafe report would make it safe, the report instead counts as safe.

Thanks to the Problem Dampener, 4 reports are actually safe!

> *Horrible code. But I did what I had to do :(*

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

Challenge: [Mull It Over](https://adventofcode.com/2024/day/3)

Example inputs:

```
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
```

```
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
```

### Part 1

It seems like the goal of the program is just to multiply some numbers. It does that with instructions like mul(X,Y), where X and Y are each 1-3 digit numbers. For instance, mul(44,46) multiplies 44 by 46 to get a result of 2024. Similarly, mul(123,4) would multiply 123 by 4.

However, because the program's memory has been corrupted, there are also many invalid characters that should be ignored, even if they look like part of a mul instruction. Sequences like mul(4*, mul(6,9!, ?(12,34), or mul ( 2 , 4 ) do nothing.

Adding up the result of each instruction produces 161 (2*4 + 5*5 + 11*8 + 8*5).

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

There are two new instructions you'll need to handle:

- The do() instruction enables future mul instructions.
- The don't() instruction disables future mul instructions.

Only the most recent do() or don't() instruction applies. At the beginning of the program, mul instructions are enabled.

This time, the sum of the results is 48 `(2*4 + 8*5)`.

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

Challenge: [Ceres Search](https://adventofcode.com/2024/day/4)

Example input:

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

### Part 1

As the search for the Chief continues, a small Elf who lives on the station tugs on your shirt; she'd like to know if you could help her with her word search (your puzzle input). She only has to find one word: XMAS.

This word search allows words to be horizontal, vertical, diagonal, written backwards, or even overlapping other words. It's a little unusual, though, as you don't merely need to find one instance of XMAS - you need to find all of them.

In this word search, XMAS occurs a total of 18 times.

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

The Elf looks quizzically at you. Did you misunderstand the assignment?

Looking for the instructions, you flip over the word search to find that this isn't actually an XMAS puzzle; it's an X-MAS puzzle in which you're supposed to find two MAS in the shape of an X. One way to achieve that is like this:

```
M.S
.A.
M.S
```

In this example, an X-MAS appears 9 times.

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

Challenge: [Print Queue](https://adventofcode.com/2024/day/5)

Example input:

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

The first section specifies the page ordering rules, one per line. The first rule, 47|53, means that if an update includes both page number 47 and page number 53, then page number 47 must be printed at some point before page number 53. (47 doesn't necessarily need to be immediately before 53; other pages are allowed to be between them.)

The second section specifies the page numbers of each update. Because most safety manuals are different, the pages needed in the updates are different too. The first update, 75,47,61,53,29, means that the update consists of page numbers 75, 47, 61, 53, and 29.

For some reason, the Elves also need to know the middle page number of each update being printed. Because you are currently only printing the correctly-ordered updates, you will need to find the middle page number of each correctly-ordered update.

These have middle page numbers of 61, 53, and 29 respectively. Adding these page numbers together gives 143.

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

For each of the incorrectly-ordered updates, use the page ordering rules to put the page numbers in the right order. For the above example, here are the three incorrectly-ordered updates and their correct orderings:

- 75,97,47,61,53 becomes 97,75,47,61,53.
- 61,13,29 becomes 61,29,13.
- 97,13,75,29,47 becomes 97,75,47,29,13.

After taking only the incorrectly-ordered updates and ordering them correctly, their middle page numbers are 47, 29, and 47. Adding these together produces 123.

## 🔹 Day 6

Challenge: [Guard Gallivant](https://adventofcode.com/2024/day/6)

Example input:

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

The map shows the current position of the guard with ^ (to indicate the guard is currently facing up from the perspective of the map). Any obstructions - crates, desks, alchemical reactors, etc. - are shown as #.

Lab guards in 1518 follow a very strict patrol protocol which involves repeatedly following these steps:

- If there is something directly in front of you, turn right 90 degrees.
- Otherwise, take a step forward.

In this example, the guard will visit 41 distinct positions on your map.

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

Adding a single new obstruction won't cause a time paradox. They'd like to place the new obstruction in such a way that the guard will get stuck in a loop, making the rest of the lab safe to search.

To have the lowest chance of creating a time paradox, The Historians would like to know all of the possible positions for such an obstruction. The new obstruction can't be placed at the guard's starting position - the guard is there right now and would notice.

In the above example, there are only 6 different positions where a new obstruction would cause the guard to get stuck in a loop.

You need to get the guard stuck in a loop by adding a single new obstruction. How many different positions could you choose for this obstruction?

## 🔹 Day 7

Challenge: [Bridge Repair](https://adventofcode.com/2024/day/7)

Example input:

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

Operators are always evaluated left-to-right, not according to precedence rules. Furthermore, numbers in the equations cannot be rearranged. Glancing into the jungle, you can see elephants holding two different types of operators: add (+) and multiply (*).

Only three of the above equations can be made true by inserting operators:

- 190: 10 19 has only one position that accepts an operator: between 10 and 19. Choosing + would give 29, but choosing * would give the test value (10 * 19 = 190).
- 3267: 81 40 27 has two positions for operators. Of the four possible configurations of the operators, two cause the right side to match the test value: 81 + 40 * 27 and 81 * 40 + 27 both equal 3267 (when evaluated left-to-right)!
- 292: 11 6 16 20 can be solved in exactly one way: 11 + 6 * 16 + 20.

The engineers just need the total calibration result, which is the sum of the test values from just the equations that could possibly be true. In the above example, the sum of the test values for the three equations listed above is 3749.

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

The concatenation operator (||) combines the digits from its left and right inputs into a single number. For example, 12 || 345 would become 12345. All operators are still evaluated left-to-right.

Now, apart from the three equations that could be made true using only addition and multiplication, the above example has three more equations that can be made true by inserting operators:

- 156: 15 6 can be made true through a single concatenation: 15 || 6 = 156.
- 7290: 6 8 6 15 can be made true using 6 * 8 || 6 * 15.
- 192: 17 8 14 can be made true using 17 || 8 + 14.

Adding up all six test values (the three that could be made before using only + and * plus the new three that can now be made by also using ||) produces the new total calibration result of 11387.

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

## 🔹 Day 8 (unsolved)

Challenge: [Resonant Collinearity](https://adventofcode.com/2024/day/8)

Example input:

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

### Part 1 (unsolved)

Scanning across the city, you find that there are actually many such antennas. Each antenna is tuned to a specific frequency indicated by a single lowercase letter, uppercase letter, or digit.

The signal only applies its nefarious effect at specific antinodes based on the resonant frequencies of the antennas. In particular, an antinode occurs at any point that is perfectly in line with two antennas of the same frequency - but only when one of the antennas is twice as far away as the other. This means that for any pair of antennas with the same frequency, there are two antinodes, one on either side of them.

Because the topmost A-frequency antenna overlaps with a 0-frequency antinode, there are 14 total unique locations that contain an antinode within the bounds of the map.

How many unique locations within the bounds of the map contain an antinode?

## 🔹 Day 9

Challenge: [Disk Fragmenter](https://adventofcode.com/2024/day/9)

Example input:

```
2333133121414131402
```

### Part 1

The disk map uses a dense format to represent the layout of files and free space on the disk. The digits alternate between indicating the length of a file and the length of free space.

So, a disk map like 12345 would represent a one-block file, two blocks of free space, a three-block file, four blocks of free space, and then a five-block file. A disk map like 90909 would represent three nine-block files in a row (with no free space between them).

Each file on disk also has an ID number based on the order of the files as they appear before they are rearranged, starting with ID 0. So, the disk map 12345 has three files: a one-block file with ID 0, a three-block file with ID 1, and a five-block file with ID 2.

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

The eager amphipod already has a new plan: rather than move individual blocks, he'd like to try compacting the files on his disk by moving whole files instead.

This time, attempt to move whole files to the leftmost span of free space blocks that could fit the file. Attempt to move each file exactly once in order of decreasing file ID number starting with the file with the highest file ID number. If there is no span of free space to the left of a file that is large enough to fit the file, the file does not move.

The process of updating the filesystem checksum is the same; now, this example's checksum would be 2858.

## 🔹 Day 10

Challenge: [Hoof It](https://adventofcode.com/2024/day/10)

Example input:

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

The topographic map indicates the height at each position using a scale from 0 (lowest) to 9 (highest).

Based on un-scorched scraps of the book, you determine that a good hiking trail is as long as possible and has an even, gradual, uphill slope. For all practical purposes, this means that a hiking trail is any path that starts at height 0, ends at height 9, and always increases by a height of exactly 1 at each step. Hiking trails never include diagonal steps - only up, down, left, or right (from the perspective of the map).

This larger example has 9 trailheads. Considering the trailheads in reading order, they have scores of 5, 6, 5, 3, 1, 3, 5, 3, and 5. Adding these scores together, the sum of the scores of all trailheads is 36.

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

The paper describes a second way to measure a trailhead called its rating. A trailhead's rating is the number of distinct hiking trails which begin at that trailhead. 

Considering its trailheads in reading order, they have ratings of 20, 24, 10, 4, 1, 4, 5, 8, and 5. The sum of all trailhead ratings in this larger example topographic map is 81.

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

Challenge: [Plutonian Pebbles](https://adventofcode.com/2024/day/11)

Example input:

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

At first glance, they seem like normal stones: they're arranged in a perfectly straight line, and each stone has a number engraved on it.

The strange part is that every time you blink, the stones change.

Sometimes, the number engraved on a stone changes. Other times, a stone might split in two, causing all the other stones to shift over a bit to make room in their perfectly straight line.

As you observe them for a while, you find that the stones have a consistent behavior. Every time you blink, the stones each simultaneously change according to the first applicable rule in this list:

- If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
- If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
- If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.

No matter how the stones change, their order is preserved, and they stay on their perfectly straight line.

In this example, after blinking six times, you would have 22 stones. After blinking 25 times, you would have 55312 stones!

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

### Part 2 (unsolved)

The Historians sure are taking a long time. To be fair, the infinite corridors are very large.

How many stones would you have after blinking a total of 75 times?

## 🔹 Day 12

Challenge: [Garden Groups](https://adventofcode.com/2024/day/12)

Example input:

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

### Part 1 (unsolved)

Each garden plot grows only a single type of plant and is indicated by a single letter on your map. When multiple garden plots are growing the same type of plant and are touching (horizontally or vertically), they form a region.

In order to accurately calculate the cost of the fence around a single region, you need to know that region's area and perimeter.

The area of a region is simply the number of garden plots the region contains. The perimeter of a region is the number of sides of garden plots in the region that do not touch another garden plot in the same region.

Due to "modern" business practices, the price of fence required for a region is found by multiplying that region's area by its perimeter.

It contains:

- A region of R plants with price 12 * 18 = 216.
- A region of I plants with price 4 * 8 = 32.
- A region of C plants with price 14 * 28 = 392.
- A region of F plants with price 10 * 18 = 180.
- A region of V plants with price 13 * 20 = 260.
- A region of J plants with price 11 * 20 = 220.
- A region of C plants with price 1 * 4 = 4.
- A region of E plants with price 13 * 18 = 234.
- A region of I plants with price 14 * 22 = 308.
- A region of M plants with price 5 * 12 = 60.
- A region of S plants with price 3 * 8 = 24.

So, it has a total price of 1930.