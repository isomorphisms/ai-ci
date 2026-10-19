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
    if #select(output, line -> line == "case_id=" | caseID) != 1 then error "FULTON-CNC-CASE-IDENTITY";
    caseStart = position(output, line -> line == "case_id=" | caseID);
    if caseStart === null then error diagnostic;
    remaining = drop(output, caseStart+1);
    nextCase = position(remaining, line -> match("^case_id=", line));
    caseLines = if nextCase === null then remaining else take(remaining,nextCase);
    matches = select(caseLines, line -> match("^" | prefix, line));
    if #matches != 1 then error diagnostic;
    matches#0
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

-- Each case is checked within its own record.  Missing fields cannot borrow
-- the next case's values.  Recompute every equation and Groebner basis, not
-- just status labels.  This independent case specification is trusted input.
expectedMeridians = {
    {"y_to_y",0,1,0,1},
    {"y_to_negative_y",0,1,0,-1},
    {"y_to_x",0,1,1,0},
    {"three_four_to_six_eight",3,4,6,8},
    {"three_four_to_negative_four_three",3,4,-4,3},
    {"rational_rescaling",3/2,2,9/4,3},
    {"irrational_settings",1,1,-2,-2}
    };
requireEqual(select(positiveOutput,line -> match("^case_id=",line)),
    apply(expectedMeridians,record -> "case_id=" | record#0), "FULTON-CNC-CASE-IDENTITY");
idealLine = (horizontalX,horizontalY) -> "(sinC^2+cosC^2-1," |
    toString horizontalX | "*cosC+" | toString horizontalY | "*sinC)";
scan(expectedMeridians, record -> (
    caseID=record#0;
    incoming=limitIdeal(record#1,record#2);
    outgoing=limitIdeal(record#3,record#4);
    meet=incoming+outgoing;
    cross=record#1*record#4-record#2*record#3;
    -- Analytic real check: each line through the origin cuts the circle in
    -- +/-(-horizontalX,horizontalY)/sqrt(horizontalX^2+horizontalY^2).
    assert(record#1^2+record#2^2 > 0 and record#3^2+record#4^2 > 0);
    requireEqual(caseField(positiveOutput,caseID,"incoming_limit_ideal=","FULTON-CNC-LIMIT-EQUATIONS"),
        "incoming_limit_ideal=" | idealLine(record#1,record#2),"FULTON-CNC-LIMIT-EQUATIONS");
    requireEqual(caseField(positiveOutput,caseID,"outgoing_limit_ideal=","FULTON-CNC-LIMIT-EQUATIONS"),
        "outgoing_limit_ideal=" | idealLine(record#3,record#4),"FULTON-CNC-LIMIT-EQUATIONS");
    requireEqual(caseField(positiveOutput,caseID,"limit_determinant=","FULTON-CNC-DETERMINANT"),
        "limit_determinant=" | toString cross,"FULTON-CNC-DETERMINANT");
    requireEqual(caseField(positiveOutput,caseID,"intersection_ideal_groebner=","FULTON-CNC-LIMIT-EQUATIONS"),
        "intersection_ideal_groebner=" | toString gens gb meet,"FULTON-CNC-LIMIT-EQUATIONS");
    requireEqual(caseField(positiveOutput,caseID,"status=","FULTON-CNC-LIMIT-STATUS"),
        "status=" | if cross==0 then "LIMIT_SETS_INTERSECT" else "LIMIT_SETS_DISJOINT","FULTON-CNC-LIMIT-STATUS");
    if cross==0 then (
        assert(dim(R/meet)==0 and degree(R/meet)==2 and radical meet==meet);
        requireEqual(caseField(positiveOutput,caseID,"intersection_scheme_dimension=","FULTON-CNC-LIMIT-DIMENSION"),
            "intersection_scheme_dimension=0","FULTON-CNC-LIMIT-DIMENSION");
        requireEqual(caseField(positiveOutput,caseID,"intersection_scheme_degree=","FULTON-CNC-LIMIT-DEGREE"),
            "intersection_scheme_degree=2","FULTON-CNC-LIMIT-DEGREE");
        requireEqual(caseField(positiveOutput,caseID,"intersection_scheme_reduced=","FULTON-CNC-LIMIT-REDUCED"),
            "intersection_scheme_reduced=true","FULTON-CNC-LIMIT-REDUCED");
        ) else (
        assert(meet==ideal(1_R));
        requireEqual(caseField(positiveOutput,caseID,"intersection_scheme=","FULTON-CNC-LIMIT-INTERSECTION"),
            "intersection_scheme=empty","FULTON-CNC-LIMIT-INTERSECTION");
        );
    ));
Q=QQ[poleSinA,poleCosA,poleSinC,poleCosC];
pole=ideal(poleSinA,poleCosA-1,poleSinC^2+poleCosC^2-1);
assert(dim(Q/pole)==1 and radical pole==pole);
requireLine(positiveOutput,"pole_ideal_groebner=" | toString gens gb pole,"FULTON-CNC-POLE-EQUATIONS");
requireLine(positiveOutput,"scope=limiting_C_settings_only;_not_clearance_collision_or_motion_authorization","FULTON-CNC-SCOPE");
requireDiagnostic(zeroError, "FULTON-CNC-ZERO-MERIDIAN", "FULTON-CNC-ZERO-MERIDIAN");
requireDiagnostic(fullFrameError, "FULTON-CNC-POSE-KIND", "FULTON-CNC-POSE-KIND");
producerExits=lines get(evidenceDirectory | "/producer-exits.tsv");
requireEqual(producerExits,{"case\texit_code","positive\t0","invalid-zero\t1","invalid-full-frame\t1"},"FULTON-CNC-PRODUCER-EXIT");
print "PASS independent pole-continuation acceptance; only limiting C settings are graded";
exit 0;
