.class public final Lacceptance/presentation/ArchiveUi;
.super Landroid/app/Instrumentation;
.field private corrupt:Z
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method
.method public onCreate(Landroid/os/Bundle;)V
    .locals 1
    if-eqz p1, :start
    const-string v0, "corrupt"
    invoke-virtual {p1, v0}, Landroid/os/Bundle;->containsKey(Ljava/lang/String;)Z
    move-result v0
    iput-boolean v0, p0, Lacceptance/presentation/ArchiveUi;->corrupt:Z
  :start
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method
.method public onStart()V
    .locals 8
  :begin
    new-instance v0, Landroid/content/Intent;
    invoke-direct {v0}, Landroid/content/Intent;-><init>()V
    const-string v1, "org.isomorphisms.chatgptexporter.e1fixture"
    const-string v2, "org.isomorphisms.webview.BridgeActivity"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const-string v1, "org.isomorphisms.chatgptexporter.READ_SAVED"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;
    const v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v0
    new-instance v3, Lacceptance/presentation/ArchiveUiTask;
    invoke-direct {v3, v0}, Lacceptance/presentation/ArchiveUiTask;-><init>(Landroid/app/Activity;)V
    const/16 v4, 100
  :await
    invoke-virtual {p0, v3}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-boolean v1, p0, Lacceptance/presentation/ArchiveUi;->corrupt:Z
    if-eqz v1, :good
    iget-boolean v1, v3, Lacceptance/presentation/ArchiveUiTask;->refused:Z
    if-nez v1, :corrupt_pass
    goto :wait
  :good
    iget-boolean v1, v3, Lacceptance/presentation/ArchiveUiTask;->ready:Z
    if-nez v1, :exercise
  :wait
    const-wide/16 v1, 0x64
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v4, v4, -1
    if-gtz v4, :await
    new-instance v1, Ljava/lang/AssertionError;
    const-string v2, "FAIL actual native archive did not reach required verified/refused state"
    invoke-direct {v1, v2}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v1
  :exercise
    invoke-static {p0, v0}, Lacceptance/presentation/ArchiveFrameProbe;->assertVisible(Landroid/app/Instrumentation;Landroid/app/Activity;)V
    const/4 v4, 1
  :phase
    iput v4, v3, Lacceptance/presentation/ArchiveUiTask;->phase:I
    invoke-virtual {p0, v3}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    const-wide/16 v1, 0x1f4
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v4, v4, 1
    const/4 v5, 5
    if-lt v4, v5, :phase
    const-string v2, "PASS actual production native archive view, source roles, branch mode, framework copy and offline entry"
    goto :finish
  :corrupt_pass
    const-string v2, "PASS actual production native archive refused corrupt normalized source"
  :finish
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, -1
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :failed
  :failed
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v2
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, 0
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method
