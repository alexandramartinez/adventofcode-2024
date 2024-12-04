(flatten(payload scan /mul\(\d+,\d+\)/)) map do {
    var nums = flatten($ scan /\d+/)
    ---
    nums[0] * nums[1]
} then sum($)