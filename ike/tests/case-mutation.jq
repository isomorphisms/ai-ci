# Derive one damaged result from the passing run captured by this job.
[inputs | select(test("^\\s*\\{")) | fromjson] |
if $mutation == "missing" then del(.[0])
elif $mutation == "duplicate" then [.[0]] + .
elif $mutation == "duplicate-replaces-next" then .[1] = .[0]
elif $mutation == "wrong-fixture" then .[0].fixture += "-other"
elif $mutation == "wrong-diagnostic" then .[0].observedCode += "-other"
elif $mutation == "reordered" then [.[1], .[0]] + .[2:]
elif $mutation == "failed-case" then .[0].status = "fail"
elif $mutation == "failed-coverage" then (.[] | select(.kind == "self-test-coverage").status) = "fail"
elif $mutation == "wrong-count" then .[-1].cases += 1
elif $mutation == "missing-summary" then .[:-1]
elif $mutation == "duplicate-summary" then . + [.[-1]]
elif $mutation == "early-summary" then [.[-1]] + .[:-1]
elif $mutation == "summary-only" then [.[-1]]
else error("unknown mutation: " + $mutation) end | .[] | @json
