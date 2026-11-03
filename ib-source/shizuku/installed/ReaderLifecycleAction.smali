.class public final Lacceptance/shizuku/ReaderLifecycleAction;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private final activity:Landroid/app/Activity;
.field private final action:I

.method public constructor <init>(Landroid/app/Activity;I)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/ReaderLifecycleAction;->activity:Landroid/app/Activity;
    iput p2, p0, Lacceptance/shizuku/ReaderLifecycleAction;->action:I
    return-void
.end method

.method public run()V
    .locals 3
    iget-object v0, p0, Lacceptance/shizuku/ReaderLifecycleAction;->activity:Landroid/app/Activity;
    iget v1, p0, Lacceptance/shizuku/ReaderLifecycleAction;->action:I
    if-eqz v1, :finish
    const/4 v2, 2
    if-eq v1, v2, :stale_destroy
    new-instance v1, Landroid/content/Intent;
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v2
    invoke-direct {v1, v0, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V
    invoke-virtual {v0, v1}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V
    return-void
  :finish
    invoke-virtual {v0}, Landroid/app/Activity;->finish()V
    return-void
  :stale_destroy
    # Deliberate stale checked callback control after real framework destruction.
    # Do not call Activity.onDestroy twice or mutate candidate fields.
    invoke-static {v0}, LIdric/Generated;->destroy_reader(Landroid/app/Activity;)V
    return-void
.end method
