.class public final Lacceptance/admin/AdminInstrumentation;
.super Landroid/app/Instrumentation;

.field public volatile activity:Landroid/app/Activity;
.field public volatile value:Ljava/lang/String;
.field public volatile uiFailure:Ljava/lang/String;
.field public webX:I
.field public webY:I
.field public webScale:F
.field public volatile pauseCount:I
.field public volatile resumeCount:I
.field public volatile diagnosticDone:I
.field public staleDiagnostic:Landroid/webkit/ValueCallback;
.field public diagnosticWeb:Landroid/webkit/WebView;
.field private arguments:Landroid/os/Bundle;
.field private firstUsefulMs:J
.field private firstActionMs:J
.field private publicState:I

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .locals 0
    iput-object p1, p0, Lacceptance/admin/AdminInstrumentation;->arguments:Landroid/os/Bundle;
    invoke-super {p0, p1}, Landroid/app/Instrumentation;->onCreate(Landroid/os/Bundle;)V
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method

.method public callActivityOnResume(Landroid/app/Activity;)V
    .locals 1
    invoke-super {p0, p1}, Landroid/app/Instrumentation;->callActivityOnResume(Landroid/app/Activity;)V
    iput-object p1, p0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    iget v0, p0, Lacceptance/admin/AdminInstrumentation;->resumeCount:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lacceptance/admin/AdminInstrumentation;->resumeCount:I
    return-void
.end method

.method public callActivityOnPause(Landroid/app/Activity;)V
    .locals 1
    invoke-super {p0, p1}, Landroid/app/Instrumentation;->callActivityOnPause(Landroid/app/Activity;)V
    iget-object v0, p0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    if-ne p1, v0, :done
    iget v0, p0, Lacceptance/admin/AdminInstrumentation;->pauseCount:I
    add-int/lit8 v0, v0, 1
    iput v0, p0, Lacceptance/admin/AdminInstrumentation;->pauseCount:I
  :done
    return-void
.end method

.method private static require(ZLjava/lang/String;)V
    .locals 1
    if-nez p0, :pass
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :pass
    return-void
.end method

.method private ui(ILjava/lang/String;)V
    .locals 2
    const/4 v0, 0
    iput-object v0, p0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    new-instance v0, Lacceptance/admin/AdminUi;
    invoke-direct {v0, p0, p1, p2}, Lacceptance/admin/AdminUi;-><init>(Lacceptance/admin/AdminInstrumentation;ILjava/lang/String;)V
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-object v1, p0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    if-eqz v1, :pass
    const/4 v0, 0
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :pass
    return-void
.end method

.method private eval(Ljava/lang/String;)Ljava/lang/String;
    .locals 5
    const/4 v0, 0
    iput-object v0, p0, Lacceptance/admin/AdminInstrumentation;->value:Ljava/lang/String;
    const/4 v0, 1
    invoke-direct {p0, v0, p1}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
    const/16 v1, 100
  :wait
    iget-object v0, p0, Lacceptance/admin/AdminInstrumentation;->value:Ljava/lang/String;
    if-nez v0, :received
    const-wide/16 v2, 50
    invoke-static {v2, v3}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v1, v1, -1
    if-gtz v1, :wait
    const/4 v0, 0
    const-string v1, "FAIL independent page observation timeout"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :received
    return-object v0
.end method

.method private await(Ljava/lang/String;Ljava/lang/String;)V
    .locals 5
    const/16 v0, 300
  :again
    invoke-direct {p0, p1}, Lacceptance/admin/AdminInstrumentation;->eval(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    const-string v2, "true"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :pass
    const-wide/16 v2, 200
    invoke-static {v2, v3}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -1
    if-gtz v0, :again
    const/4 v0, 0
    invoke-static {v0, p2}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :pass
    return-void
.end method

.method private tap(FF)V
    .locals 10
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v0
    move-wide v2, v0
    const/4 v4, 0
    move v5, p1
    move v6, p2
    const/4 v7, 0
    invoke-static/range {v0 .. v7}, Landroid/view/MotionEvent;->obtain(JJIFFI)Landroid/view/MotionEvent;
    move-result-object v8
    invoke-virtual {p0, v8}, Landroid/app/Instrumentation;->sendPointerSync(Landroid/view/MotionEvent;)V
    invoke-virtual {v8}, Landroid/view/MotionEvent;->recycle()V
    const-wide/16 v8, 60
    invoke-static {v8, v9}, Landroid/os/SystemClock;->sleep(J)V
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    const/4 v4, 1
    invoke-static/range {v0 .. v7}, Landroid/view/MotionEvent;->obtain(JJIFFI)Landroid/view/MotionEvent;
    move-result-object v8
    invoke-virtual {p0, v8}, Landroid/app/Instrumentation;->sendPointerSync(Landroid/view/MotionEvent;)V
    invoke-virtual {v8}, Landroid/view/MotionEvent;->recycle()V
    return-void
.end method

.method private press(Ljava/lang/String;)V
    .locals 7
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "(function(){var e=document.getElementById('"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "');if(!e||e.disabled||e.hidden)return 'unusable';e.scrollIntoView({block:'center'});var r=e.getBoundingClientRect();if(r.width<=0||r.height<=0)return 'unusable';return (r.left+r.width/2)+','+(r.top+r.height/2);})()"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->eval(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    new-instance v1, Lorg/json/JSONTokener;
    invoke-direct {v1, v0}, Lorg/json/JSONTokener;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Lorg/json/JSONTokener;->nextValue()Ljava/lang/Object;
    move-result-object v0
    instance-of v1, v0, Ljava/lang/String;
    const-string v2, "FAIL no usable page control"
    invoke-static {v1, v2}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    check-cast v0, Ljava/lang/String;
    const-string v1, "unusable"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    xor-int/lit8 v1, v1, 1
    invoke-static {v1, v2}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    const-string v1, ","
    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v0
    const/4 v1, 0
    aget-object v1, v0, v1
    invoke-static {v1}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F
    move-result v1
    const/4 v2, 1
    aget-object v0, v0, v2
    invoke-static {v0}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F
    move-result v2
    iget v3, p0, Lacceptance/admin/AdminInstrumentation;->webScale:F
    mul-float/2addr v1, v3
    mul-float/2addr v2, v3
    iget v4, p0, Lacceptance/admin/AdminInstrumentation;->webX:I
    int-to-float v4, v4
    add-float/2addr v1, v4
    iget v4, p0, Lacceptance/admin/AdminInstrumentation;->webY:I
    int-to-float v4, v4
    add-float/2addr v2, v4
    invoke-direct {p0, v1, v2}, Lacceptance/admin/AdminInstrumentation;->tap(FF)V
    return-void
.end method

.method private static checkedSelector(Ljava/lang/String;)[Ljava/lang/String;
    .locals 2
    const-string v0, "IBLV1\n[A-Za-z0-9_-]{1,64}\n[A-Za-z0-9_-]{1,64}\n"
    invoke-virtual {p0, v0}, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result v0
    const-string v1, "FAIL malformed protected task selector"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    const-string v0, "\n"
    invoke-virtual {p0, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method

.method private static requireSelectedRecord([Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "schema\tib-long-view-task-v1\ntask_id\t"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const/4 v1, 1
    aget-object v1, p0, v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "\ntab_id\t"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const/4 v1, 2
    aget-object v1, p0, v1
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, "\n"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    const-string v1, "FAIL selected protected record identity mismatch"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
.end method

.method private static selectorSelfTest()V
    .locals 5
    const-string v0, "IBLV1\ntask_good\ntab_good\n"
    invoke-static {v0}, Lacceptance/admin/AdminInstrumentation;->checkedSelector(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v1
    const-string v2, "schema\tib-long-view-task-v1\ntask_id\ttask_good\ntab_id\ttab_good\n"
    invoke-static {v1, v2}, Lacceptance/admin/AdminInstrumentation;->requireSelectedRecord([Ljava/lang/String;Ljava/lang/String;)V
  :bad_magic_start
    const-string v3, "IBLV2\ntask_good\ntab_good\n"
    invoke-static {v3}, Lacceptance/admin/AdminInstrumentation;->checkedSelector(Ljava/lang/String;)[Ljava/lang/String;
  :bad_magic_end
    .catch Ljava/lang/AssertionError; {:bad_magic_start .. :bad_magic_end} :bad_magic_rejected
    const/4 v3, 0
    const-string v4, "FAIL malformed selector control accepted"
    invoke-static {v3, v4}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    goto :bad_magic_done
  :bad_magic_rejected
    move-exception v3
    invoke-virtual {v3}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v3
    const-string v4, "FAIL malformed protected task selector"
    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    const-string v4, "FAIL malformed selector control failed for wrong reason"
    invoke-static {v3, v4}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :bad_magic_done
  :wrong_tab_start
    const-string v2, "schema\tib-long-view-task-v1\ntask_id\ttask_good\ntab_id\ttab_other\n"
    invoke-static {v1, v2}, Lacceptance/admin/AdminInstrumentation;->requireSelectedRecord([Ljava/lang/String;Ljava/lang/String;)V
  :wrong_tab_end
    .catch Ljava/lang/AssertionError; {:wrong_tab_start .. :wrong_tab_end} :wrong_tab_rejected
    const/4 v3, 0
    const-string v4, "FAIL mismatched selected tab control accepted"
    invoke-static {v3, v4}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
  :wrong_tab_rejected
    move-exception v3
    invoke-virtual {v3}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v3
    const-string v4, "FAIL selected protected record identity mismatch"
    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    const-string v4, "FAIL selected tab control failed for wrong reason"
    invoke-static {v3, v4}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
.end method

.method private snapshot(Ljava/lang/String;)V
    .locals 9
    invoke-static {}, Lacceptance/admin/AdminInstrumentation;->selectorSelfTest()V
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v1
    new-instance v2, Ljava/io/File;
    const-string v3, "state/longview-current"
    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->toPath()Ljava/nio/file/Path;
    move-result-object v2
    invoke-static {v2}, Ljava/nio/file/Files;->readAllBytes(Ljava/nio/file/Path;)[B
    move-result-object v2
    new-instance v3, Ljava/lang/String;
    const-string v4, "UTF-8"
    invoke-direct {v3, v2, v4}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    invoke-static {v3}, Lacceptance/admin/AdminInstrumentation;->checkedSelector(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v8
    const/4 v3, 1
    aget-object v5, v8, v3
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "state/tasks/"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v4, "/task.txt"
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->toPath()Ljava/nio/file/Path;
    move-result-object v1
    invoke-static {v1}, Ljava/nio/file/Files;->readAllBytes(Ljava/nio/file/Path;)[B
    move-result-object v1
    new-instance v3, Ljava/lang/String;
    const-string v4, "UTF-8"
    invoke-direct {v3, v1, v4}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    invoke-static {v8, v3}, Lacceptance/admin/AdminInstrumentation;->requireSelectedRecord([Ljava/lang/String;Ljava/lang/String;)V
    invoke-virtual {v0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v0
    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->toPath()Ljava/nio/file/Path;
    move-result-object v2
    const/4 v0, 0
    new-array v0, v0, [Ljava/nio/file/OpenOption;
    invoke-static {v2, v1, v0}, Ljava/nio/file/Files;->write(Ljava/nio/file/Path;[B[Ljava/nio/file/OpenOption;)Ljava/nio/file/Path;
    return-void
.end method

.method private launch()V
    .locals 3
    new-instance v0, Landroid/content/Intent;
    const-string v1, "android.intent.action.MAIN"
    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v1, "org.isomorphisms.ib.prepaint"
    const-string v2, "Idric.Generated"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v0
    iput-object v0, p0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    return-void
.end method

.method private appSwitch()V
    .locals 8
    iget-object v0, p0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    iget v4, p0, Lacceptance/admin/AdminInstrumentation;->resumeCount:I
    iget v5, p0, Lacceptance/admin/AdminInstrumentation;->pauseCount:I
    const/4 v1, 3
    invoke-virtual {p0, v1}, Landroid/app/Instrumentation;->sendKeyDownUpSync(I)V
    const/16 v6, 100
  :wait_pause
    iget v7, p0, Lacceptance/admin/AdminInstrumentation;->pauseCount:I
    if-gt v7, v5, :paused
    const-wide/16 v1, 50
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v6, v6, -1
    if-gtz v6, :wait_pause
    const/4 v1, 0
    const-string v2, "FAIL app switch never paused the target Activity"
    invoke-static {v1, v2}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :paused
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.intent.action.MAIN"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    const-string v2, "org.isomorphisms.ib.prepaint"
    const-string v3, "Idric.Generated"
    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const v2, 0x10020000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v2
    invoke-virtual {v2, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V
    const/16 v6, 100
  :wait_resume
    iget v7, p0, Lacceptance/admin/AdminInstrumentation;->resumeCount:I
    if-gt v7, v4, :resumed
    const-wide/16 v1, 50
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v6, v6, -1
    if-gtz v6, :wait_resume
    const/4 v1, 0
    const-string v2, "FAIL app switch never resumed the target Activity"
    invoke-static {v1, v2}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :resumed
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    iget-object v1, p0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    if-ne v0, v1, :changed
    return-void
  :changed
    const/4 v0, 0
    const-string v1, "FAIL app switch replaced live fixture Activity"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
.end method

.method private recreate()V
    .locals 4
    iget-object v0, p0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    const/4 v1, 4
    const-string v2, ""
    invoke-direct {p0, v1, v2}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
    const/16 v3, 200
  :wait
    iget-object v1, p0, Lacceptance/admin/AdminInstrumentation;->activity:Landroid/app/Activity;
    if-ne v1, v0, :changed
    const-wide/16 v1, 50
    invoke-static {v1, v2}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v3, v3, -1
    if-gtz v3, :wait
    const/4 v0, 0
    const-string v1, "FAIL Activity recreation did not replace Activity"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :changed
    invoke-virtual {p0}, Landroid/app/Instrumentation;->waitForIdleSync()V
    return-void
.end method

.method private screenshot(Ljava/lang/String;)V
    .locals 7
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/UiAutomation;->takeScreenshot()Landroid/graphics/Bitmap;
    move-result-object v0
    if-eqz v0, :failed
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v1
    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v1, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v3, Ljava/io/FileOutputStream;
    invoke-direct {v3, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    sget-object v4, Landroid/graphics/Bitmap$CompressFormat;->PNG:Landroid/graphics/Bitmap$CompressFormat;
    const/16 v5, 100
    invoke-virtual {v0, v4, v5, v3}, Landroid/graphics/Bitmap;->compress(Landroid/graphics/Bitmap$CompressFormat;ILjava/io/OutputStream;)Z
    move-result v6
    invoke-virtual {v3}, Ljava/io/OutputStream;->close()V
    invoke-virtual {v0}, Landroid/graphics/Bitmap;->recycle()V
    const-string v0, "FAIL live source-bound screenshot encoding"
    invoke-static {v6, v0}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
  :failed
    const/4 v0, 0
    const-string v1, "FAIL live source-bound screenshot unavailable"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
.end method

.method private diagnostic(I)V
    .locals 5
    const/4 v0, 0
    iput v0, p0, Lacceptance/admin/AdminInstrumentation;->diagnosticDone:I
    const-string v0, ""
    invoke-direct {p0, p1, v0}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
    const/16 v0, 100
  :wait
    iget v1, p0, Lacceptance/admin/AdminInstrumentation;->diagnosticDone:I
    if-nez v1, :done
    const-wide/16 v2, 50
    invoke-static {v2, v3}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v0, v0, -1
    if-gtz v0, :wait
    const/4 v0, 0
    const-string v1, "FAIL real diagnostic callback was not exercised"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :done
    iget-object v0, p0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
    if-eqz v0, :pass
    const/4 v1, 0
    invoke-static {v1, v0}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
  :pass
    return-void
.end method

.method private exercise()V
    .locals 7
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v4
    const/4 v0, 0
    const-string v1, "http://127.0.0.1:18493/"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
    const-string v0, "!!document.getElementById('confirm-control')&&!document.getElementById('confirm-control').disabled"
    const-string v1, "FAIL fixture never exposed useful control"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v2
    sub-long/2addr v2, v4
    iput-wide v2, p0, Lacceptance/admin/AdminInstrumentation;->firstUsefulMs:J
    const-string v0, "confirm-control"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->press(Ljava/lang/String;)V
    const-string v0, "!!document.getElementById('state')&&document.getElementById('state').dataset.confirmed==='yes'"
    const-string v1, "FAIL touched control lacked server confirmation"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v2
    sub-long/2addr v2, v4
    iput-wide v2, p0, Lacceptance/admin/AdminInstrumentation;->firstActionMs:J
    const-string v0, "admin-first-action.png"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->screenshot(Ljava/lang/String;)V
    const-string v0, "document.readyState==='complete'"
    const-string v1, "FAIL initial fixture did not finish its document"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v0, 6
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->diagnostic(I)V
    const-string v0, "verify"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->press(Ljava/lang/String;)V
    const-string v0, "!!document.getElementById('approve-verification')"
    const-string v1, "FAIL mock verification navigation"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    invoke-direct {p0}, Lacceptance/admin/AdminInstrumentation;->appSwitch()V
    const-string v0, "approve-verification"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->press(Ljava/lang/String;)V
    const-string v0, "!!document.getElementById('create-value')&&!document.getElementById('create-value').disabled"
    const-string v1, "FAIL verification return control"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "create-value"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->press(Ljava/lang/String;)V
    const-string v0, "!!document.getElementById('one-time')&&/^IB_SYNTHETIC_ONLY_[0-9a-f]{32}\\n$/.test(document.getElementById('one-time').textContent)"
    const-string v1, "FAIL usable verified synthetic result"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v0, 5
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->diagnostic(I)V
    const-string v0, "forget-value"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->press(Ljava/lang/String;)V
    const-string v0, "document.getElementById('one-time').textContent===''&&document.getElementById('forget-value').hidden"
    const-string v1, "FAIL synthetic value remained visible"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "(function(){window.__adminPreviousDocument=true;location.assign('/');return true;})()"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->eval(Ljava/lang/String;)Ljava/lang/String;
    const-string v0, "!window.__adminPreviousDocument&&!!document.getElementById('confirm-control')&&!document.getElementById('confirm-control').disabled"
    const-string v1, "FAIL ordinary same-renderer document navigation"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const/16 v0, 9
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->diagnostic(I)V
    const-string v0, "admin-before-lifecycle.task"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->snapshot(Ljava/lang/String;)V
    const/16 v0, 10
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->diagnostic(I)V
    const-string v0, "admin-after-lifecycle.task"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->snapshot(Ljava/lang/String;)V
    const/16 v0, 8
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->diagnostic(I)V
    const-string v0, "ambiguous"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->press(Ljava/lang/String;)V
    const-string v0, "document.getElementById('mutation-state').textContent==='Remote result uncertain; do not replay'"
    const-string v1, "FAIL ambiguous response was reported complete"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "(function(){var e=document.getElementById('unapproved');e.value='IB_UNAPPROVED_INPUT';e.dispatchEvent(new Event('input',{bubbles:true}));return true;})()"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->eval(Ljava/lang/String;)Ljava/lang/String;
    const-string v0, "!!document.getElementById('unapproved')&&document.getElementById('unapproved').value==='IB_UNAPPROVED_INPUT'"
    const-string v1, "FAIL unapproved form input was never present"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "admin-before-renderer.task"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->snapshot(Ljava/lang/String;)V
    const/4 v0, 3
    const-string v1, ""
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
    const-string v0, "document.readyState==='complete'&&!!document.getElementById('unapproved')&&document.getElementById('unapproved').value===''&&document.getElementById('one-time').textContent===''&&!document.getElementById('confirm-control').disabled"
    const-string v1, "FAIL renderer recovery did not reconstruct ordinary root"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "admin-after-renderer.task"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->snapshot(Ljava/lang/String;)V
    const/4 v0, 7
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->diagnostic(I)V
    invoke-direct {p0}, Lacceptance/admin/AdminInstrumentation;->recreate()V
    const-string v0, "!!document.getElementById('unapproved')&&document.getElementById('unapproved').value===''&&document.getElementById('one-time').textContent===''&&!document.getElementById('confirm-control').disabled"
    const-string v1, "FAIL Activity recreation did not reconstruct ordinary root"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "admin-after-activity.task"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->snapshot(Ljava/lang/String;)V
    const-string v0, "admin-after-activity.png"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->screenshot(Ljava/lang/String;)V
    return-void
.end method

.method private fake()V
    .locals 4
    const/4 v0, 0
    const-string v1, "http://127.0.0.1:18493/fake-interactive"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
    const-string v0, "location.origin==='http://127.0.0.1:18493'&&location.pathname==='/fake-interactive'&&document.title==='False readiness control'&&document.documentElement.dataset.ready==='interactive'&&!!document.getElementById('confirm-control')&&document.getElementById('confirm-control').disabled&&document.getElementById('state').dataset.confirmed==='no'"
    const-string v1, "FAIL missing false-readiness negative fixture"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
  :try_start
    const-string v0, "confirm-control"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->press(Ljava/lang/String;)V
  :try_end
    .catch Ljava/lang/AssertionError; {:try_start .. :try_end} :rejected
    const/4 v0, 0
    const-string v1, "FAIL false interactive marker accepted as usable"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
  :rejected
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v0
    const-string v1, "FAIL no usable page control"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    const-string v1, "FAIL negative fixture failed outside usability assertion"
    invoke-static {v0, v1}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    return-void
.end method

.method private resume()V
    .locals 2
    const/4 v0, 2
    const-string v1, ""
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
    const-string v0, "!!document.getElementById('unapproved')&&document.getElementById('unapproved').value===''&&document.getElementById('one-time').textContent===''&&!document.getElementById('confirm-control').disabled"
    const-string v1, "FAIL host recovery did not reconstruct ordinary root"
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->await(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "admin-after-host.task"
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->snapshot(Ljava/lang/String;)V
    return-void
.end method

.method private publicPage(Ljava/lang/String;)I
    .locals 8
    const-string v0, "public-search"
    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :miwam
    const-string v1, "https://duckduckgo.com/?q=Michigan+unemployment+insurance&ia=web"
    const-string v3, "(function(){if(!document.body)return 0;var t=document.body.innerText;if(/captcha|verify you are human|access denied|too many requests|unusual traffic|bots use/i.test(t))return -1;if(location.hostname!=='duckduckgo.com'||document.readyState!=='complete')return 0;return Array.from(document.querySelectorAll('a[data-testid=\"result-title-a\"],a.result__a,[data-testid=\"result\"] a[href]')).some(function(e){var r=e.getBoundingClientRect(),s=getComputedStyle(e);return !e.disabled&&r.width>0&&r.height>0&&r.bottom>0&&r.top<innerHeight&&s.display!=='none'&&s.visibility==='visible';})?1:0;})()"
    goto :open
  :miwam
    const-string v1, "https://miwam.unemployment.state.mi.us/ClmMiWAM/_/"
    const-string v3, "(function(){if(!document.body)return 0;var t=document.body.innerText;if(/captcha|verify you are human|access denied|too many requests|unusual traffic/i.test(t))return -1;if(location.hostname!=='miwam.unemployment.state.mi.us'||document.readyState!=='complete'||!/miwam|michigan web account manager/i.test(t))return 0;return Array.from(document.querySelectorAll('input,button,a[href]')).some(function(e){var r=e.getBoundingClientRect(),s=getComputedStyle(e),n=[e.textContent,e.name,e.id,e.getAttribute('aria-label')].join(' ');return !e.disabled&&/log\\s*in|sign\\s*in|claimant|username/i.test(n)&&r.width>0&&r.height>0&&r.bottom>0&&r.top<innerHeight&&s.display!=='none'&&s.visibility==='visible';})?1:0;})()"
  :open
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v4
    const/4 v0, 0
    invoke-direct {p0, v0, v1}, Lacceptance/admin/AdminInstrumentation;->ui(ILjava/lang/String;)V
  :poll
    invoke-direct {p0, v3}, Lacceptance/admin/AdminInstrumentation;->eval(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "1"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :ready
    const-string v1, "-1"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :blocked
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v0
    sub-long/2addr v0, v4
    const-wide/32 v6, 120000
    cmp-long v0, v0, v6
    if-gez v0, :unknown
    const-wide/16 v0, 200
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    goto :poll
  :ready
    const/4 v2, 1
    goto :capture
  :blocked
    const/4 v2, -1
    goto :capture
  :unknown
    const/4 v2, 0
  :capture
    iput v2, p0, Lacceptance/admin/AdminInstrumentation;->publicState:I
    const/4 v0, 1
    if-ne v2, v0, :capture_image
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v0
    sub-long/2addr v0, v4
    iput-wide v0, p0, Lacceptance/admin/AdminInstrumentation;->firstUsefulMs:J
  :capture_image
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v1, ".png"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->screenshot(Ljava/lang/String;)V
    return v2
.end method

.method public onStart()V
    .locals 7
  :try_start
    invoke-direct {p0}, Lacceptance/admin/AdminInstrumentation;->launch()V
    iget-object v0, p0, Lacceptance/admin/AdminInstrumentation;->arguments:Landroid/os/Bundle;
    const-string v1, "phase"
    invoke-virtual {v0, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "public-search"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :public_page
    const-string v1, "public-miwam"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :public_page
    const-string v1, "fake"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :fake
    const-string v1, "resume"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :resume
    const-string v1, "exercise"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    const-string v2, "FAIL unknown independent admin phase"
    invoke-static {v1, v2}, Lacceptance/admin/AdminInstrumentation;->require(ZLjava/lang/String;)V
    invoke-direct {p0}, Lacceptance/admin/AdminInstrumentation;->exercise()V
    const-string v4, "PASS actual admin touch verification app-switch result and renderer recovery"
    goto :pass
  :fake
    invoke-direct {p0}, Lacceptance/admin/AdminInstrumentation;->fake()V
    const-string v4, "PASS false interactive marker rejected by usable-control assertion"
    goto :pass
  :resume
    invoke-direct {p0}, Lacceptance/admin/AdminInstrumentation;->resume()V
    const-string v4, "PASS actual admin host recovery requires ordinary root reconstruction"
    goto :pass
  :public_page
    invoke-direct {p0, v0}, Lacceptance/admin/AdminInstrumentation;->publicPage(Ljava/lang/String;)I
    move-result v0
    const/4 v1, 1
    const-string v4, "PASS public page exposed expected visible controls"
    if-eq v0, v1, :pass
    const-string v4, "UNKNOWN public page did not expose expected controls before deadline"
    if-eqz v0, :public_failed
    const-string v4, "BLOCKED public site presented a verification or denial page"
  :public_failed
    const/4 v5, 0
    goto :finish
  :pass
    const/4 v5, -1
    goto :finish
  :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :failed
  :failed
    move-exception v0
    instance-of v1, v0, Ljava/lang/AssertionError;
    if-eqz v1, :unexpected
    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;
    move-result-object v4
    goto :failure_result
  :unexpected
    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/Class;->getName()Ljava/lang/String;
    move-result-object v4
  :failure_result
    const/4 v5, 0
  :finish
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    invoke-virtual {v0, v1, v4}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const-string v1, "first_action_ms"
    iget-wide v2, p0, Lacceptance/admin/AdminInstrumentation;->firstActionMs:J
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V
    const-string v1, "first_useful_ms"
    iget-wide v2, p0, Lacceptance/admin/AdminInstrumentation;->firstUsefulMs:J
    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V
    const-string v1, "observed_host_pid"
    invoke-static {}, Landroid/os/Process;->myPid()I
    move-result v2
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    const-string v1, "public_state"
    iget v2, p0, Lacceptance/admin/AdminInstrumentation;->publicState:I
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    invoke-virtual {p0, v5, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method
