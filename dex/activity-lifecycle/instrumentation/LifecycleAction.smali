.class public final Lacceptance/lifecycle/LifecycleAction;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private final activity:Landroid/app/Activity;
.field private final launch:Z

.method public constructor <init>(Landroid/app/Activity;Z)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/lifecycle/LifecycleAction;->activity:Landroid/app/Activity;
    iput-boolean p2, p0, Lacceptance/lifecycle/LifecycleAction;->launch:Z
    return-void
.end method

.method public run()V
    .locals 3
    iget-object v0, p0, Lacceptance/lifecycle/LifecycleAction;->activity:Landroid/app/Activity;
    iget-boolean v1, p0, Lacceptance/lifecycle/LifecycleAction;->launch:Z
    if-eqz v1, :finish
    const-string v1, "Before return"
    invoke-virtual {v0, v1}, Landroid/app/Activity;->setTitle(Ljava/lang/CharSequence;)V
    new-instance v1, Landroid/content/Intent;
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v2
    invoke-direct {v1, v0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {v0, v1}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V
    return-void
  :finish
    invoke-virtual {v0}, Landroid/app/Activity;->finish()V
    return-void
.end method
