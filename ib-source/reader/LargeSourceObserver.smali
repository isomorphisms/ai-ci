.class public final Lacceptance/LargeSourceObserver;
.super Ljava/lang/Object;

# SDK/ART observer only. The candidate is unchanged compiled ReaderProjection.
.method private static digest([B)Ljava/lang/String;
    .registers 9
    const-string v0, "SHA-256"
    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;
    move-result-object v0
    invoke-virtual {v0, p0}, Ljava/security/MessageDigest;->digest([B)[B
    move-result-object v0
    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "0123456789abcdef"
    const/4 v3, 0
    array-length v4, v0
  :again
    if-ge v3, v4, :done
    aget-byte v5, v0, v3
    ushr-int/lit8 v6, v5, 0x4
    and-int/lit8 v6, v6, 0xf
    invoke-virtual {v2, v6}, Ljava/lang/String;->charAt(I)C
    move-result v6
    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    and-int/lit8 v5, v5, 0xf
    invoke-virtual {v2, v5}, Ljava/lang/String;->charAt(I)C
    move-result v5
    invoke-virtual {v1, v5}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;
    add-int/lit8 v3, v3, 0x1
    goto :again
  :done
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method private static observe(I)V
    .registers 16
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const/4 v1, 0
    const-string v2, "source "
  :words
    if-ge v1, p0, :words_done
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    add-int/lit8 v1, v1, 0x1
    goto :words
  :words_done
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v1
    new-instance v2, Ljava/lang/StringBuilder;
    const-string v3, "<p>"
    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v3, "</p>"
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "ISO-8859-1"
    invoke-virtual {v2, v3}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v3
    invoke-static {v3}, Lacceptance/LargeSourceObserver;->digest([B)Ljava/lang/String;
    move-result-object v4
    array-length v3, v3
    new-instance v5, Ljava/lang/StringBuilder;
    const-string v6, "arena:scale\t1\t"
    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v6, "\t"
    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v6, "\thttps://example.com/\thttps://example.com/\ttext/html\tiso-8859-1\t200\tverified-utf8\tcomplete"
    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v5
    new-instance v6, Ljava/lang/StringBuilder;
    const-string v7, "arena:scale\n1\n"
    invoke-direct {v6, v7}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v7, "\niso-8859-1\noriginal-valid-utf8\nwhatwg-windows-1252-e56d49d9176e9a4-v1:windows-1252\narena:scale;generation=1;sha256="
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v7, ";decoder=whatwg-windows-1252-e56d49d9176e9a4-v1;encoding=windows-1252\n"
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v6
    sget-object v8, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v9, "BEGIN original byte count for checked projection"
    invoke-virtual {v8, v9}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v8, v3}, Ljava/io/PrintStream;->println(I)V
    invoke-static {}, Ljava/lang/System;->nanoTime()J
    move-result-wide v10
    invoke-static {v5, v2}, LIdric/Generated;->project_committed_representation(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v7
    invoke-static {}, Ljava/lang/System;->nanoTime()J
    move-result-wide v12
    sub-long v10, v12, v10
    sget-object v8, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v9, "checked projection elapsed nanoseconds"
    invoke-virtual {v8, v9}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v8, v10, v11}, Ljava/io/PrintStream;->println(J)V
    invoke-virtual {v6, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v8
    if-nez v8, :passed
    sget-object v8, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v9, "FAIL exact checked large source representation"
    invoke-virtual {v8, v9}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :passed
    const/16 v8, 32
    if-ne p0, v8, :record
    const-string v8, "complete"
    const-string v9, "incomplete"
    invoke-virtual {v5, v8, v9}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v5
    invoke-static {v5, v2}, LIdric/Generated;->project_committed_representation(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v7
    const-string v8, "refused:incomplete-or-stale-source"
    invoke-virtual {v8, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v8
    if-nez v8, :record
    sget-object v8, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v9, "FAIL checked scale incomplete-source refusal"
    invoke-virtual {v8, v9}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :record
    sget-object v8, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v9, "verified_original_byte_count"
    invoke-virtual {v8, v9}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v8, v3}, Ljava/io/PrintStream;->println(I)V
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 7
  :start
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;
    move-result-object v0
    new-instance v1, Lacceptance/SourceStackSampler;
    invoke-direct {v1, v0}, Lacceptance/SourceStackSampler;-><init>(Ljava/lang/Thread;)V
    invoke-virtual {v1}, Ljava/lang/Thread;->start()V
    const/16 v0, 32
    invoke-static {v0}, Lacceptance/LargeSourceObserver;->observe(I)V
    const/16 v0, 1200
    invoke-static {v0}, Lacceptance/LargeSourceObserver;->observe(I)V
    const/16 v0, 4500
    invoke-static {v0}, Lacceptance/LargeSourceObserver;->observe(I)V
    const/16 v0, 12000
    invoke-static {v0}, Lacceptance/LargeSourceObserver;->observe(I)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent exact 231 and 84007 byte legacy source projections"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
  :finish
    .catch Ljava/lang/Throwable; {:start .. :finish} :failed
  :failed
    move-exception v0
    sget-object v1, Ljava/lang/System;->err:Ljava/io/PrintStream;
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v2
    const-string v3, "FAIL actual checked source exception type:"
    invoke-virtual {v1, v3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v1, v2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v0}, Ljava/lang/Throwable;->getStackTrace()[Ljava/lang/StackTraceElement;
    move-result-object v0
    array-length v2, v0
    const/16 v3, 12
    if-le v2, v3, :bounded
    move v2, v3
  :bounded
    const/4 v3, 0
  :frame
    if-ge v3, v2, :exit
    aget-object v4, v0, v3
    invoke-virtual {v4}, Ljava/lang/StackTraceElement;->getClassName()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v1, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v4}, Ljava/lang/StackTraceElement;->getMethodName()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v1, v5}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    add-int/lit8 v3, v3, 0x1
    goto :frame
  :exit
    const/4 v0, 1
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
.end method
