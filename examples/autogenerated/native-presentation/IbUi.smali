.class public final Lacceptance/presentation/IbUi;
.super Landroid/app/Instrumentation;
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method
.method public onCreate(Landroid/os/Bundle;)V
    .locals 0
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method
.method public onStart()V
    .locals 7
  :begin
    new-instance v0, Landroid/content/Intent;
    invoke-direct {v0}, Landroid/content/Intent;-><init>()V
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "Idric.Generated"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const-string v1, "android.intent.action.MAIN"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;
    const v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v0
    const-wide/16 v1, 0x7d0
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    new-instance v3, Lacceptance/presentation/IbUiTask;
    invoke-direct {v3, v0}, Lacceptance/presentation/IbUiTask;-><init>(Landroid/app/Activity;)V
    const/4 v4, 0
  :phase
    iput v4, v3, Lacceptance/presentation/IbUiTask;->phase:I
    invoke-virtual {p0, v3}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    const-wide/16 v1, 0x3e8
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v4, v4, 1
    const/4 v5, 5
    if-lt v4, v5, :phase
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    const-string v2, "PASS actual IB History Reader preserves View text selection scroll and selects retained source"
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
