.class public final Lacceptance/presentation/FastChatIme;
.super Landroid/app/Instrumentation;
.field private broken:Z
.method public onCreate(Landroid/os/Bundle;)V
    .locals 2
    const-string v0, "broken"
    invoke-virtual {p1, v0}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "adjust-nothing"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    iput-boolean v0, p0, Lacceptance/presentation/FastChatIme;->broken:Z
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method
.method private static fail(Ljava/lang/String;)V
    .locals 1
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method
.method private assertNoSubmission()V
    .locals 4
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "fc-m4-ime-native-ui/history.events"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->isFile()Z
    move-result v0
    if-eqz v0, :fail
    invoke-virtual {v1}, Ljava/io/File;->length()J
    move-result-wide v0
    const-wide/16 v2, 0
    cmp-long v0, v0, v2
    if-eqz v0, :done
  :fail
    const-string v0, "FAIL IME exercise changed the empty durable request journal"
    invoke-static {v0}, Lacceptance/presentation/FastChatIme;->fail(Ljava/lang/String;)V
  :done
    return-void
.end method
.method private keyboardTop()I
    .locals 4
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/UiAutomation;->getWindows()Ljava/util/List;
    move-result-object v0
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v0
  :next
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z
    move-result v1
    if-eqz v1, :none
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/view/accessibility/AccessibilityWindowInfo;
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityWindowInfo;->getType()I
    move-result v2
    const/4 v3, 2
    if-ne v2, v3, :next
    new-instance v2, Landroid/graphics/Rect;
    invoke-direct {v2}, Landroid/graphics/Rect;-><init>()V
    invoke-virtual {v1, v2}, Landroid/view/accessibility/AccessibilityWindowInfo;->getBoundsInScreen(Landroid/graphics/Rect;)V
    iget v0, v2, Landroid/graphics/Rect;->top:I
    return v0
  :none
    const/4 v0, -1
    return v0
.end method
.method public onStart()V
    .locals 10
  :begin
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/UiAutomation;->getServiceInfo()Landroid/accessibilityservice/AccessibilityServiceInfo;
    move-result-object v1
    iget v2, v1, Landroid/accessibilityservice/AccessibilityServiceInfo;->flags:I
    or-int/lit8 v2, v2, 0x40
    iput v2, v1, Landroid/accessibilityservice/AccessibilityServiceInfo;->flags:I
    invoke-virtual {v0, v1}, Landroid/app/UiAutomation;->setServiceInfo(Landroid/accessibilityservice/AccessibilityServiceInfo;)V
    new-instance v0, Landroid/content/Intent;
    invoke-direct {v0}, Landroid/content/Intent;-><init>()V
    const-string v1, "org.isomorphisms.fastchat.diskstreaming.arena"
    const-string v2, "android.app.NativeActivity"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    const-string v1, "fastchat_acceptance_store"
    const-string v2, "fc-m4-ime-native-ui"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v7
    new-instance v6, Lacceptance/presentation/ImeTask;
    invoke-direct {v6, v7}, Lacceptance/presentation/ImeTask;-><init>(Landroid/app/Activity;)V
    iget-boolean v0, p0, Lacceptance/presentation/FastChatIme;->broken:Z
    iput-boolean v0, v6, Lacceptance/presentation/ImeTask;->broken:Z
    const/16 v5, 100
  :find
    invoke-virtual {p0, v6}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-object v0, v6, Lacceptance/presentation/ImeTask;->editor:Landroid/widget/EditText;
    if-eqz v0, :find_wait
    iget v0, v6, Lacceptance/presentation/ImeTask;->height:I
    if-gtz v0, :ready
  :find_wait
    const-wide/16 v0, 0x32
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v5, v5, -1
    if-gtz v5, :find
    const-string v0, "FAIL actual IME composer discovery"
    invoke-static {v0}, Lacceptance/presentation/FastChatIme;->fail(Ljava/lang/String;)V
  :ready
    invoke-direct {p0}, Lacceptance/presentation/FastChatIme;->assertNoSubmission()V
    iget v8, v6, Lacceptance/presentation/ImeTask;->height:I
    const/4 v0, 1
    iput v0, v6, Lacceptance/presentation/ImeTask;->stage:I
    invoke-virtual {p0, v6}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    const/4 v0, 2
    iput v0, v6, Lacceptance/presentation/ImeTask;->stage:I
    const/16 v5, 100
  :keyboard
    const-wide/16 v0, 0x32
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    invoke-direct {p0}, Lacceptance/presentation/FastChatIme;->keyboardTop()I
    move-result v9
    if-gtz v9, :shown
    add-int/lit8 v5, v5, -1
    if-gtz v5, :keyboard
    const-string v0, "FAIL actual visible IME window"
    invoke-static {v0}, Lacceptance/presentation/FastChatIme;->fail(Ljava/lang/String;)V
  :shown
    const-wide/16 v0, 0x1f4
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    invoke-virtual {p0, v6}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget v0, v6, Lacceptance/presentation/ImeTask;->height:I
    sub-int v0, v8, v0
    const/16 v1, 80
    if-le v0, v1, :resize_bad
    iget v0, v6, Lacceptance/presentation/ImeTask;->bottom:I
    if-gt v0, v9, :resize_bad
    iget-boolean v0, v6, Lacceptance/presentation/ImeTask;->focused:Z
    if-nez v0, :type
  :resize_bad
    const-string v0, "FAIL keyboard resize keeps composer above actual IME"
    invoke-static {v0}, Lacceptance/presentation/FastChatIme;->fail(Ljava/lang/String;)V
  :type
    const-string v0, "IME"
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->sendStringSync(Ljava/lang/String;)V
    const/16 v0, 66
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->sendKeyDownUpSync(I)V
    const-string v0, "next"
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->sendStringSync(Ljava/lang/String;)V
    invoke-virtual {p0, v6}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-object v0, v6, Lacceptance/presentation/ImeTask;->text:Ljava/lang/String;
    const-string v1, "Türkçe é שלום\nIME\nnext"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :back
    const-string v0, "FAIL real input dispatch preserves multiline Unicode composer"
    invoke-static {v0}, Lacceptance/presentation/FastChatIme;->fail(Ljava/lang/String;)V
  :back
    const/4 v0, 4
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->sendKeyDownUpSync(I)V
    const-wide/16 v0, 0x1f4
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    invoke-virtual {p0, v6}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    invoke-direct {p0}, Lacceptance/presentation/FastChatIme;->keyboardTop()I
    move-result v0
    if-gtz v0, :back_bad
    invoke-virtual {v7}, Landroid/app/Activity;->isFinishing()Z
    move-result v0
    if-nez v0, :back_bad
    iget v0, v6, Lacceptance/presentation/ImeTask;->height:I
    if-ge v0, v8, :pass
  :back_bad
    const-string v0, "FAIL Back dismisses IME and restores the live conversation"
    invoke-static {v0}, Lacceptance/presentation/FastChatIme;->fail(Ljava/lang/String;)V
  :pass
    invoke-direct {p0}, Lacceptance/presentation/FastChatIme;->assertNoSubmission()V
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    const-string v2, "PASS real IME resize focus input dispatch multiline Unicode and Back; no request submitted"
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, -1
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :failure
  :failure
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    new-instance v1, Landroid/os/Bundle;
    invoke-direct {v1}, Landroid/os/Bundle;-><init>()V
    const-string v2, "stream"
    invoke-virtual {v1, v2, v0}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v2, 0
    invoke-virtual {p0, v2, v1}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method
