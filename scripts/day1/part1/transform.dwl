%dw 2.0
input payload application/csv separator=" ", header=false
output application/json
var a = payload.column_0 orderBy $
var b = payload.column_3 orderBy $
---
(0 to sizeOf(a)-1) map (abs(a[$] - b[$])) then sum($)