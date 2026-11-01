.class public final Lacceptance/lifecycle/LifecycleInstrumentation;
.super Landroid/app/Instrumentation;

.field private volatile createdCount:I
.field private volatile createdTitle:Ljava/lang/String;
.field private volatile resumed:Landroid/app/Activity;
.field private volatile destroyed:Landroid/app/Activity;
.field private volatile destroyedTitle:Ljava/lang/String;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .locals 0
    invoke-super {p0, p1}, Landroid/app/Instrumentation;->onCreate(Landroid/os/Bundle;)V
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method

.method public callActivityOnCreate(Landroid/app/Activity;Landroid/os/Bundle;)V
    .locals 1
    invoke-super {p0, p1, p2}, Landroid/app/Instrumentation;->callActivityOnCreate(Landroid/app/Activity;Landroid/os/Bundle;)V
    invoke-virtual {p1}, Landroid/app/Activity;->getTitle()Ljava/lang/CharSequence;
    move-result-object v0
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->createdTitle:Ljava/lang/String;
    iget v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->createdCount:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->createdCount:I
    return-void
.end method

.method public callActivityOnResume(Landroid/app/Activity;)V
    .locals 0
    invoke-super {p0, p1}, Landroid/app/Instrumentation;->callActivityOnResume(Landroid/app/Activity;)V
    iput-object p1, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->resumed:Landroid/app/Activity;
    return-void
.end method

.method public callActivityOnDestroy(Landroid/app/Activity;)V
    .locals 1
    invoke-super {p0, p1}, Landroid/app/Instrumentation;->callActivityOnDestroy(Landroid/app/Activity;)V
    invoke-virtual {p1}, Landroid/app/Activity;->getTitle()Ljava/lang/CharSequence;
    move-result-object v0
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->destroyedTitle:Ljava/lang/String;
    iput-object p1, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->destroyed:Landroid/app/Activity;
    return-void
.end method

.method private static require(ZLjava/lang/String;)V
    .locals 1
    if-nez p0, :done
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :done
    return-void
.end method

.method private static title(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    invoke-virtual {p0}, Landroid/app/Activity;->getTitle()Ljava/lang/CharSequence;
    move-result-object v0
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    invoke-static {v0, p2}, Lacceptance/lifecycle/LifecycleInstrumentation;->require(ZLjava/lang/String;)V
    return-void
.end method

.method public onStart()V
    .locals 11
  :try_start
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.MAIN"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v1
    const-string v2, "Idric.Generated"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Landroid/content/Context;Ljava/lang/String;)Landroid/content/Intent;
    const/high16 v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v3
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    iget-object v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->createdTitle:Ljava/lang/String;
    const-string v1, "Created"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    const-string v1, "FAIL checked onCreate framework title"
    invoke-static {v0, v1}, Lacceptance/lifecycle/LifecycleInstrumentation;->require(ZLjava/lang/String;)V
    const-string v0, "Resumed"
    const-string v1, "FAIL checked onResume framework title"
    invoke-static {v3, v0, v1}, Lacceptance/lifecycle/LifecycleInstrumentation;->title(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V
    new-instance v0, Lacceptance/lifecycle/LifecycleAction;
    const/4 v1, 1
    invoke-direct {v0, v3, v1}, Lacceptance/lifecycle/LifecycleAction;-><init>(Landroid/app/Activity;Z)V
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    const/4 v4, 0
    const/16 v5, 100
  :wait_second
    iget v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->createdCount:I
    const/4 v1, 2
    if-lt v0, v1, :second_retry
    iget-object v4, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->resumed:Landroid/app/Activity;
    if-eqz v4, :second_retry
    if-ne v4, v3, :second_ready
  :second_retry
    const-wide/16 v8, 100
    invoke-static {v8, v9}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v5, v5, -1
    if-gtz v5, :wait_second
    const/4 v0, 0
    const-string v1, "FAIL second framework Activity instance"
    invoke-static {v0, v1}, Lacceptance/lifecycle/LifecycleInstrumentation;->require(ZLjava/lang/String;)V
  :second_ready
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    const-string v0, "Resumed"
    const-string v1, "FAIL second checked onResume framework title"
    invoke-static {v4, v0, v1}, Lacceptance/lifecycle/LifecycleInstrumentation;->title(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V
    new-instance v0, Lacceptance/lifecycle/LifecycleAction;
    const/4 v1, 0
    invoke-direct {v0, v4, v1}, Lacceptance/lifecycle/LifecycleAction;-><init>(Landroid/app/Activity;Z)V
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    const/16 v5, 100
  :wait_return
    iget-object v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->destroyed:Landroid/app/Activity;
    if-ne v0, v4, :return_retry
    iget-object v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->resumed:Landroid/app/Activity;
    if-eq v0, v3, :returned
  :return_retry
    const-wide/16 v8, 100
    invoke-static {v8, v9}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v5, v5, -1
    if-gtz v5, :wait_return
    const/4 v0, 0
    const-string v1, "FAIL framework destroy and original Activity return"
    invoke-static {v0, v1}, Lacceptance/lifecycle/LifecycleInstrumentation;->require(ZLjava/lang/String;)V
  :returned
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    iget-object v0, p0, Lacceptance/lifecycle/LifecycleInstrumentation;->destroyedTitle:Ljava/lang/String;
    const-string v1, "Destroyed"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    const-string v1, "FAIL checked onDestroy framework title"
    invoke-static {v0, v1}, Lacceptance/lifecycle/LifecycleInstrumentation;->require(ZLjava/lang/String;)V
    const-string v0, "Resumed"
    const-string v1, "FAIL original Activity automatic resume"
    invoke-static {v3, v0, v1}, Lacceptance/lifecycle/LifecycleInstrumentation;->title(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V
    const-string v6, "PASS framework create resume destroy and return to the original checked Activity"
    const/4 v7, -1
    goto :result
  :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :failed
  :failed
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v6
    const/4 v7, 0
  :result
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    invoke-virtual {v0, v1, v6}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    invoke-virtual {p0, v7, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method
