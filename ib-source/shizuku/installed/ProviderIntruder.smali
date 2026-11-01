.class public final Lacceptance/shizuku/ProviderIntruder;
.super Landroid/app/Instrumentation;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .registers 2
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method

.method public onStart()V
    .registers 10
  :setup
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v1
    const-string v2, "org.isomorphisms.ib.prepaint.shizuku"
    const/4 v3, 0x0
    invoke-virtual {v1, v2, v3}, Landroid/content/pm/PackageManager;->resolveContentProvider(Ljava/lang/String;I)Landroid/content/pm/ProviderInfo;
    move-result-object v1
    if-eqz v1, :failed
    iget-object v2, v1, Landroid/content/pm/ProviderInfo;->applicationInfo:Landroid/content/pm/ApplicationInfo;
    iget v2, v2, Landroid/content/pm/ApplicationInfo;->uid:I
    invoke-static {}, Landroid/os/Process;->myUid()I
    move-result v3
    if-eq v2, v3, :failed
    const-string v2, "android.permission.INTERACT_ACROSS_USERS_FULL"
    iget-object v3, v1, Landroid/content/pm/ProviderInfo;->readPermission:Ljava/lang/String;
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :failed
    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    const-string v1, "content://org.isomorphisms.ib.prepaint.shizuku"
    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v1
    const-string v2, "sendBinder"
    const/4 v3, 0x0
    new-instance v4, Landroid/os/Bundle;
    invoke-direct {v4}, Landroid/os/Bundle;-><init>()V
  :attack
    invoke-virtual {v0, v1, v2, v3, v4}, Landroid/content/ContentResolver;->call(Landroid/net/Uri;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;
  :attack_end
    goto :failed
  .catch Ljava/lang/SecurityException; {:attack .. :attack_end} :refused
  .catch Ljava/lang/Throwable; {:setup .. :attack} :failed_exception
  :refused
    move-exception v0
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    const-string v2, "PASS independent external provider caller refused by Android"
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, -0x1
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
  :failed_exception
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->printStackTrace()V
  :failed
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    const-string v2, "FAIL external provider caller identity or refusal"
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, 0x0
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method
