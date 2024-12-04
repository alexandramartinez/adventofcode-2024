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