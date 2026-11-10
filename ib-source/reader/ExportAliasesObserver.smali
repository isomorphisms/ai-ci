.class public final Lacceptance/ExportAliasesObserver;
.super Ljava/lang/Object;

.method private static fail(Ljava/lang/String;)V
    .registers 2
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    invoke-virtual {v0, p0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 8
    const-string v0, "π🧭"
    const/16 v1, 42
    invoke-static {v0, v1}, LIdric/Generated;->aliased_pure(Ljava/lang/String;I)Ljava/lang/String;
    move-result-object v2
    const-string v3, "π🧭:42"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :partial
    const-string v5, "FAIL checked pure export alias Unicode and arguments"
    invoke-static {v5}, Lacceptance/ExportAliasesObserver;->fail(Ljava/lang/String;)V
  :partial
    invoke-static {v1}, LIdric/Generated;->partially_applied_pure(I)Ljava/lang/String;
    move-result-object v2
    const-string v3, "fixed:42"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :io
    const-string v5, "FAIL checked partial export saturation"
    invoke-static {v5}, Lacceptance/ExportAliasesObserver;->fail(Ljava/lang/String;)V
  :io
    new-instance v0, Ljava/util/concurrent/atomic/AtomicInteger;
    const/4 v1, 7
    invoke-direct {v0, v1}, Ljava/util/concurrent/atomic/AtomicInteger;-><init>(I)V
    const/16 v1, 35
    invoke-static {v0, v1}, LIdric/Generated;->aliased_io(Ljava/util/concurrent/atomic/AtomicInteger;I)V
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicInteger;->get()I
    move-result v2
    const/16 v3, 42
    if-eq v2, v3, :second
    const-string v5, "FAIL checked IO alias applies supplied effect exactly once"
    invoke-static {v5}, Lacceptance/ExportAliasesObserver;->fail(Ljava/lang/String;)V
  :second
    const/4 v1, -7
    invoke-static {v0, v1}, LIdric/Generated;->aliased_io(Ljava/util/concurrent/atomic/AtomicInteger;I)V
    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicInteger;->get()I
    move-result v2
    const/16 v3, 35
    if-eq v2, v3, :passed
    const-string v5, "FAIL checked IO alias preserves live SDK state and World invocation"
    invoke-static {v5}, Lacceptance/ExportAliasesObserver;->fail(Ljava/lang/String;)V
  :passed
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent pure partial and IO export alias saturation on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
