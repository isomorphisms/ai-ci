.class public final Lacceptance/CheckedSearchQueryObserver;
.super Ljava/lang/Object;

.method private static expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .registers 5
    invoke-static {p0}, LIdric/Generated;->checked_search_query(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :passed
    sget-object v1, Ljava/lang/System;->err:Ljava/io/PrintStream;
    invoke-virtual {v1, p2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v1, v0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :passed
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 6
    const/4 v0, 0x0
    const-string v1, "Search refused: the query is empty."
    const-string v2, "FAIL checked search null query refusal"
    invoke-static {v0, v1, v2}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, ""
    invoke-static {v0, v1, v2}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "   "
    const-string v1, "Search refused: the query is unsupported or its encoded URL is too long."
    const-string v2, "FAIL checked search whitespace query refusal"
    invoke-static {v0, v1, v2}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "  Björk + %2F & 🌍  "
    const-string v1, "https://google.com/search?q=Bj%C3%B6rk+%2B+%252F+%26+%F0%9F%8C%8D"
    const-string v2, "FAIL checked search exact Unicode once encoding"
    invoke-static {v0, v1, v2}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "AZaz09-._~"
    const-string v1, "https://google.com/search?q=AZaz09-._~"
    const-string v2, "FAIL checked search unreserved bytes"
    invoke-static {v0, v1, v2}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bad\nquery"
    const-string v1, "Search refused: the query is unsupported or its encoded URL is too long."
    const-string v2, "FAIL checked search control refusal"
    invoke-static {v0, v1, v2}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const/4 v0, 0x1
    new-array v0, v0, [C
    const/4 v1, 0x0
    const v2, 0xd800
    aput-char v2, v0, v1
    new-instance v1, Ljava/lang/String;
    invoke-direct {v1, v0}, Ljava/lang/String;-><init>([C)V
    const-string v2, "Search refused: the query contains invalid Unicode."
    const-string v3, "FAIL checked search malformed Unicode refusal"
    invoke-static {v1, v2, v3}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const/16 v0, 0x400
    new-array v0, v0, [C
    const/16 v1, 0x61
    invoke-static {v0, v1}, Ljava/util/Arrays;->fill([CC)V
    new-instance v1, Ljava/lang/String;
    invoke-direct {v1, v0}, Ljava/lang/String;-><init>([C)V
    const-string v2, "https://google.com/search?q="
    invoke-virtual {v2, v1}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    const-string v3, "FAIL checked search exact UTF16 size boundary"
    invoke-static {v1, v2, v3}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v2, "a"
    invoke-virtual {v1, v2}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v2, "Search refused: the query exceeds 1024 UTF-16 units."
    const-string v3, "FAIL checked search oversized query refusal"
    invoke-static {v1, v2, v3}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const/16 v0, 0x100
    new-array v0, v0, [C
    const/16 v1, 0x3bb
    invoke-static {v0, v1}, Ljava/util/Arrays;->fill([CC)V
    new-instance v1, Ljava/lang/String;
    invoke-direct {v1, v0}, Ljava/lang/String;-><init>([C)V
    const-string v2, "Search refused: the query is unsupported or its encoded URL is too long."
    const-string v3, "FAIL checked search encoded URL bound"
    # 256 lambdas encode to 1536 octets, so remain below 2048 URL characters.
    # Duplicate the actual independent input to exceed the complete URL limit.
    invoke-virtual {v1, v1}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-static {v1, v2, v3}, Lacceptance/CheckedSearchQueryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent actual Activity query validation Unicode encoding and limits"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
