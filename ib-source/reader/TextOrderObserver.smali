.class public final Lacceptance/reader/TextOrderObserver;
.super Ljava/lang/Object;

.method private static expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .registers 6
    invoke-static {p0, p1}, LIdric/Generated;->text_order(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :pass
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    invoke-virtual {v0, p3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x49
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
  :pass
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 5
    const-string v3, "FAIL ASCII or prefix Text ordering"
    const-string v0, ""
    const-string v1, ""
    const-string v2, "01110"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v1, "a"
    const-string v2, "11000"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "a"
    const-string v1, ""
    const-string v2, "00011"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v1, "aa"
    const-string v2, "11000"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "2147483648"
    const-string v1, "2147483647"
    const-string v2, "00011"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v3, "FAIL Unicode scalar Text ordering"
    const-string v0, "𝄞"
    const-string v1, "\ue000"
    const-string v2, "00011"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "\ue000"
    const-string v1, "𝄞"
    const-string v2, "11000"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "𝄞"
    const-string v1, "𝄞"
    const-string v2, "01110"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v1, "𝄞a"
    const-string v2, "11000"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "𝄞a"
    const-string v1, "𝄞"
    const-string v2, "00011"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "e\u0301"
    const-string v1, "é"
    const-string v2, "11000"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "\u0000"
    const-string v1, "a"
    invoke-static {v0, v1, v2, v3}, Lacceptance/reader/TextOrderObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent ASCII prefix NUL combining and supplementary scalar Text ordering"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
