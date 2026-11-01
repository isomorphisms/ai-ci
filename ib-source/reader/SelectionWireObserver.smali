.class public final Lacceptance/SelectionWireObserver;
.super Ljava/lang/Object;

.method private static expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    .registers 10
    invoke-static {p0, p1, p2, p3, p4}, LIdric/Generated;->copy_reader_selection(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p5, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :passed
    sget-object v1, Ljava/lang/System;->err:Ljava/io/PrintStream;
    invoke-virtual {v1, p6}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :passed
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 10
    const-string v0, "co\u00adoperate"
    const-string v1, "co-\noperate\n"
    const-string v2, "IBP1\n0\t4\t0\t3\tH\t\n4\t12\t3\t10\tL\t\n"
    const/4 v3, 0
    const/16 v4, 12
    const-string v5, "co\u00adoperate"
    const-string v6, "FAIL actual source copy retains soft hyphen and omits wrapping glyphs"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionWireObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const-string v0, "co\u00adoperatX"
    const-string v5, ""
    const-string v6, "FAIL source/display coordinate mismatch refusal"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionWireObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const-string v0, "co\u00adoperate"
    const-string v2, "IBP1\n0\t4\t0\t3\tH\t\n4\t12\t3\t11\tL\t\n"
    const-string v6, "FAIL source coordinate overrun refusal"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionWireObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const-string v2, "IBP1\n1\t4\t0\t3\tH\t\n4\t12\t3\t10\tL\t\n"
    const-string v6, "FAIL source projection initial gap refusal"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionWireObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const-string v2, "IBP1\n00\t4\t0\t3\tH\t\n4\t12\t3\t10\tL\t\n"
    const-string v6, "FAIL noncanonical source coordinate refusal"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionWireObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent source projection bytes metadata and actual export copy boundary"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
