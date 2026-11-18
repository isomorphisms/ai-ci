.class public final Lacceptance/AssertionFailure;
.super Ljava/lang/Object;

# Independent observer only. An assertion first prints its exact diagnostic.
# Stop only this observer, after flushing, without racing app_process's ART
# teardown against its JIT thread. The controller requires exit 137 AND the
# intended assertion text. A candidate crash or timeout is still a failure.
.method public static terminate()V
    .registers 2
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    invoke-virtual {v0}, Ljava/io/PrintStream;->flush()V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    invoke-virtual {v0}, Ljava/io/PrintStream;->flush()V
    invoke-static {}, Landroid/os/Process;->myPid()I
    move-result v0
    invoke-static {v0}, Landroid/os/Process;->killProcess(I)V
    new-instance v0, Ljava/lang/AssertionError;
    const-string v1, "Independent assertion process termination failed"
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method
