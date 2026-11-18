.class public final Lacceptance/SelectionObserver;
.super Ljava/lang/Object;

.method private static equal(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .registers 5
    invoke-virtual {p1, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :passed
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    invoke-virtual {v0, p2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :passed
    return-void
.end method

.method private static display(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    .registers 7
    invoke-static {p0, p1, p2}, LIdric/Generated;->selection_display(Ljava/lang/String;II)Ljava/lang/String;
    move-result-object v0
    invoke-static {v0, p3, p4}, Lacceptance/SelectionObserver;->equal(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private static copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    .registers 10
    invoke-static {p0, p1, p2, p3, p4}, LIdric/Generated;->selection_copy(Ljava/lang/String;IIII)Ljava/lang/String;
    move-result-object v0
    invoke-static {v0, p5, p6}, Lacceptance/SelectionObserver;->equal(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private static link(Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    .registers 8
    invoke-static {p0, p1, p2, p3}, LIdric/Generated;->selection_link(Ljava/lang/String;Ljava/lang/String;II)Ljava/lang/String;
    move-result-object v0
    invoke-static {v0, p4, p5}, Lacceptance/SelectionObserver;->equal(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private static all(Ljava/lang/String;IILjava/lang/String;)V
    .registers 10
    move-object v0, p0
    move v1, p1
    move v2, p2
    invoke-static {v0, v1, v2}, LIdric/Generated;->selection_display(Ljava/lang/String;II)Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v4}, Ljava/lang/String;->length()I
    move-result v4
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3, v4}, LIdric/Generated;->selection_copy(Ljava/lang/String;IIII)Ljava/lang/String;
    move-result-object v5
    invoke-static {v5, p0, p3}, Lacceptance/SelectionObserver;->equal(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 14
    const-string v0, "one two three"
    const/4 v1, 7
    const/4 v2, 0
    const-string v3, "one two\nthree\n"
    const-string v4, "FAIL literal greedy display"
    invoke-static/range {v0 .. v4}, Lacceptance/SelectionObserver;->display(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 0
    const/16 v4, 14
    const-string v5, "one two three"
    const-string v6, "FAIL exact decoded copy omits wrapping glyphs"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 4
    const/4 v4, 7
    const-string v5, "two"
    const-string v6, "FAIL selected word excludes suppressed trailing space"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 7
    const/16 v4, 8
    const-string v5, " "
    const-string v6, "FAIL wrapping boundary retains original source space"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const-string v0, "co\u00adoperate"
    const/4 v1, 3
    const-string v3, "co-\noperate\n"
    const-string v4, "FAIL discretionary hyphen literal display"
    invoke-static/range {v0 .. v4}, Lacceptance/SelectionObserver;->display(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 0
    const/16 v4, 12
    const-string v5, "co\u00adoperate"
    const-string v6, "FAIL soft hyphen full source copy"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 2
    const/4 v4, 3
    const-string v5, "\u00ad"
    const-string v6, "FAIL discretionary glyph selects its original soft hyphen"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/16 v1, 20
    const/4 v3, 0
    const/4 v4, 2
    const-string v5, "co"
    const-string v6, "FAIL hidden control end affinity"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 2
    const/16 v4, 9
    const-string v5, "operate"
    const-string v6, "FAIL hidden control start affinity"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const-string v0, "A🧭e\u0301 Z"
    const/4 v3, 1
    const/4 v4, 3
    const-string v5, "🧭"
    const-string v6, "FAIL UTF16 selection maps one supplementary scalar"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 2
    const-string v5, ""
    const-string v6, "FAIL interior UTF16 surrogate start refusal"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 1
    const/4 v4, 2
    const-string v6, "FAIL interior UTF16 surrogate end refusal"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 3
    const/4 v4, 5
    const-string v5, "e\u0301"
    const-string v6, "FAIL combining source substring"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const-string v0, "a\r\nb\u0085c\u2028d\u2029e\rf\n"
    const/4 v3, 0
    const/16 v4, 12
    const-string v5, "a\r\nb\u0085c\u2028d\u2029e\rf\n"
    const-string v6, "FAIL all supported source line endings remain exact"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 1
    const/4 v4, 2
    const-string v5, "\r\n"
    const-string v6, "FAIL displayed hard newline selects original CRLF"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const-string v0, "ab\u200bcd"
    const/4 v1, 2
    const/4 v3, 2
    const/4 v4, 3
    const-string v5, "\u200b"
    const-string v6, "FAIL zero width wrapping boundary retains source control"
    invoke-static/range {v0 .. v6}, Lacceptance/SelectionObserver;->copy(Ljava/lang/String;IIIILjava/lang/String;Ljava/lang/String;)V
    const-string v0, "one two three co\u00adoperate A🧭e\u0301 Z"
    const/4 v1, 7
    const/4 v2, 0
    const-string v3, "FAIL full greedy selection source equality"
    invoke-static {v0, v1, v2, v3}, Lacceptance/SelectionObserver;->all(Ljava/lang/String;IILjava/lang/String;)V
    const/4 v2, 1
    const-string v3, "FAIL full squared selection source equality"
    invoke-static {v0, v1, v2, v3}, Lacceptance/SelectionObserver;->all(Ljava/lang/String;IILjava/lang/String;)V
    const-string v0, "learn more"
    const-string v1, "https://example.org/path?q=1#section"
    const/4 v2, 5
    const/4 v3, 6
    const-string v4, "https://example.org/path?q=1#section"
    const-string v5, "FAIL checked retained projection link target"
    invoke-static/range {v0 .. v5}, Lacceptance/SelectionObserver;->link(Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const/4 v3, 5
    const-string v4, ""
    const-string v5, "FAIL displayed line ending is not a clickable link"
    invoke-static/range {v0 .. v5}, Lacceptance/SelectionObserver;->link(Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const-string v1, "javascript:alert(1)"
    const/4 v3, 0
    const-string v5, "FAIL unsupported link scheme refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/SelectionObserver;->link(Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent exact source selection UTF16 line endings soft hyphens reflow and links"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
