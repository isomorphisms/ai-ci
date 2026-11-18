# Independent GAP oracle. Run from the exact Mathieu source checkout.
# The oracle reads the original ATLAS expressions, not the native image lists.
SizeScreen([4096,4096]);;
Require := function(condition, message)
    if not condition then PrintTo("*errout*", "FAIL Mathieu oracle: ", message, "\n"); QUIT_GAP(1); fi;
end;;
AsMask := points -> Sum(points, point -> 2^(point-1));;
EvaluateWord := function(generators, word)
    local result, symbol;
    result := ();
    for symbol in word do
        if symbol = 'a' then result := result * generators[1];
        elif symbol = 'b' then result := result * generators[2];
        elif symbol = 'A' then result := result / generators[1];
        elif symbol = 'B' then result := result / generators[2];
        else Error("bad oracle word"); fi;
    od;
    return result;
end;;
for degree in [12,24] do
    if degree = 12 then
        Read("data/atlas/M12G1-p12aB0.g1"); Read("data/atlas/M12G1-p12aB0.g2");
        expected_order := 95040; seed := [1,2,3,4,5,9]; block_size := 6; expected_blocks := 132;
    else
        Read("data/atlas/M24G1-p24B0.g1"); Read("data/atlas/M24G1-p24B0.g2");
        expected_order := 244823040; seed := [1,2,3,4,5,11,17,24]; block_size := 8; expected_blocks := 759;
    fi;
    generators := [b11,b21]; group := Group(generators);
    Require(Size(group) = expected_order, "group order");
    stabilizer := group;
    for fixed in [1..5] do
        Require(Length(Orbit(stabilizer, fixed)) = degree-fixed+1, "five-transitivity orbit");
        stabilizer := Stabilizer(stabilizer, fixed);
    od;
    if degree = 12 then
        Require(Size(Stabilizer(group, 1)) = 7920, "M11 point stabilizer");
    else
        Require(Size(Stabilizer(group, 1)) = 10200960, "M23 point stabilizer");
        Require(Size(Stabilizer(Stabilizer(group, 1), 2)) = 443520, "M22 two-point stabilizer");
    fi;
    Print("group ", degree, " order ", Size(group), "\n");
    for word in ["", "a", "b", "ab", "ba", "abababB", "aBAbbaB", "abAB", "aabbABBA", "bbbbbbb"] do
        value := EvaluateWord(generators, word);
        if word = "" then Print("word identity"); else Print("word ", word); fi;
        for point in [1..degree] do Print(" ", point^value); od;
        Print("\n");
    od;
    blocks := Set(Orbit(group, seed, OnSets));
    Require(Length(blocks) = expected_blocks, "design block count");
    covered := Concatenation(List(blocks, block -> Combinations(block,5)));
    Require(Length(covered) = Binomial(degree,5) and Length(Set(covered)) = Binomial(degree,5), "unique five-subset completion");
    for generator in generators do Require(Set(List(blocks, block -> OnSets(block,generator))) = blocks, "design preservation"); od;
    for mask in SortedList(List(blocks, AsMask)) do Print("block ", mask, "\n"); od;
    if degree = 24 then
        rows := [];
        for block in blocks do
            row := List([1..24], point -> Zero(GF(2)));
            for point in block do row[point] := One(GF(2)); od;
            Add(rows,row);
        od;
        code_space := VectorSpace(GF(2), rows);
        Require(Dimension(code_space) = 12, "Golay dimension");
        code := Set(Elements(code_space));
        Require(Length(code) = 4096, "Golay cardinality");
        for weight in [0..24] do
            if weight = 0 or weight = 24 then expected := 1;
            elif weight = 8 or weight = 16 then expected := 759;
            elif weight = 12 then expected := 2576; else expected := 0; fi;
            Require(Number(code, vector -> Number(vector, value -> value <> Zero(GF(2))) = weight) = expected, "Golay weight distribution");
        od;
        for generator in generators do
            Require(Set(List(code, vector -> Permuted(vector,generator))) = code, "Golay preservation");
        od;
        masks := SortedList(List(code, vector -> AsMask(Filtered([1..24], point -> vector[point] <> Zero(GF(2))))));
        for mask in masks do Print("code ", mask, "\n"); od;
    fi;
od;
QUIT_GAP(0);
