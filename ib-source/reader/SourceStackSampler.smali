.class public final Lacceptance/SourceStackSampler;
.super Ljava/lang/Thread;
.field private observed:Ljava/lang/Thread;

.method public constructor <init>(Ljava/lang/Thread;)V
    .registers 3
    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V
    iput-object p1, p0, Lacceptance/SourceStackSampler;->observed:Ljava/lang/Thread;
    const/4 v0, 0x1
    invoke-virtual {p0, v0}, Ljava/lang/Thread;->setDaemon(Z)V
    return-void
.end method

.method public run()V
    .registers 10
  :start
    const/4 v0, 0x0
  :sample
    const/16 v1, 16
    if-ge v0, v1, :done
    const-wide/16 v1, 10000
    invoke-static {v1, v2}, Ljava/lang/Thread;->sleep(J)V
    iget-object v1, p0, Lacceptance/SourceStackSampler;->observed:Ljava/lang/Thread;
    invoke-virtual {v1}, Ljava/lang/Thread;->isAlive()Z
    move-result v2
    if-eqz v2, :done
    invoke-virtual {v1}, Ljava/lang/Thread;->getStackTrace()[Ljava/lang/StackTraceElement;
    move-result-object v1
    sget-object v2, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v3, "SAMPLE actual checked-source execution stack"
    invoke-virtual {v2, v3}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    array-length v3, v1
    const/16 v4, 12
    if-le v3, v4, :bounded
    move v3, v4
  :bounded
    const/4 v4, 0
  :frame
    if-ge v4, v3, :next
    aget-object v5, v1, v4
    invoke-virtual {v5}, Ljava/lang/StackTraceElement;->getClassName()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v2, v6}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v5}, Ljava/lang/StackTraceElement;->getMethodName()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v2, v6}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    add-int/lit8 v4, v4, 0x1
    goto :frame
  :next
    add-int/lit8 v0, v0, 0x1
    goto :sample
  :done
    return-void
  :finish
    .catch Ljava/lang/Throwable; {:start .. :finish} :quiet
  :quiet
    move-exception v0
    return-void
.end method
