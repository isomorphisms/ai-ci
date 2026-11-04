.class public Lacceptance/CheckedCallsRunner;
.super Ljava/lang/Object;

.method private static require_equal(II)V
    .registers 4
    if-eq p0, p1, :okay
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "checked Idric call returned the wrong value"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 73
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
  :okay
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 12
    const/4 v0, 0
    const/16 v1, 13
  :loop
    # Independent arithmetic oracle for every count from zero through twelve.
    invoke-static {v0}, LIdric/Generated;->sum_recursive(I)I
    move-result v2
    add-int/lit8 v3, v0, 1
    mul-int v3, v0, v3
    div-int/lit8 v3, v3, 2
    invoke-static {v2, v3}, Lacceptance/CheckedCallsRunner;->require_equal(II)V
    invoke-static {v0}, LIdric/Generated;->mutual_parity(I)I
    move-result v2
    and-int/lit8 v3, v0, 1
    xor-int/lit8 v3, v3, 1
    invoke-static {v2, v3}, Lacceptance/CheckedCallsRunner;->require_equal(II)V
    invoke-static {v0}, LIdric/Generated;->cross_module(I)I
    move-result v2
    add-int/lit8 v3, v0, 7
    mul-int/lit8 v3, v3, 3
    invoke-static {v2, v3}, Lacceptance/CheckedCallsRunner;->require_equal(II)V
    add-int/lit8 v0, v0, 1
    if-lt v0, v1, :loop

    const/4 v0, -2
    invoke-static {v0}, LIdric/Generated;->sum_recursive(I)I
    move-result v2
    const/4 v3, 0
    invoke-static {v2, v3}, Lacceptance/CheckedCallsRunner;->require_equal(II)V

    const/4 v0, 1
    const/4 v1, 2
    const/4 v2, 3
    const/4 v3, 4
    const/4 v4, 5
    const/4 v5, 6
    invoke-static/range {v0 .. v5}, LIdric/Generated;->reordered_six(IIIIII)I
    move-result v2
    const/16 v3, 56
    invoke-static {v2, v3}, Lacceptance/CheckedCallsRunner;->require_equal(II)V

    const/4 v0, 0
    const-string v1, "runtime λ input"
    invoke-static {v0, v1}, LIdric/Generated;->text_call(ILjava/lang/String;)Ljava/lang/String;
    move-result-object v2
    const-string v3, "♭𝄪"
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    const/4 v3, 1
    invoke-static {v2, v3}, Lacceptance/CheckedCallsRunner;->require_equal(II)V
    const/4 v0, 7
    invoke-static {v0, v1}, LIdric/Generated;->text_call(ILjava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    invoke-static {v2, v3}, Lacceptance/CheckedCallsRunner;->require_equal(II)V

    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS checked calls: 43 assertions"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
