.class public final Lacceptance/admin/AdminUi;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private final observer:Lacceptance/admin/AdminInstrumentation;
.field private final operation:I
.field private final text:Ljava/lang/String;

.method public constructor <init>(Lacceptance/admin/AdminInstrumentation;ILjava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/admin/AdminUi;->observer:Lacceptance/admin/AdminInstrumentation;
    iput p2, p0, Lacceptance/admin/AdminUi;->operation:I
    iput-object p3, p0, Lacceptance/admin/AdminUi;->text:Ljava/lang/String;
    return-void
.end method

.method public run()V
    .locals 9
    iget-object v0, p0, Lacceptance/admin/AdminUi;->observer:Lacceptance/admin/AdminInstrumentation;
    iget-object v1, v0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    iget v2, p0, Lacceptance/admin/AdminUi;->operation:I
    iget-object v3, p0, Lacceptance/admin/AdminUi;->text:Ljava/lang/String;
  :try_start
    if-eqz v2, :open
    const/4 v4, 2
    if-eq v2, v4, :resume
    const/4 v4, 4
    if-eq v2, v4, :recreate
    const v4, 0x7f030013
    invoke-virtual {v1, v4}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v4
    if-eqz v4, :missing
    check-cast v4, Landroid/webkit/WebView;
    const/4 v5, 5
    if-ge v2, v5, :diagnostic
    const/4 v5, 3
    if-eq v2, v5, :terminate
    const/4 v5, 2
    new-array v5, v5, [I
    invoke-virtual {v4, v5}, Landroid/view/View;->getLocationOnScreen([I)V
    const/4 v6, 0
    aget v6, v5, v6
    iput v6, v0, Lacceptance/admin/AdminInstrumentation;->webX:I
    const/4 v6, 1
    aget v6, v5, v6
    iput v6, v0, Lacceptance/admin/AdminInstrumentation;->webY:I
    invoke-virtual {v4}, Landroid/webkit/WebView;->getScale()F
    move-result v5
    iput v5, v0, Lacceptance/admin/AdminInstrumentation;->webScale:F
    iget-object v5, v0, Lacceptance/admin/AdminInstrumentation;->evaluation:Lacceptance/admin/AdminCallback;
    invoke-virtual {v4, v3, v5}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
    return-void
  :diagnostic
    const/16 v5, 10
    if-eq v2, v5, :lifecycle
    const/4 v5, 7
    if-eq v2, v5, :stale
    const/16 v5, 9
    if-eq v2, v5, :stale_document
    invoke-static {v4}, Lacceptance/admin/AdminUi;->nativeCallback(Landroid/webkit/WebView;)Landroid/webkit/ValueCallback;
    move-result-object v5
    const/16 v6, 8
    if-ne v2, v6, :not_capture
    iput-object v5, v0, Lacceptance/admin/AdminInstrumentation;->staleDiagnostic:Landroid/webkit/ValueCallback;
    const/4 v6, 1
    iput v6, v0, Lacceptance/admin/AdminInstrumentation;->diagnosticDone:I
    return-void
  :not_capture
    const/4 v6, 6
    if-ne v2, v6, :secret
    iput-object v5, v0, Lacceptance/admin/AdminInstrumentation;->staleDiagnostic:Landroid/webkit/ValueCallback;
    iput-object v4, v0, Lacceptance/admin/AdminInstrumentation;->diagnosticWeb:Landroid/webkit/WebView;
    const-string v3, "[10001,10002,10003,10004,10005,10006,10007,10008,10009,10010,10011,10012]"
    goto :dispatch_diagnostic
  :secret
    const-string v3, "[0,0,0,0,0,0,0,0,0,0,0,document.getElementById('one-time').textContent]"
    goto :dispatch_diagnostic
  :stale
    iget-object v5, v0, Lacceptance/admin/AdminInstrumentation;->staleDiagnostic:Landroid/webkit/ValueCallback;
    const-string v3, "[20001,20002,20003,20004,20005,20006,20007,20008,20009,20010,20011,20012]"
    goto :dispatch_diagnostic
  :stale_document
    iget-object v5, v0, Lacceptance/admin/AdminInstrumentation;->staleDiagnostic:Landroid/webkit/ValueCallback;
    iget-object v6, v0, Lacceptance/admin/AdminInstrumentation;->diagnosticWeb:Landroid/webkit/WebView;
    if-ne v4, v6, :failed_document
    invoke-static {v5}, Lacceptance/admin/AdminUi;->epoch(Ljava/lang/Object;)I
    move-result v7
    invoke-virtual {v4}, Landroid/webkit/WebView;->getWebViewClient()Landroid/webkit/WebViewClient;
    move-result-object v6
    invoke-static {v6}, Lacceptance/admin/AdminUi;->epoch(Ljava/lang/Object;)I
    move-result v8
    if-le v8, v7, :failed_document
    const-string v3, "[30001,30002,30003,30004,30005,30006,30007,30008,30009,30010,30011,30012]"
  :dispatch_diagnostic
    new-instance v6, Lacceptance/admin/AdminDiagnosticCallback;
    invoke-direct {v6, v5, v0}, Lacceptance/admin/AdminDiagnosticCallback;-><init>(Landroid/webkit/ValueCallback;Lacceptance/admin/AdminInstrumentation;)V
    invoke-virtual {v4, v3, v6}, Landroid/webkit/WebView;->evaluateJavascript(Ljava/lang/String;Landroid/webkit/ValueCallback;)V
    return-void
  :lifecycle
    invoke-static {v4}, Lacceptance/admin/AdminUi;->lifecycleProbe(Landroid/webkit/WebView;)V
    const/4 v5, 1
    iput v5, v0, Lacceptance/admin/AdminInstrumentation;->diagnosticDone:I
    return-void
  :open
    const v4, 0x7f030001
    invoke-virtual {v1, v4}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v4
    check-cast v4, Landroid/widget/EditText;
    invoke-virtual {v4, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v4, 0x7f03000f
    goto :click
  :resume
    const v4, 0x7f030010
  :click
    invoke-virtual {v1, v4}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v4
    invoke-virtual {v4}, Landroid/view/View;->performClick()Z
    move-result v5
    if-eqz v5, :failed_click
    return-void
  :terminate
    invoke-virtual {v4}, Landroid/webkit/WebView;->getWebViewRenderProcess()Landroid/webkit/WebViewRenderProcess;
    move-result-object v4
    if-eqz v4, :failed_renderer
    invoke-virtual {v4}, Landroid/webkit/WebViewRenderProcess;->terminate()Z
    move-result v5
    if-eqz v5, :failed_renderer
    return-void
  :recreate
    invoke-virtual {v1}, Landroid/app/Activity;->recreate()V
    return-void
  :missing
    const/4 v5, 3
    if-eq v2, v5, :missing_renderer
    iget-object v5, v0, Lacceptance/admin/AdminInstrumentation;->evaluation:Lacceptance/admin/AdminCallback;
    if-eqz v5, :missing_done
    const-string v4, "null"
    invoke-virtual {v5, v4}, Lacceptance/admin/AdminCallback;->onReceiveValue(Ljava/lang/Object;)V
  :missing_done
    return-void
  :failed_click
    const-string v4, "FAIL native protected control did not dispatch"
    iput-object v4, v0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    return-void
  :failed_renderer
    const-string v4, "FAIL independent renderer termination"
    iput-object v4, v0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    return-void
  :missing_renderer
    const-string v4, "FAIL independent renderer termination: protected WebView is absent"
    iput-object v4, v0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    return-void
  :failed_document
    const-string v4, "FAIL document callback probe did not preserve renderer and advance document"
    iput-object v4, v0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    return-void
  :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :failed
  :failed
    move-exception v4
    const-string v4, "FAIL independent UI operation exception"
    iput-object v4, v0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    return-void
.end method

.method private static probeBoundary(I)V
    .locals 3
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "observer_probe=1 boundary="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v1, " host_pid="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-static {}, Landroid/os/Process;->myPid()I
    move-result v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "IBAdminProbe"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
.end method

.method private static lifecycleProbe(Landroid/webkit/WebView;)V
    .locals 3
    invoke-virtual {p0}, Landroid/webkit/WebView;->getWebViewClient()Landroid/webkit/WebViewClient;
    move-result-object v0
    invoke-static {v0}, Lacceptance/admin/AdminUi;->epoch(Ljava/lang/Object;)I
    move-result v1
    const/4 v2, 1
    if-le v1, v2, :failed
    invoke-virtual {p0}, Landroid/webkit/WebView;->getUrl()Ljava/lang/String;
    move-result-object v1
    const-string v2, "http://127.0.0.1:18493/"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :failed
    const/4 v1, 1
    invoke-static {v1}, Lacceptance/admin/AdminUi;->probeBoundary(I)V
    const-string v1, "http://127.0.0.1:18493/verify"
    invoke-virtual {v0, p0, v1}, Landroid/webkit/WebViewClient;->onPageCommitVisible(Landroid/webkit/WebView;Ljava/lang/String;)V
    invoke-virtual {v0, p0, v1}, Landroid/webkit/WebViewClient;->onPageFinished(Landroid/webkit/WebView;Ljava/lang/String;)V
    const-string v1, "http://127.0.0.1:18493/"
    invoke-virtual {v0, p0, v1}, Landroid/webkit/WebViewClient;->onPageCommitVisible(Landroid/webkit/WebView;Ljava/lang/String;)V
    invoke-virtual {v0, p0, v1}, Landroid/webkit/WebViewClient;->onPageFinished(Landroid/webkit/WebView;Ljava/lang/String;)V
    const/4 v1, 2
    invoke-static {v1}, Lacceptance/admin/AdminUi;->probeBoundary(I)V
    return-void
  :failed
    new-instance v0, Ljava/lang/AssertionError;
    const-string v1, "FAIL lifecycle probe lacked repeated current document"
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method

.method private static epoch(Ljava/lang/Object;)I
    .locals 2
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    const-string v1, "documentEpoch"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 1
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    invoke-virtual {v0, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/Integer;
    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I
    move-result v0
    return v0
.end method

.method private static copyField(Ljava/lang/String;Ljava/lang/Class;Ljava/lang/Object;Ljava/lang/Class;Ljava/lang/Object;)V
    .locals 2
    invoke-virtual {p1, p0}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 1
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    invoke-virtual {v0, p2}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    invoke-virtual {p3, p0}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object p0
    invoke-virtual {p0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    invoke-virtual {p0, p4, v0}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
    return-void
.end method

.method private static nativeCallback(Landroid/webkit/WebView;)Landroid/webkit/ValueCallback;
    .locals 5
    invoke-virtual {p0}, Landroid/webkit/WebView;->getWebViewClient()Landroid/webkit/WebViewClient;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v1
    invoke-virtual {v1}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;
    move-result-object v3
    const-string v0, "org.isomorphisms.ib.LongViewTimingCallback"
    invoke-virtual {v3, v0}, Ljava/lang/ClassLoader;->loadClass(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/Class;->newInstance()Ljava/lang/Object;
    move-result-object v4
    const-string v0, "observationRecord"
    invoke-static {v0, v1, v2, v3, v4}, Lacceptance/admin/AdminUi;->copyField(Ljava/lang/String;Ljava/lang/Class;Ljava/lang/Object;Ljava/lang/Class;Ljava/lang/Object;)V
    const-string v0, "documentEpoch"
    invoke-static {v0, v1, v2, v3, v4}, Lacceptance/admin/AdminUi;->copyField(Ljava/lang/String;Ljava/lang/Class;Ljava/lang/Object;Ljava/lang/Class;Ljava/lang/Object;)V
    check-cast v4, Landroid/webkit/ValueCallback;
    return-object v4
.end method
