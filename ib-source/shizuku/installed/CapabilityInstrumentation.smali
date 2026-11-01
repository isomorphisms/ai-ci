.class public final Lacceptance/shizuku/CapabilityInstrumentation;
.super Landroid/app/Instrumentation;

.field private phase:Ljava/lang/String;
.field private observedActivity:Landroid/app/Activity;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method

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
    invoke-static {}, Lacceptance/shizuku/CapabilityInstrumentation;->dumpMainStack()V
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method

.method private static dumpMainStack()V
    .registers 7
  :trace_start
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v0
    if-eqz v0, :trace_end
    invoke-virtual {v0}, Landroid/os/Looper;->getThread()Ljava/lang/Thread;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Thread;->getStackTrace()[Ljava/lang/StackTraceElement;
    move-result-object v2
    const/4 v3, 0
    const/16 v4, 24
    const-string v5, "IBIndependentReaderStack"
  :trace_next
    array-length v6, v2
    if-ge v3, v6, :trace_end
    if-ge v3, v4, :trace_end
    aget-object v0, v2, v3
    invoke-virtual {v0}, Ljava/lang/StackTraceElement;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v5, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    add-int/lit8 v3, v3, 1
    goto :trace_next
  :trace_end
    return-void
  :trace_catch_end
    .catch Ljava/lang/Throwable; {:trace_start .. :trace_catch_end} :trace_unavailable
  :trace_unavailable
    move-exception v0
    return-void
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
    const-string v0, "IBIndependentState"
    invoke-static {v1}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v1
    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
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

.method private assertReflowLabel(Ljava/lang/String;)V
    .registers 5
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reflow_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    if-eqz v0, :failed
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "IBIndependentReflowLabel"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :done
  :failed
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "FAIL visible selected reflow algorithm expected="
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, " observed="
    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :done
    return-void
.end method

.method private assertDocumentTitle(Ljava/lang/String;)V
    .registers 5
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_title"
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
    const-string v0, "FAIL extracted title in visible native toolbar"
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

.method private recordDocumentScreenshot()V
    .registers 9
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v0
    iget-object v1, p0, Lacceptance/shizuku/CapabilityInstrumentation;->phase:Ljava/lang/String;
    const-string v2, ".png"
    invoke-virtual {v1, v2}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v2, "ib-acceptance-"
    invoke-virtual {v2, v1}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    new-instance v3, Ljava/io/File;
    invoke-direct {v3, v0, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v2, Ljava/io/FileOutputStream;
    invoke-direct {v2, v3}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v3
    invoke-virtual {v3}, Landroid/app/UiAutomation;->takeScreenshot()Landroid/graphics/Bitmap;
    move-result-object v4
    sget-object v5, Landroid/graphics/Bitmap$CompressFormat;->PNG:Landroid/graphics/Bitmap$CompressFormat;
    const/16 v6, 0x64
    invoke-virtual {v4, v5, v6, v2}, Landroid/graphics/Bitmap;->compress(Landroid/graphics/Bitmap$CompressFormat;ILjava/io/OutputStream;)Z
    move-result v7
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V
    if-nez v7, :saved
    const-string v0, "FAIL independent visible document screenshot"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :saved
    return-void
.end method

.method private logReaderFailureStatus()V
    .registers 5
  :status_start
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_status"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    if-eqz v0, :status_end
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    const/16 v2, 1024
    if-le v1, v2, :status_log
    const/4 v1, 0
    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v0
  :status_log
    const-string v1, "IBIndependentReaderStatus"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
  :status_end
    return-void
  :status_catch_end
    .catch Ljava/lang/Throwable; {:status_start .. :status_catch_end} :status_unavailable
  :status_unavailable
    move-exception v0
    return-void
.end method

.method private logReaderFailureBody()V
    .registers 5
  :body_start
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_body"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    if-eqz v0, :body_end
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v1
    const/16 v2, 4096
    if-le v1, v2, :body_log
    const/4 v1, 0
    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v0
  :body_log
    const-string v1, "IBIndependentReaderBody"
    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
  :body_end
    return-void
  :body_catch_end
    .catch Ljava/lang/Throwable; {:body_start .. :body_catch_end} :body_unavailable
  :body_unavailable
    move-exception v0
    return-void
.end method

.method private waitExampleDocument()V
    .registers 8
    const/16 v0, 0x258
  :again
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "org.isomorphisms.ib.prepaint:id/reader_body"
    invoke-direct {p0, v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :retry
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "\\s+"
    const-string v3, " "
    invoke-virtual {v1, v2, v3}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v2, "This domain is for use in documentation examples without needing permission."
    invoke-virtual {v1, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-eqz v2, :retry
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "org.isomorphisms.ib.prepaint:id/reader_status"
    invoke-direct {p0, v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :retry
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "Static HTML — scripts and forms are unavailable."
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :retry
    const-string v1, "Static HTML — scripts and forms are unavailable."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    const-string v1, "Example Domain"
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertDocumentTitle(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->recordDocumentScreenshot()V
    return-void
  :retry
    const-wide/16 v5, 0x64
    invoke-static {v5, v6}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -0x1
    if-gtz v0, :again
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureBody()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureStatus()V
    const-string v0, "FAIL actual acquired Example Domain in native document view"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
.end method

.method private exactExampleClipboard()V
    .registers 2
    const-string v0, "This domain is for use in documentation examples without needing permission. This is not a service; avoid relying on it for testing and monitoring purposes."
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->exactSourceClipboard(Ljava/lang/String;)V
    return-void
.end method

.method private exactSourceClipboard(Ljava/lang/String;)V
    .registers 10
    const/4 v7, 0x1
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_body"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->isFocused()Z
    move-result v1
    if-nez v1, :focused
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    move-result v1
    if-eqz v1, :failed
  :focused
    const/4 v7, 0x2
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :failed
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "IBIndependentCopyDisplay"
    invoke-static {v2, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-virtual {v1}, Ljava/lang/String;->length()I
    move-result v3
    if-lez v3, :failed
    const/4 v7, 0x3
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v4
    const-string v5, "clipboard"
    invoke-virtual {v4, v5}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v4
    check-cast v4, Landroid/content/ClipboardManager;
    const-string v5, "Independent stale-clipboard control"
    const-string v6, "This is not the source selection."
    invoke-static {v5, v6}, Landroid/content/ClipData;->newPlainText(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Landroid/content/ClipData;
    move-result-object v5
    invoke-virtual {v4, v5}, Landroid/content/ClipboardManager;->setPrimaryClip(Landroid/content/ClipData;)V
    new-instance v2, Landroid/os/Bundle;
    invoke-direct {v2}, Landroid/os/Bundle;-><init>()V
    const-string v5, "ACTION_ARGUMENT_SELECTION_START_INT"
    const/4 v6, 0x0
    invoke-virtual {v2, v5, v6}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    const-string v5, "ACTION_ARGUMENT_SELECTION_END_INT"
    invoke-virtual {v2, v5, v3}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    const/4 v7, 0x4
    const v1, 0x20000
    invoke-virtual {v0, v1, v2}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(ILandroid/os/Bundle;)Z
    move-result v1
    if-eqz v1, :failed
    const/4 v7, 0x5
    const/16 v1, 0x4000
    invoke-virtual {v0, v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    move-result v1
    if-eqz v1, :failed
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    const/4 v7, 0x6
    invoke-virtual {v4}, Landroid/content/ClipboardManager;->getPrimaryClip()Landroid/content/ClipData;
    move-result-object v4
    if-eqz v4, :failed
    invoke-virtual {v4}, Landroid/content/ClipData;->getItemCount()I
    move-result v1
    const/4 v2, 0x1
    if-ne v1, v2, :failed
    const/4 v7, 0x7
    invoke-virtual {v4}, Landroid/content/ClipData;->getDescription()Landroid/content/ClipDescription;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/ClipDescription;->getLabel()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :failed
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "IB source selection"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :failed
    const/4 v1, 0x0
    invoke-virtual {v4, v1}, Landroid/content/ClipData;->getItemAt(I)Landroid/content/ClipData$Item;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/ClipData$Item;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :failed
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const/16 v7, 0x8
    const-string v2, "IBIndependentClipboard"
    invoke-static {v2, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    move-object v2, p1
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :failed
    return-void
  :failed
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "FAIL actual SDK selection and exact source clipboard stage="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
.end method

.method private reflowAndCopyExample()V
    .registers 3
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->waitExampleDocument()V
    const-string v0, "REFLOW: GREEDY"
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->assertReflowLabel(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->exactExampleClipboard()V
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reflow_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->waitExampleDocument()V
    const-string v0, "REFLOW: SQUARED"
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->assertReflowLabel(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->exactExampleClipboard()V
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reflow_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->waitExampleDocument()V
    const-string v0, "REFLOW: GREEDY"
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->assertReflowLabel(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->exactExampleClipboard()V
    return-void
.end method

.method private readExampleDocument()V
    .registers 7
    const/4 v0, 0x3
    const-string v1, "FAIL authorized acquisition capability before native navigation"
    invoke-static {v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_input"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    new-instance v2, Landroid/os/Bundle;
    invoke-direct {v2}, Landroid/os/Bundle;-><init>()V
    const-string v3, "ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE"
    const-string v4, "https://example.com/"
    invoke-virtual {v2, v3, v4}, Landroid/os/Bundle;->putCharSequence(Ljava/lang/String;Ljava/lang/CharSequence;)V
    const v3, 0x200000
    invoke-virtual {v1, v3, v2}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(ILandroid/os/Bundle;)Z
    move-result v1
    if-nez v1, :entered
    const-string v1, "FAIL native URL input refused text entry"
    invoke-static {v1}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :entered
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    const-string v1, "org.isomorphisms.ib.prepaint:id/read_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->waitExampleDocument()V
    return-void
.end method

.method private waitNetworkDocument(Ljava/lang/String;Ljava/lang/String;)V
    .registers 10
    const/16 v0, 0x258
  :again
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "org.isomorphisms.ib.prepaint:id/reader_body"
    invoke-direct {p0, v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :retry
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "\\s+"
    const-string v3, " "
    invoke-virtual {v1, v2, v3}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    move-object v2, p2
    invoke-virtual {v1, v2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v2
    if-eqz v2, :retry
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "org.isomorphisms.ib.prepaint:id/reader_status"
    invoke-direct {p0, v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :retry
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "Static HTML — scripts and forms are unavailable."
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :retry
    const-string v1, "Static HTML — scripts and forms are unavailable."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    invoke-direct {p0, p1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertDocumentTitle(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->recordDocumentScreenshot()V
    return-void
  :retry
    const-wide/16 v5, 0x64
    invoke-static {v5, v6}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -0x1
    if-gtz v0, :again
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureBody()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureStatus()V
    const-string v0, "FAIL actual acquired controlled native document"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
.end method

.method private enterReaderURL(Ljava/lang/String;)V
    .registers 7
    const/4 v0, 0x3
    const-string v1, "FAIL authorized acquisition capability before native navigation"
    invoke-static {v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->sources()V
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_input"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    new-instance v2, Landroid/os/Bundle;
    invoke-direct {v2}, Landroid/os/Bundle;-><init>()V
    const-string v3, "ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE"
    move-object v4, p1
    invoke-virtual {v2, v3, v4}, Landroid/os/Bundle;->putCharSequence(Ljava/lang/String;Ljava/lang/CharSequence;)V
    const v3, 0x200000
    invoke-virtual {v1, v3, v2}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(ILandroid/os/Bundle;)Z
    move-result v1
    if-nez v1, :entered
    const-string v1, "FAIL native URL input refused text entry"
    invoke-static {v1}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :entered
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    const-string v1, "org.isomorphisms.ib.prepaint:id/read_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private tapNextLink()V
    .registers 14
    iget-object v10, p0, Lacceptance/shizuku/CapabilityInstrumentation;->observedActivity:Landroid/app/Activity;
    new-instance v9, Lacceptance/shizuku/VisibleLinkPoint;
    invoke-direct {v9, v10}, Lacceptance/shizuku/VisibleLinkPoint;-><init>(Landroid/app/Activity;)V
    invoke-virtual {p0, v9}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-object v10, v9, Lacceptance/shizuku/VisibleLinkPoint;->problem:Ljava/lang/String;
    if-eqz v10, :visible
    invoke-static {v10}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :visible
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v10
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v0
    move-wide v2, v0
    const/4 v4, 0x0
    iget v5, v9, Lacceptance/shizuku/VisibleLinkPoint;->x:F
    iget v6, v9, Lacceptance/shizuku/VisibleLinkPoint;->y:F
    const/4 v7, 0x0
    invoke-static/range {v0 .. v7}, Landroid/view/MotionEvent;->obtain(JJIFFI)Landroid/view/MotionEvent;
    move-result-object v8
    const/16 v11, 0x1002
    invoke-virtual {v8, v11}, Landroid/view/MotionEvent;->setSource(I)V
    const/4 v11, 0x1
    invoke-virtual {v10, v8, v11}, Landroid/app/UiAutomation;->injectInputEvent(Landroid/view/InputEvent;Z)Z
    move-result v11
    invoke-virtual {v8}, Landroid/view/MotionEvent;->recycle()V
    if-eqz v11, :failed
    const-wide/16 v11, 0x32
    invoke-static {v11, v12}, Landroid/os/SystemClock;->sleep(J)V
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    const/4 v4, 0x1
    invoke-static/range {v0 .. v7}, Landroid/view/MotionEvent;->obtain(JJIFFI)Landroid/view/MotionEvent;
    move-result-object v8
    const/16 v11, 0x1002
    invoke-virtual {v8, v11}, Landroid/view/MotionEvent;->setSource(I)V
    const/4 v11, 0x1
    invoke-virtual {v10, v8, v11}, Landroid/app/UiAutomation;->injectInputEvent(Landroid/view/InputEvent;Z)Z
    move-result v11
    invoke-virtual {v8}, Landroid/view/MotionEvent;->recycle()V
    if-eqz v11, :failed
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    return-void
  :failed
    const-string v0, "FAIL actual down/up input at visible Next link"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
.end method

.method private fixtureOne()V
    .registers 3
    const-string v0, "Reader One"
    const-string v1, "First retained fixture:"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitNetworkDocument(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private fixtureTwo()V
    .registers 3
    const-string v0, "Reader Two"
    const-string v1, "Second retained fixture acquired through ICU."
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitNetworkDocument(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private historyBack()V
    .registers 3
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/back_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private historyForward()V
    .registers 3
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/forward_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    return-void
.end method

.method private scrollFixture()V
    .registers 6
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_body"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getParent()Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    if-eqz v0, :failed
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getClassName()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :failed
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "android.widget.ScrollView"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :failed
    const/16 v1, 0x2000
    invoke-virtual {v0, v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    const/16 v1, 0x1000
    invoke-virtual {v0, v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    move-result v1
    if-eqz v1, :failed
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    return-void
  :failed
    const-string v0, "FAIL actual native ScrollView fixture movement"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
.end method

.method private networkNavigation()V
    .registers 3
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->waitExampleDocument()V
    const-string v0, "http://10.0.2.2:18491/valid"
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->enterReaderURL(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureOne()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->tapNextLink()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureTwo()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyBack()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureOne()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyForward()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureTwo()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyBack()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureOne()V
    const-string v0, "Reader One\n\nNext\n\nFirst retained fixture: café 🌍; co­operate across source-backed wraps.\n\nParagraph 01 preserves a separate source block for scrolling and reflow.\n\nParagraph 02 preserves a separate source block for scrolling and reflow.\n\nParagraph 03 preserves a separate source block for scrolling and reflow.\n\nParagraph 04 preserves a separate source block for scrolling and reflow.\n\nParagraph 05 preserves a separate source block for scrolling and reflow.\n\nParagraph 06 preserves a separate source block for scrolling and reflow.\n\nParagraph 07 preserves a separate source block for scrolling and reflow.\n\nParagraph 08 preserves a separate source block for scrolling and reflow.\n\nParagraph 09 preserves a separate source block for scrolling and reflow.\n\nParagraph 10 preserves a separate source block for scrolling and reflow.\n\nParagraph 11 preserves a separate source block for scrolling and reflow.\n\nParagraph 12 preserves a separate source block for scrolling and reflow.\n\nParagraph 13 preserves a separate source block for scrolling and reflow.\n\nParagraph 14 preserves a separate source block for scrolling and reflow.\n\nParagraph 15 preserves a separate source block for scrolling and reflow.\n\nParagraph 16 preserves a separate source block for scrolling and reflow.\n\nParagraph 17 preserves a separate source block for scrolling and reflow.\n\nParagraph 18 preserves a separate source block for scrolling and reflow.\n\nParagraph 19 preserves a separate source block for scrolling and reflow.\n\nParagraph 20 preserves a separate source block for scrolling and reflow."
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->exactSourceClipboard(Ljava/lang/String;)V
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reflow_button"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->click(Ljava/lang/String;Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureOne()V
    const-string v0, "REFLOW: SQUARED"
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->assertReflowLabel(Ljava/lang/String;)V
    const-string v0, "Reader One\n\nNext\n\nFirst retained fixture: café 🌍; co­operate across source-backed wraps.\n\nParagraph 01 preserves a separate source block for scrolling and reflow.\n\nParagraph 02 preserves a separate source block for scrolling and reflow.\n\nParagraph 03 preserves a separate source block for scrolling and reflow.\n\nParagraph 04 preserves a separate source block for scrolling and reflow.\n\nParagraph 05 preserves a separate source block for scrolling and reflow.\n\nParagraph 06 preserves a separate source block for scrolling and reflow.\n\nParagraph 07 preserves a separate source block for scrolling and reflow.\n\nParagraph 08 preserves a separate source block for scrolling and reflow.\n\nParagraph 09 preserves a separate source block for scrolling and reflow.\n\nParagraph 10 preserves a separate source block for scrolling and reflow.\n\nParagraph 11 preserves a separate source block for scrolling and reflow.\n\nParagraph 12 preserves a separate source block for scrolling and reflow.\n\nParagraph 13 preserves a separate source block for scrolling and reflow.\n\nParagraph 14 preserves a separate source block for scrolling and reflow.\n\nParagraph 15 preserves a separate source block for scrolling and reflow.\n\nParagraph 16 preserves a separate source block for scrolling and reflow.\n\nParagraph 17 preserves a separate source block for scrolling and reflow.\n\nParagraph 18 preserves a separate source block for scrolling and reflow.\n\nParagraph 19 preserves a separate source block for scrolling and reflow.\n\nParagraph 20 preserves a separate source block for scrolling and reflow."
    invoke-direct {p0, v0}, Lacceptance/shizuku/CapabilityInstrumentation;->exactSourceClipboard(Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->scrollFixture()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyForward()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureTwo()V
    return-void
.end method

.method private offlineNetworkHistory()V
    .registers 3
    const/4 v0, 0x0
    const-string v1, "FAIL offline network history requires absent Shizuku"
    invoke-static {v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureTwo()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyBack()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureOne()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyBack()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->waitExampleDocument()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyForward()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureOne()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->historyForward()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureTwo()V
    return-void
.end method


.method public callActivityOnCreate(Landroid/app/Activity;Landroid/os/Bundle;)V
    .registers 3
    invoke-super {p0, p1, p2}, Landroid/app/Instrumentation;->callActivityOnCreate(Landroid/app/Activity;Landroid/os/Bundle;)V
    iput-object p1, p0, Lacceptance/shizuku/CapabilityInstrumentation;->observedActivity:Landroid/app/Activity;
    return-void
.end method

.method private waitStatus(Ljava/lang/String;)V
    .registers 8
    const/16 v0, 0x258
  :again
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "org.isomorphisms.ib.prepaint:id/reader_status"
    invoke-direct {p0, v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :retry
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :done
  :retry
    const-wide/16 v3, 0x64
    invoke-static {v3, v4}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -0x1
    if-gtz v0, :again
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureStatus()V
    const-string v0, "FAIL expected explicit native search or acquisition result"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :done
    return-void
.end method

.method private static searchIntent()Landroid/content/Intent;
    .registers 3
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.SEARCH"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "Idric.Generated"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const-string v1, "query"
    const-string v2, "IB café + %2F 🌍 chords"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    return-object v0
.end method

.method private searchCallerRefusals()V
    .registers 7
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureTwo()V
    invoke-static {}, Lacceptance/shizuku/CapabilityInstrumentation;->searchIntent()Landroid/content/Intent;
    move-result-object v0
    const-string v1, "android.intent.extra.REFERRER_NAME"
    const-string v2, "android-app://org.isomorphisms.chordreader.dev"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const/high16 v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v0
    if-eqz v0, :no_activity
    iput-object v0, p0, Lacceptance/shizuku/CapabilityInstrumentation;->observedActivity:Landroid/app/Activity;
    invoke-virtual {v0}, Landroid/app/Activity;->getCallingPackage()Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :null_caller
    const-string v0, "FAIL no-result search unexpectedly authenticated a caller"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
  :no_activity
    const-string v0, "FAIL negative search Activity launch"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
  :null_caller
    const-string v1, "Search refused: a fresh authenticated ChordReader handoff is required."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitStatus(Ljava/lang/String;)V
    const-wide/16 v1, 0x7d0
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    const-string v1, "Reader Two"
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertDocumentTitle(Ljava/lang/String;)V
    const-string v1, "Search refused: a fresh authenticated ChordReader handoff is required."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertStatus(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/shizuku/CapabilityInstrumentation;->searchIntent()Landroid/content/Intent;
    move-result-object v1
    new-instance v2, Lacceptance/shizuku/SearchDispatch;
    const/4 v3, 0x0
    invoke-direct {v2, v0, v1, v3}, Lacceptance/shizuku/SearchDispatch;-><init>(Landroid/app/Activity;Landroid/content/Intent;Z)V
    invoke-virtual {p0, v2}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    const-string v1, "Search refused: the sender is not ChordReader."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitStatus(Ljava/lang/String;)V
    const-wide/16 v1, 0x7d0
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    const-string v1, "Reader Two"
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertDocumentTitle(Ljava/lang/String;)V
    iget-object v0, p0, Lacceptance/shizuku/CapabilityInstrumentation;->observedActivity:Landroid/app/Activity;
    invoke-virtual {v0}, Landroid/app/Activity;->getCallingPackage()Ljava/lang/String;
    move-result-object v1
    const-string v2, "org.isomorphisms.ib.prepaint"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :own_caller
    const-string v1, "FAIL wrong for-result caller control did not originate in IB"
    invoke-static {v1}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :own_caller
    invoke-static {}, Lacceptance/shizuku/CapabilityInstrumentation;->searchIntent()Landroid/content/Intent;
    move-result-object v1
    new-instance v2, Lacceptance/shizuku/SearchDispatch;
    const/4 v3, 0x1
    invoke-direct {v2, v0, v1, v3}, Lacceptance/shizuku/SearchDispatch;-><init>(Landroid/app/Activity;Landroid/content/Intent;Z)V
    invoke-virtual {p0, v2}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    const-string v1, "Search refused: start a fresh ChordReader handoff or enter a URL in Sources."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitStatus(Ljava/lang/String;)V
    const-string v1, "Reader Two"
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertDocumentTitle(Ljava/lang/String;)V
    return-void
.end method

.method private static findChordControl(Landroid/view/accessibility/AccessibilityNodeInfo;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    .registers 7
    invoke-virtual {p0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getContentDescription()Ljava/lang/CharSequence;
    move-result-object v0
    if-eqz v0, :children
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :found
  :children
    invoke-virtual {p0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getChildCount()I
    move-result v0
    const/4 v1, 0x0
  :next
    if-ge v1, v0, :absent
    invoke-virtual {p0, v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getChild(I)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v2
    if-eqz v2, :advance
    invoke-static {v2, p1}, Lacceptance/shizuku/CapabilityInstrumentation;->findChordControl(Landroid/view/accessibility/AccessibilityNodeInfo;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v3
    if-nez v3, :child_found
  :advance
    add-int/lit8 v1, v1, 0x1
    goto :next
  :child_found
    return-object v3
  :found
    return-object p0
  :absent
    const/4 v0, 0x0
    return-object v0
.end method

.method private clickChordSearch()V
    .registers 8
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
    move-result-object v3
    const-string v4, "org.isomorphisms.chordreader.dev"
    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :retry
    const-string v3, "search-web"
    invoke-static {v2, v3}, Lacceptance/shizuku/CapabilityInstrumentation;->findChordControl(Landroid/view/accessibility/AccessibilityNodeInfo;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v2
    if-eqz v2, :retry
    const/16 v3, 0x10
    invoke-virtual {v2, v3}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    move-result v3
    if-eqz v3, :retry
    return-void
  :retry
    const-wide/16 v5, 0x64
    invoke-static {v5, v6}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -0x1
    if-gtz v0, :again
    const-string v0, "FAIL actual ChordReader search control"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
.end method

.method private chordSearchHandoff()V
    .registers 8
    const/4 v0, 0x3
    const-string v1, "FAIL authorized real worker before ChordReader search"
    invoke-static {v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.SEND"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v1, "org.isomorphisms.chordreader.dev"
    const-string v2, "org.isomorphisms.NativeViewActivity"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const-string v1, "text/plain"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;
    const-string v1, "android.intent.extra.TITLE"
    const-string v2, "IB café + %2F 🌍"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const-string v1, "android.intent.extra.TEXT"
    const-string v2, "[C] Public search handoff acceptance fixture"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const/high16 v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v1
    invoke-virtual {v1, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->clickChordSearch()V
    const-string v0, "org.isomorphisms.ib.prepaint"
    const-string v1, "org.isomorphisms.ib.prepaint:id/reader_status"
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->node(Ljava/lang/String;Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    const/16 v0, 0xc8
  :again
    iget-object v1, p0, Lacceptance/shizuku/CapabilityInstrumentation;->observedActivity:Landroid/app/Activity;
    invoke-virtual {v1}, Landroid/app/Activity;->getCallingPackage()Ljava/lang/String;
    move-result-object v2
    const-string v3, "org.isomorphisms.chordreader.dev"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :retry
    new-instance v2, Lacceptance/shizuku/ReaderAddressSnapshot;
    invoke-direct {v2, v1}, Lacceptance/shizuku/ReaderAddressSnapshot;-><init>(Landroid/app/Activity;)V
    invoke-virtual {p0, v2}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-object v2, v2, Lacceptance/shizuku/ReaderAddressSnapshot;->address:Ljava/lang/String;
    const-string v3, "https://google.com/search?q=IB+caf%C3%A9+%2B+%252F+%F0%9F%8C%8D+chords"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :encoded
  :retry
    const-wide/16 v4, 0x64
    invoke-static {v4, v5}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -0x1
    if-gtz v0, :again
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureStatus()V
    const-string v0, "FAIL real ChordReader caller and exact once-encoded Google URL"
    invoke-static {v0}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
    return-void
  :encoded
    const-string v0, "IBIndependentSearchAddress"
    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    const-wide/16 v0, 0x7530
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureStatus()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->logReaderFailureBody()V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->recordDocumentScreenshot()V
    return-void
.end method


.method private httpStatusRefusal()V
    .registers 5
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->fixtureTwo()V
    invoke-static {}, Lorg/isomorphisms/ib/ReaderBridge;->history()Ljava/lang/String;
    move-result-object v0
    const-string v1, "http://10.0.2.2:18491/not-found"
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->enterReaderURL(Ljava/lang/String;)V
    const-string v1, "HTTP 404 did not admit a readable document."
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->waitStatus(Ljava/lang/String;)V
    const-string v1, "Reader Two"
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->assertDocumentTitle(Ljava/lang/String;)V
    invoke-static {}, Lorg/isomorphisms/ib/ReaderBridge;->history()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :preserved
    const-string v1, "FAIL HTTP error changed last-good navigation"
    invoke-static {v1}, Lacceptance/shizuku/CapabilityInstrumentation;->failure(Ljava/lang/String;)V
  :preserved
    const-string v1, "Reader Two\n\nSecond retained fixture acquired through ICU.\n\nFirst"
    invoke-direct {p0, v1}, Lacceptance/shizuku/CapabilityInstrumentation;->exactSourceClipboard(Ljava/lang/String;)V
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
    return-void
  :launched
    iput-object v0, p0, Lacceptance/shizuku/CapabilityInstrumentation;->observedActivity:Landroid/app/Activity;
    iget-object v0, p0, Lacceptance/shizuku/CapabilityInstrumentation;->phase:Ljava/lang/String;
    const-string v1, "http-refusal"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :search_caller_controls
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->httpStatusRefusal()V
    const-string v7, "PASS installed actual ICU HTTP 404 refusal preserves visible source clipboard and navigation"
    goto :success
  :search_caller_controls
    const-string v1, "search-callers"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :chord_search
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->searchCallerRefusals()V
    const-string v7, "PASS installed no-caller spoofed-referrer wrong-caller and warm SEARCH refusals"
    goto :success
  :chord_search
    const-string v1, "chord-search"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :capability_phases
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->chordSearchHandoff()V
    const-string v7, "PASS actual ChordReader SEARCH caller and exact Google request encoding; Google results remain unqualified"
    goto :success
  :capability_phases
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
    const-string v1, "read-example"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :reflow_copy
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->readExampleDocument()V
    const-string v7, "PASS installed native URL entry actual Example Domain and acknowledged retained source"
    goto :success
  :reflow_copy
    const-string v1, "reflow-copy-example"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :retained
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->reflowAndCopyExample()V
    const-string v7, "PASS installed native reflow selector and exact source clipboard in both modes"
    goto :success
  :retained
    const-string v1, "retained-example"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :network
    const/4 v1, 0x0
    const-string v2, "FAIL retained-source control requires absent Shizuku"
    invoke-static {v1, v2}, Lacceptance/shizuku/CapabilityInstrumentation;->waitState(ILjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->waitExampleDocument()V
    const-string v7, "PASS installed native retained Example Domain reopened with Shizuku unavailable"
    goto :success
  :network
    const-string v1, "network-navigation"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :offline_network
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->networkNavigation()V
    const-string v7, "PASS installed actual link acquisition Back Forward Unicode source clipboard reflow and scrolling"
    goto :success
  :offline_network
    const-string v1, "offline-network-history"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :authorization
    invoke-direct {p0}, Lacceptance/shizuku/CapabilityInstrumentation;->offlineNetworkHistory()V
    const-string v7, "PASS installed retained three-document Back Forward without Shizuku"
    goto :success
  :authorization
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
