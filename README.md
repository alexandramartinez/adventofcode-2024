# Advent of Code 2024

DataWeave scripts used in the [adventofcode.com](https://adventofcode.com/) site for 2024.

> [!TIP]
> Check out [Ryan's private leaderboard](https://adventofcode.com/2024/leaderboard/private/view/1739830)!

### Other Muleys doing DataWeave

- [Ryan Hoegg](https://github.com/rhoegg/adventofcode2024)
- [Pranav Davar](https://github.com/pranav-davar/advent-of-code-2024-dw)

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