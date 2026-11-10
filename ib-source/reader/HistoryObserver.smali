.class public final Lacceptance/HistoryObserver;
.super Ljava/lang/Object;

.method private static expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .registers 10
    invoke-static {p0, p1, p2, p3}, LIdric/Generated;->history_step(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p4, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :passed
    sget-object v1, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v2, "FAIL "
    invoke-virtual {v2, p5}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v1, v0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :passed
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 12
    const-string v0, "IBH1\n0\n"
    const/4 v1, 0
    const-string v2, ""
    const-string v3, ""
    const-string v4, "IBH1\n0\n"
    const-string v5, "empty history"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, 2
    const-string v4, "unavailable"
    const-string v5, "empty Back refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, 1
    const-string v2, "first"
    const-string v3, "1"
    const-string v4, "IBH1\n0\nfirst\t1\n"
    const-string v5, "first retained occurrence"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "IBH1\n0\nfirst\t1\n"
    const-string v2, "second"
    const-string v3, "2"
    const-string v4, "IBH1\n1\nfirst\t1\nsecond\t2\n"
    const-string v5, "second retained occurrence"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "IBH1\n1\nfirst\t1\nsecond\t2\n"
    const/4 v1, 2
    const-string v4, "IBH1\n0\nfirst\t1\nsecond\t2\n"
    const-string v5, "Back preserves immutable source generations"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "IBH1\n0\nfirst\t1\nsecond\t2\n"
    const/4 v1, 3
    const-string v4, "IBH1\n1\nfirst\t1\nsecond\t2\n"
    const-string v5, "Forward retained occurrence"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, 1
    const-string v2, "third"
    const-string v3, "9"
    const-string v4, "IBH1\n1\nfirst\t1\nthird\t9\n"
    const-string v5, "arrival after Back drops only forward references"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "IBH1\n1\nfirst\t1\n"
    const/4 v1, 0
    const-string v4, "refused:Retained history cursor has no source"
    const-string v5, "out of range cursor refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "IBH1\n00\nfirst\t1\n"
    const-string v4, "refused:Invalid retained history cursor"
    const-string v5, "noncanonical cursor refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "IBH1\n0\nfirst\t1"
    const-string v4, "refused:Incomplete retained history"
    const-string v5, "incomplete history refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "IBH1\n0\n"
    const/4 v1, 1
    const-string v2, "valid"
    const-string v3, "2147483647"
    const-string v4, "IBH1\n0\nvalid\t2147483647\n"
    const-string v5, "largest supported source generation"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v3, "2147483648"
    const-string v4, "refused:Invalid retained source generation"
    const-string v5, "source generation overflow refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v3, "01"
    const-string v5, "noncanonical source generation refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v3, "1"
    const-string v2, "../escape"
    const-string v4, "refused:Invalid retained source identity"
    const-string v5, "unsafe identity refusal"
    invoke-static/range {v0 .. v5}, Lacceptance/HistoryObserver;->expect(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent retained history Back Forward branching canonical identity and generation bounds"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
