.class public final Lacceptance/pasteboard/TransitionObserver;
.super Ljava/lang/Object;

# Independent caller only. Candidate DEX comes from the checked canonical writer.
.method private static path(Ljava/lang/String;ILjava/lang/String;)Ljava/lang/String;
    .registers 5
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "/"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method private static read(Ljava/lang/String;)Ljava/lang/String;
    .registers 5
    const/4 v0, 0x0
    new-array v0, v0, [Ljava/lang/String;
    invoke-static {p0, v0}, Ljava/nio/file/Paths;->get(Ljava/lang/String;[Ljava/lang/String;)Ljava/nio/file/Path;
    move-result-object v0
    invoke-static {v0}, Ljava/nio/file/Files;->readAllBytes(Ljava/nio/file/Path;)[B
    move-result-object v1
    new-instance v2, Ljava/lang/String;
    const-string v3, "UTF-8"
    invoke-direct {v2, v1, v3}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    return-object v2
.end method

.method public static main([Ljava/lang/String;)V
    .registers 12
    const/4 v0, 0x0
    aget-object v1, p0, v0
    const/4 v2, 0x1
    aget-object v2, p0, v2
    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v2
    :start
    if-ge v0, v2, :success
    :try_start
    const-string v3, ".request"
    invoke-static {v1, v0, v3}, Lacceptance/pasteboard/TransitionObserver;->path(Ljava/lang/String;ILjava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-static {v3}, Lacceptance/pasteboard/TransitionObserver;->read(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    const-string v3, ".expected"
    invoke-static {v1, v0, v3}, Lacceptance/pasteboard/TransitionObserver;->path(Ljava/lang/String;ILjava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-static {v3}, Lacceptance/pasteboard/TransitionObserver;->read(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v5
    invoke-static {v4}, LIdric/Generated;->pasteboard_transition(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v5, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v7
    if-eqz v7, :failure
    :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :exception
    add-int/lit8 v0, v0, 0x1
    goto :start
    :failure
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "FAIL independent Pasteboard transition response case "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    sget-object v4, Ljava/lang/System;->out:Ljava/io/PrintStream;
    invoke-virtual {v4, v3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x49
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
    :exception
    move-exception v0
    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v2, "FAIL ART transition execution"
    invoke-virtual {v1, v2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v0}, Ljava/lang/Throwable;->printStackTrace()V
    const/16 v0, 0x4a
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
    :success
    sget-object v1, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v2, "PASS independent exact Pasteboard transitions including Unicode long text mode and protected deletion"
    invoke-virtual {v1, v2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
