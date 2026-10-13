-- Independent acceptance for the bounded pole-continuation diagnostic.
-- Usage: M2 --script accept.m2 EVIDENCE_DIRECTORY

if #scriptCommandLine != 2 then error "usage: M2 --script accept.m2 EVIDENCE_DIRECTORY";
evidenceDirectory = scriptCommandLine#1;
positiveOutput = lines get(evidenceDirectory | "/positive.stdout.txt");
zeroError = lines get(evidenceDirectory | "/invalid-zero.stderr.txt");
fullFrameError = lines get(evidenceDirectory | "/invalid-full-frame.stderr.txt");

requireLine = (output, expected, diagnostic) ->
    if not member(expected, output) then error diagnostic;
requireEqual = (actual, expected, diagnostic) ->
    if actual != expected then error diagnostic;
requireDiagnostic = (output, fragment, diagnostic) ->
    if not any(output, line -> match(fragment, line)) then error diagnostic;

caseField = (output, caseID, prefix, diagnostic) -> (
    caseStart = position(output, line -> line == "case_id=" | caseID);
    if caseStart === null then error diagnostic;
    remaining = drop(output, caseStart);
    fieldPosition = position(remaining, line -> match("^" | prefix, line));
    if fieldPosition === null then error diagnostic;
    remaining#fieldPosition
    );

-- Recompute the mathematical criterion independently of the producer's
-- parsing and output procedure.  A nonzero meridian cuts the C-circle in a
-- reduced degree-two scheme.  Two independent meridian lines have unit ideal.
R = QQ[sinC,cosC];
circle = ideal(sinC^2+cosC^2-1);
limitIdeal = (horizontalX,horizontalY) -> circle + ideal(horizontalX*cosC+horizontalY*sinC);
Y = limitIdeal(0,1);
minusY = limitIdeal(0,-1);
X = limitIdeal(1,0);
threeFour = limitIdeal(3,4);
sixEight = limitIdeal(6,8);
negativeFourThree = limitIdeal(-4,3);
rationalScaleIncoming = limitIdeal(3/2,2);
rationalScaleOutgoing = limitIdeal(9/4,3);
assert(dim(R/Y) == 0 and degree(R/Y) == 2 and radical Y == Y);
assert(Y+minusY == Y);
assert(Y+X == ideal(1_R));
assert(threeFour+sixEight == threeFour);
assert(threeFour+negativeFourThree == ideal(1_R));
assert(rationalScaleIncoming+rationalScaleOutgoing == rationalScaleIncoming);

requireLine(positiveOutput, "model=idealized_right_handed_active_Rz(C)Rx(A)_tip_plus_direction", "FULTON-CNC-MODEL");
requireLine(positiveOutput, "reduced_pole_freedom_dimension=1", "FULTON-CNC-POLE-DIMENSION");
requireLine(positiveOutput, "pole_radical_equals_original=true", "FULTON-CNC-POLE-REDUCED");
requireLine(positiveOutput, "PASS pole-continuation", "FULTON-CNC-EXECUTION");

requireEqual(caseField(positiveOutput,"y_to_y","status=","FULTON-CNC-CASE-Y-Y"), "status=LIMIT_SETS_INTERSECT", "FULTON-CNC-LIMIT-STATUS");
requireEqual(caseField(positiveOutput,"y_to_negative_y","status=","FULTON-CNC-CASE-Y-NEG-Y"), "status=LIMIT_SETS_INTERSECT", "FULTON-CNC-LIMIT-STATUS");
requireEqual(caseField(positiveOutput,"y_to_x","status=","FULTON-CNC-CASE-Y-X"), "status=LIMIT_SETS_DISJOINT", "FULTON-CNC-LIMIT-STATUS");
requireEqual(caseField(positiveOutput,"three_four_to_six_eight","status=","FULTON-CNC-CASE-3-4-6-8"), "status=LIMIT_SETS_INTERSECT", "FULTON-CNC-LIMIT-STATUS");
requireEqual(caseField(positiveOutput,"three_four_to_negative_four_three","status=","FULTON-CNC-CASE-3-4-NEG-4-3"), "status=LIMIT_SETS_DISJOINT", "FULTON-CNC-LIMIT-STATUS");
requireEqual(caseField(positiveOutput,"rational_rescaling","status=","FULTON-CNC-CASE-RATIONAL"), "status=LIMIT_SETS_INTERSECT", "FULTON-CNC-LIMIT-STATUS");

requireEqual(caseField(positiveOutput,"y_to_y","intersection_scheme_dimension=","FULTON-CNC-CASE-Y-Y"), "intersection_scheme_dimension=0", "FULTON-CNC-LIMIT-DIMENSION");
requireEqual(caseField(positiveOutput,"y_to_y","intersection_scheme_degree=","FULTON-CNC-CASE-Y-Y"), "intersection_scheme_degree=2", "FULTON-CNC-LIMIT-DEGREE");
requireEqual(caseField(positiveOutput,"y_to_y","intersection_scheme_reduced=","FULTON-CNC-CASE-Y-Y"), "intersection_scheme_reduced=true", "FULTON-CNC-LIMIT-REDUCED");
requireEqual(caseField(positiveOutput,"y_to_x","intersection_scheme=","FULTON-CNC-CASE-Y-X"), "intersection_scheme=empty", "FULTON-CNC-LIMIT-INTERSECTION");

requireDiagnostic(zeroError, "FULTON-CNC-ZERO-MERIDIAN", "FULTON-CNC-ZERO-MERIDIAN");
requireDiagnostic(fullFrameError, "FULTON-CNC-POSE-KIND", "FULTON-CNC-POSE-KIND");
print "PASS independent pole-continuation acceptance; only limiting C settings are graded";
exit 0;
