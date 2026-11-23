.class public final Lacceptance/reader/PureTextOrderObserver;
.super Ljava/lang/Object;
.method public static main([Ljava/lang/String;)V
    .registers 4
    const-string v0, "𝄞"
    invoke-static {v0}, LIdric/Generated;->text_order_one(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "00011"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :pass
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL pure Text export scalar ordering"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x49
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
  :pass
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent pure Text export scalar ordering"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
