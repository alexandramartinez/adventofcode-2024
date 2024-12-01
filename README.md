# Advent of Code 2024

DataWeave scripts used in the [adventofcode.com](https://adventofcode.com/) site for 2024.

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