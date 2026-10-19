-- Bounded independent geometry + producer-transcript oracle.
-- User explicitly assigns exact algebra to Macaulay2. No compiled helper.
if #scriptCommandLine < 2 or #scriptCommandLine > 3 then error "usage: M2 --script accept.m2 EVIDENCE_DIRECTORY [fp]";
evidenceDirectory = scriptCommandLine#1;
fpCapture = (#scriptCommandLine == 3 and scriptCommandLine#2 == "fp");
if #scriptCommandLine == 3 and not fpCapture then error "unsupported evidence format";
armOutput = lines get(evidenceDirectory | if fpCapture then "/01-arm/stdout.bin" else "/case-a-arm.stdout.txt");
headOutput = lines get(evidenceDirectory | if fpCapture then "/02-head/stdout.bin" else "/case-b-ac-head.stdout.txt");
offsetOutput = lines get(evidenceDirectory | if fpCapture then "/03-linkage-offset/stdout.bin" else "/linkage-and-offset.stdout.txt");
requireLine = (output,expected,diagnostic) ->
    if not member(expected,output) then error diagnostic;
-- Independent analytic identities; not the producer's Groebner procedure.
K = QQ[rootHeight]/(rootHeight^2-15);
elbowHorizontal = 7/4_K;
elbowVertical = rootHeight/4;
assert(elbowHorizontal^2+elbowVertical^2 == 4_K);
assert((elbowHorizontal-2)^2+elbowVertical^2 == 1_K);
-- At target 3 the quadratic constraint rows annihilate every second-order
-- correction only when firstVertical^2=0. Det=6 is nonzero.
assert(det matrix(QQ,{{4,1},{-2,1}}) == 6);
if #select(armOutput,line -> line == "length_over_QQ=2") != 4 then
    error "FULTON-ARM-MULTIPLICITY";
requireLine(armOutput,"outer_tangent_dimension=1","FULTON-ARM-TANGENT");
requireLine(armOutput,"reduced_tangent_dimension=0","FULTON-ARM-REDUCTION");
requireLine(armOutput,"PASS case-a: full ideal, support, tangent, length, family identity, obstruction","FULTON-ARM-EXECUTION");
-- A non-meridian C setting really remains on the original pole fiber.
sinA = 0_QQ; cosA = 1_QQ; sinC = 3/5_QQ; cosC = 4/5_QQ;
assert(sinC^2+cosC^2 == 1);
assert(-sinA*sinC == 0 and sinA*cosC == 0 and -cosA == -1);
assert(sinC*(sinA*sinC)+cosC*(sinA*cosC) == sinA);
requireLine(headOutput,"pole_dimension=1","FULTON-POLE-DIMENSION");
requireLine(headOutput,"pole_radical_equals_original=true","FULTON-POLE-REDUCED");
requireLine(headOutput,"near_dimension=0","FULTON-NEAR-DIMENSION");
requireLine(headOutput,"near_length_over_QQ=2","FULTON-NEAR-MULTIPLICITY");
-- For a nonzero Y meridian: sinA != 0, nx=0 implies sinC=0;
-- two unit-circle settings are the only limits. X meridian requires cosC=0.
assert(not(sinC == 0)); -- this pole setting is not a Y-meridian limit
requireLine(headOutput,"whole_special_dimension=1","FULTON-SPECIAL-FIBER");
requireLine(headOutput,"punctured_limit_dimension=0","FULTON-LIMIT-DIMENSION");
requireLine(headOutput,"punctured_limit_length=2","FULTON-LIMIT-MULTIPLICITY");
requireLine(headOutput,"PASS case-b: reduced pole, two-point nearby fiber, minors, limiting settings","FULTON-HEAD-EXECUTION");
-- Different offset parameters, same point, independent nonzero differential.
radius = 5/4_QQ; speed = 5/4_QQ;
assert((3/4_QQ)*(1-radius/speed) == (-3/4_QQ)*(1-radius/speed));
assert((3/4_QQ)^2/2+radius/speed == 41/32_QQ);
assert(1-radius/speed^3 == 9/25_QQ);
requireLine(offsetOutput,"offset_regular_factor_at_crossing=9/25","FULTON-OFFSET-LOCAL-GLOBAL");
requireLine(offsetOutput,"quadratic_cone_reduced=true","FULTON-CHAIN-CONE");
requireLine(offsetOutput,"offset_residual_off_diagonal=true","FULTON-OFFSET-RESIDUAL");
requireLine(offsetOutput,"offset_residual_diagonal_at_crossing=false","FULTON-OFFSET-DIAGONAL");
requireLine(offsetOutput,"PASS linkage-offset: tangent obstruction, reduced cone, regular double point","FULTON-OFFSET-EXECUTION");
print "PASS bounded independent geometric oracle; prose, hardware and platform delivery not graded";
exit 0;
