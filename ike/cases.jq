# Ike echoes its recipes. The core verifier emits one JSON object per line.
def reject($reason): ("aici-ike-cases: " + $reason + "\n") | halt_error(1);

def manifest_cases:
  split("\n") | map(
    gsub("^\\s+|\\s+$"; "") | select(. != "" and (startswith("#") | not)) |
    split("\t") |
    if length != 4 or .[1] == "" or .[2] == "" then reject("invalid manifest row")
    elif .[0] == "pass" and .[3] == "-" then .[3] = ""
    elif .[0] == "fail" and .[3] != "" and .[3] != "-" then .
    else reject("invalid manifest expectation") end
  ) | if length == 0 then reject("empty manifest") else . end;

($manifest | manifest_cases) as $expected |
[inputs | select(test("^\\s*\\{")) | fromjson] as $rows |
if ($rows | map(select(.kind == "self-test-summary")) | length) != 1
   or $rows[-1].kind != "self-test-summary" then reject("expected one final summary")
elif ($rows[-1] | [.status, .cases, .failures]) != ["pass", ($expected | length), 0]
then reject("summary result mismatch")
else
  $rows[:-1] | map(
    if .kind == "self-test-coverage" then
      if .status == "pass" then empty else reject("coverage failed") end
    elif .kind != "self-test" then reject("unexpected result kind")
    elif .status != "pass" then reject("case failed")
    else [.expected, .contract, .fixture, .observedCode] end
  ) |
  if length != ($expected | length) then reject("case count mismatch")
  elif . != $expected then reject("case identity or diagnostic mismatch")
  else {verified_core_cases: length} end
end
