.class public final Lacceptance/presentation/WorkbenchProbe;
.super Ljava/lang/Object;

.method public static main([Ljava/lang/String;)V
    .locals 5
    const-string v0, "IBH1\n2\nalpha\t1\nbeta\t4\nalpha\t2\n"
    const/4 v1, 1
    invoke-static {v0, v0, v1}, LIdric/Generated;->projected_history(Ljava/lang/String;Ljava/lang/String;I)Ljava/lang/String;
    move-result-object v2
    const-string v3, "IBH1\n1\nalpha\t1\nbeta\t4\nalpha\t2\n"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :fail
    const-string v1, "IBH1\n0\nalpha\t3\n"
    const/4 v2, 0
    invoke-static {v0, v1, v2}, LIdric/Generated;->projected_history(Ljava/lang/String;Ljava/lang/String;I)Ljava/lang/String;
    move-result-object v0
    const-string v1, "REFUSED: History changed. Reopen History before selecting a source."
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :stale
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent retained occurrence and stale revision refusal on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
  :stale
    const-string v1, "FAIL stale projection refused"
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x2a
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
  :fail
    const-string v1, "FAIL retained occurrence identity or order"
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method
