.class public final Lacceptance/shizuku/CapabilityInstrumentation;
.super Landroid/app/Instrumentation;

.field private phase:Ljava/lang/String;

.method public onCreate(Landroid/os/Bundle;)V
    .registers 4
    const-string v0, "phase"
    invoke-virtual {p1, v0}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/CapabilityInstrumentation;->phase:Ljava/lang/String;
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method

.method private static failure(Ljava/lang/String;)V
    .registers 2
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method

.method private static waitState(ILjava/lang/String;)V
    .registers 6
    const/16 v0, 0xc8
  :again
    invoke-static {}, Lorg/isomorphisms/ib/ShizukuClient;->state()I
    move-result v1
    if-eq v1, p0, :ready
    const-wide/16 v2, 0x64
    invoke-static {v2, v3}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -0x1
    if-gtz v0, :again
    invoke-static {p1}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :ready
    return-void
.end method

.method private node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    .registers 12
    const/16 v0, 0xc8
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v1
  :again
    invoke-virtual {v1}, Landroid/app/UiAutomation;->getRootInActiveWindow()Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v2
    if-eqz v2, :retry
    invoke-virtual {v2}, Landroid/view/accessibility/AccessibilityNodeInfo;->getPackageName()Ljava/lang/CharSequence;
    move-result-object v3
    if-eqz v3, :retry
    invoke-interface {v3}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {p1, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :retry
    invoke-virtual {v2, p2}, Landroid/view/accessibility/AccessibilityNodeInfo;->findAccessibilityNodeInfosByViewId(Ljava/lang/String;)Ljava/util/List;
    move-result-object v5
    invoke-interface {v5}, Ljava/util/List;->size()I
    move-result v6
    const/4 v4, 0x1
    if-ne v6, v4, :retry
    const/4 v4, 0x0
    invoke-interface {v5, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Landroid/view/accessibility/AccessibilityNodeInfo;
    return-object v5
  :retry
    const-wide/16 v7, 0x64
    invoke-static {v7, v8}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -0x1
    if-gtz v0, :again
    const-string v0, "FAIL expected visible native control in declared package"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    const/4 v0, 0x0
    return-object v0
.end method

.method private click(Ljava/lang/String;Ljava/lang/String;)V
    .registers 5
    invoke-direct {p0, p1, p2}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    const/16 v1, 0x10
    invoke-virtual {v0, v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    move-result v1
    if-nez v1, :clicked
    const-string v0, "FAIL native control refused accessibility click"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :clicked
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    return-void
.end method

.method private sources()V
    .registers 3
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/sources_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private permission()V
    .registers 3
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/permission_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private assertStatus(Ljava/lang/String;)V
    .registers 5
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_status"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    if-eqz v0, :failed
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :done
  :failed
    const-string v0, "FAIL checked native Activity capability text"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :done
    return-void
.end method

.method private permissionDecision(Ljava/lang/String;)V
    .registers 6
    const-string v0, "moe.shizuku.privileged.api"
    const-string v1, "android:id/title"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :wrong
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "IB Prepaint"
    invoke-virtual {v1, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :correct
  :wrong
    const-string v1, "FAIL real permission dialog does not name the candidate app"
    invoke-static {v1}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :correct
    invoke-direct {p0, v0, p1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private unprivilegedDelivery()V
    .registers 8
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0
    const-string v1, "content://org.isomorphisms.ib.prepaint.shizuku"
    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v1
    new-instance v2, Landroid/os/Bundle;
    invoke-direct {v2}, Landroid/os/Bundle;-><init>()V
    new-instance v3, Lmoe/shizuku/api/BinderContainer;
    invoke-direct {v3}, Lmoe/shizuku/api/BinderContainer;-><init>()V
    new-instance v4, Lacceptance/shizuku/FakeUnprivilegedServer;
    invoke-direct {v4}, Lacceptance/shizuku/FakeUnprivilegedServer;-><init>()V
    iput-object v4, v3, Lmoe/shizuku/api/BinderContainer;->binder:Landroid/os/IBinder;
    const-string v4, "moe.shizuku.privileged.api.intent.extra.BINDER"
    invoke-virtual {v2, v4, v3}, Landroid/os/Bundle;->putParcelable(Ljava/lang/String;Landroid/os/Parcelable;)V
    const-string v3, "sendBinder"
    const/4 v4, 0x0
    invoke-virtual {v0, v1, v3, v4, v2}, Landroid/content/ContentResolver;->call(Landroid/net/Uri;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;
    move-result-object v0
    if-eqz v0, :refused
    const-string v0, "FAIL unprivileged Shizuku capability delivery"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :refused
    const/4 v0, 0x0
    const-string v1, "FAIL unprivileged delivery changed capability state"
    invoke-static {v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    return-void
.end method

.method private stopServerAndObserve()V
    .registers 4
    # This instrumentation is admitted only on a separately verified emulator.
    # The command is fixed; no document, URL or argument is interpolated.
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    const-string v1, "killall shizuku_server"
    invoke-virtual {v0, v1}, Landroid/app/UiAutomation;->executeShellCommand(Ljava/lang/String;)Landroid/os/ParcelFileDescriptor;
    move-result-object v0
    invoke-virtual {v0}, Landroid/os/ParcelFileDescriptor;->close()V
    const/4 v0, 0x0
    const-string v1, "FAIL revoked Shizuku capability after Binder death"
    invoke-static {v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    const-string v0, "Shizuku unavailable — start Shizuku, then retry."
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    return-void
.end method

.method public onStart()V
    .registers 10
  :begin
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/UiAutomation;->getServiceInfo()Landroid/accessibilityservice/AccessibilityServiceInfo;
    move-result-object v1
    iget v2, v1, Landroid/accessibilityservice/AccessibilityServiceInfo;->flags:I
    or-int/lit8 v2, v2, 0x12
    iput v2, v1, Landroid/accessibilityservice/AccessibilityServiceInfo;->flags:I
    invoke-virtual {v0, v1}, Landroid/app/UiAutomation;->setServiceInfo(Landroid/accessibilityservice/AccessibilityServiceInfo;)V
    new-instance v0, Landroid/content/Intent;
    invoke-direct {v0}, Landroid/content/Intent;-><init>()V
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "Idric.Generated"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v0
    if-nez v0, :launched
    const-string v0, "FAIL installed checked Activity launch"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :launched
    iget-object v0, p0, Lacceptance/shizuku/CapabilityInstrumentation;->phase:Ljava/lang/String;
    const-string v1, "missing"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :real
    const/4 v1, 0x0
    const-string v2, "FAIL absent Shizuku was treated as available"
    invoke-static {v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->unprivilegedDelivery()V
    const-string v1, "Shizuku unavailable — start Shizuku, then retry."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->permission()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    const-string v7, "PASS installed IB unavailable capability and unprivileged delivery refusal"
    goto :success
  :real
    const-string v1, "authorize"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :reconnect
    const/4 v1, 0x2
    const-string v2, "FAIL real Shizuku provider delivery and application attachment"
    invoke-static {v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->permission()V
    const-string v1, "moe.shizuku.privileged.api"
    const-string v2, "android:id/button3"
    invoke-direct {p0, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->permissionDecision(Ljava/lang/String;)V
    const/4 v1, 0x2
    const-string v2, "FAIL denied Shizuku permission granted authority"
    invoke-static {v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    const-string v1, "Shizuku permission required."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->permission()V
    const-string v1, "moe.shizuku.privileged.api"
    const-string v2, "android:id/button1"
    invoke-direct {p0, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->permissionDecision(Ljava/lang/String;)V
    const/4 v1, 0x3
    const-string v2, "FAIL actual Shizuku permission grant and identity query"
    invoke-static {v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    const-string v1, "Shizuku authorized."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->stopServerAndObserve()V
    const-string v7, "PASS installed IB real Shizuku denial grant and Binder death"
    goto :success
  :reconnect
    const-string v1, "death-only"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :known
    const-string v1, "FAIL unknown observer phase"
    invoke-static {v1}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :known
    const/4 v1, 0x3
    const-string v2, "FAIL legitimate authorized Shizuku reconnection"
    invoke-static {v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    const-string v1, "Shizuku authorized."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->stopServerAndObserve()V
    const-string v7, "PASS installed IB authorized reconnection and Binder death"
  :success
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    invoke-virtual {v0, v1, v7}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, -0x1
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
  :end
    return-void
  .catch Ljava/lang/Throwable; {:begin .. :end} :caught
  :caught
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->printStackTrace()V
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    new-instance v1, Landroid/os/Bundle;
    invoke-direct {v1}, Landroid/os/Bundle;-><init>()V
    const-string v2, "stream"
    invoke-virtual {v1, v2, v0}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v2, 0x0
    invoke-virtual {p0, v2, v1}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method
