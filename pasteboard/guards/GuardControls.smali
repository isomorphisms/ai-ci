.class public Lacceptance/pasteboard/GuardControls;
.super Landroid/app/Instrumentation;
.field private phase:Ljava/lang/String;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .registers 4
    const-string v0, "phase"
    const-string v1, "external"
    invoke-virtual {p1, v0, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/pasteboard/GuardControls;->phase:Ljava/lang/String;
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method

.method private static failure(Ljava/lang/String;)V
    .registers 2
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method

.method private heartbeat(Ljava/lang/String;)Landroid/os/Bundle;
    .registers 8
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    const-string v1, "content://com.isomorphisms.pasteboard.shizuku"
    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v1
    const-string v2, "observer_heartbeat"
    new-instance v3, Landroid/os/Bundle;
    invoke-direct {v3}, Landroid/os/Bundle;-><init>()V
    invoke-virtual {v0, v1, v2, p1, v3}, Landroid/content/ContentResolver;->call(Landroid/net/Uri;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;
    move-result-object v0
    return-object v0
.end method

.method private external()V
    .registers 2
    :begin
    const-string v0, "0000000000000000000000000000000000000000000000000000000000000000"
    invoke-direct {p0, v0}, Lacceptance/pasteboard/GuardControls;->heartbeat(Ljava/lang/String;)Landroid/os/Bundle;
    :end
    .catch Ljava/lang/SecurityException; {:begin .. :end} :denied
    const-string v0, "FAIL external observer call not rejected by Android permission"
    invoke-static {v0}, Lacceptance/pasteboard/GuardControls;->failure(Ljava/lang/String;)V
    return-void
    :denied
    move-exception v0
    return-void
.end method

# Only the independently verified emulator procedure invokes this phase. The
# private capability remains inside this controlled Android process: no log,
# shell argument, result Bundle or artifact contains it. No event is injected.
.method private capability()Ljava/lang/String;
    .registers 11
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    const-string v1, "run-as com.isomorphisms.pasteboard cat files/observer.key"
    invoke-virtual {v0, v1}, Landroid/app/UiAutomation;->executeShellCommand(Ljava/lang/String;)Landroid/os/ParcelFileDescriptor;
    move-result-object v0
    new-instance v1, Landroid/os/ParcelFileDescriptor$AutoCloseInputStream;
    invoke-direct {v1, v0}, Landroid/os/ParcelFileDescriptor$AutoCloseInputStream;-><init>(Landroid/os/ParcelFileDescriptor;)V
    const/16 v7, 0x41
    new-array v3, v7, [B
    const/4 v4, 0x0
    :read
    sub-int v5, v7, v4
    if-lez v5, :done
    invoke-virtual {v1, v3, v4, v5}, Ljava/io/InputStream;->read([BII)I
    move-result v6
    if-lez v6, :done
    add-int/2addr v4, v6
    goto :read
    :done
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    const/16 v0, 0x40
    if-eq v4, v0, :valid
    const-string v0, "FAIL controlled observer capability unavailable"
    invoke-static {v0}, Lacceptance/pasteboard/GuardControls;->failure(Ljava/lang/String;)V
    :valid
    new-instance v9, Ljava/lang/String;
    const/4 v0, 0x0
    const-string v8, "UTF-8"
    invoke-direct {v9, v3, v0, v4, v8}, Ljava/lang/String;-><init>([BIILjava/lang/String;)V
    return-object v9
.end method

.method private wrongUid()V
    .registers 8
    invoke-static {}, Landroid/os/Process;->myUid()I
    move-result v0
    const/16 v1, 0x2710
    if-ge v0, v1, :application_uid
    const-string v0, "FAIL UID control requires actual unprivileged application identity"
    invoke-static {v0}, Lacceptance/pasteboard/GuardControls;->failure(Ljava/lang/String;)V
    :application_uid
    invoke-direct {p0}, Lacceptance/pasteboard/GuardControls;->capability()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    const/4 v2, 0x1
    new-array v2, v2, [Ljava/lang/String;
    const/4 v3, 0x0
    const-string v4, "android.permission.INTERACT_ACROSS_USERS_FULL"
    aput-object v4, v2, v3
    invoke-virtual {v0, v2}, Landroid/app/UiAutomation;->adoptShellPermissionIdentity([Ljava/lang/String;)V
    :begin
    invoke-direct {p0, v1}, Lacceptance/pasteboard/GuardControls;->heartbeat(Ljava/lang/String;)Landroid/os/Bundle;
    move-result-object v2
    if-eqz v2, :bad
    const-string v3, "accepted"
    const/16 v4, -0x3e7
    invoke-virtual {v2, v3, v4}, Landroid/os/Bundle;->getInt(Ljava/lang/String;I)I
    move-result v2
    const/4 v3, -0x1
    if-eq v2, v3, :refused
    :bad
    const-string v2, "FAIL unprivileged observer heartbeat accepted"
    invoke-static {v2}, Lacceptance/pasteboard/GuardControls;->failure(Ljava/lang/String;)V
    :refused
    :end
    .catchall {:begin .. :end} :cleanup
    invoke-virtual {v0}, Landroid/app/UiAutomation;->dropShellPermissionIdentity()V
    return-void
    :cleanup
    move-exception v1
    invoke-virtual {v0}, Landroid/app/UiAutomation;->dropShellPermissionIdentity()V
    throw v1
.end method

.method public onStart()V
    .registers 8
    :begin
    iget-object v0, p0, Lacceptance/pasteboard/GuardControls;->phase:Ljava/lang/String;
    const-string v1, "external"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :uid_phase
    invoke-direct {p0}, Lacceptance/pasteboard/GuardControls;->external()V
    const-string v5, "PASS independent external provider caller refused by Android"
    goto :success
    :uid_phase
    const-string v1, "uid"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :unknown
    invoke-direct {p0}, Lacceptance/pasteboard/GuardControls;->wrongUid()V
    const-string v5, "PASS independent real application UID refused with a valid controlled capability"
    goto :success
    :unknown
    const-string v0, "FAIL unknown guard phase"
    invoke-static {v0}, Lacceptance/pasteboard/GuardControls;->failure(Ljava/lang/String;)V
    :success
    const/4 v6, -0x1
    :end
    .catch Ljava/lang/AssertionError; {:begin .. :end} :assertion
    .catch Ljava/lang/Throwable; {:begin .. :end} :exception
    goto :finish
    :assertion
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v5
    const/4 v6, 0x0
    goto :finish
    :exception
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v0
    const-string v1, "FAIL guard platform exception "
    invoke-virtual {v1, v0}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v5
    const/4 v6, 0x0
    :finish
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    invoke-virtual {v0, v1, v5}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    invoke-virtual {p0, v6, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method
