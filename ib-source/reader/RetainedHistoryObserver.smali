.class public final Lacceptance/RetainedHistoryObserver;
.super Ljava/lang/Object;

.method private static expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    .registers 6
    invoke-static {p0, p1, p2}, LIdric/Generated;->reader_retained_history_valid(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
    move-result v0
    if-eq v0, p3, :passed
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL checked retained journal identity"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :passed
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 5
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "IBH1\n0\nfixture-alpha\t7\n"
    const/4 v3, 1
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, ""
    const/4 v3, 1
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "IBH1\n0\nfixture-alpha\t7\nfixture-beta\t8\n"
    const/4 v3, 1
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "IBH1\n1\nfixture-alpha\t7\n"
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "IBH1\n0\nfixture-beta\t7\n"
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "IBH1\n0\nfixture-alpha\t8\n"
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "IBH1\n0\nfixture-alpha\t7"
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "IBH1\n0\n"
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "7"
    const-string v2, "OTHER\n0\nfixture-alpha\t7\n"
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    const-string v0, "fixture-alpha"
    const-string v1, "2147483648"
    const-string v2, ""
    const/4 v3, 0
    invoke-static {v0, v1, v2, v3}, Lacceptance/RetainedHistoryObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS checked retained journal selected source generation framing and legacy recovery"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
