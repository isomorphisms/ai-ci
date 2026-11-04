.class public final Lacceptance/presentation/FastChatUi;
.super Landroid/app/Instrumentation;
.field private timeline:Z

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Instrumentation;-><init>()V
    return-void
.end method
.method public onCreate(Landroid/os/Bundle;)V
    .locals 2
    if-eqz p1, :start
    const-string v0, "timeline"
    invoke-virtual {p1, v0}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "required"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    iput-boolean v0, p0, Lacceptance/presentation/FastChatUi;->timeline:Z
  :start
    invoke-virtual {p0}, Landroid/app/Instrumentation;->start()V
    return-void
.end method
.method private static fail(Ljava/lang/String;)V
    .locals 1
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p0}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method
.method private node(Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    .locals 8
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    const/16 v1, 0xc8
  :retry
    invoke-virtual {v0}, Landroid/app/UiAutomation;->getRootInActiveWindow()Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v2
    if-eqz v2, :wait
    invoke-virtual {v2, p1}, Landroid/view/accessibility/AccessibilityNodeInfo;->findAccessibilityNodeInfosByText(Ljava/lang/String;)Ljava/util/List;
    move-result-object v3
    const/4 v4, 0
  :next
    invoke-interface {v3}, Ljava/util/List;->size()I
    move-result v5
    if-ge v4, v5, :wait
    invoke-interface {v3, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Landroid/view/accessibility/AccessibilityNodeInfo;
    invoke-virtual {v5}, Landroid/view/accessibility/AccessibilityNodeInfo;->getContentDescription()Ljava/lang/CharSequence;
    move-result-object v6
    if-eqz v6, :text
    invoke-interface {v6}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v6, p1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v6
    if-nez v6, :found
  :text
    invoke-virtual {v5}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v6
    if-eqz v6, :later
    invoke-interface {v6}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {p1, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v6
    if-nez v6, :found
  :later
    add-int/lit8 v4, v4, 1
    goto :next
  :wait
    const-wide/16 v6, 0x64
    invoke-static {v6, v7}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v1, v1, -1
    if-gtz v1, :retry
    invoke-static {p1}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
    const/4 v5, 0
  :found
    return-object v5
.end method
.method private click(Ljava/lang/String;)V
    .locals 3
    invoke-direct {p0, p1}, Lacceptance/presentation/FastChatUi;->node(Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getClassName()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "android.widget.Button"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :fail
    const/16 v1, 0x10
    invoke-virtual {v0, v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    move-result v1
    if-nez v1, :ok
  :fail
    const-string v0, "FAIL actual framework Button action"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :ok
    return-void
.end method
.method private text(Ljava/lang/String;)Ljava/lang/String;
    .locals 1
    invoke-direct {p0, p1}, Lacceptance/presentation/FastChatUi;->node(Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method
.method private static logProcessMemory()V
    .locals 5
  :read_begin
    new-instance v0, Ljava/io/FileReader;
    const-string v1, "/proc/self/status"
    invoke-direct {v0, v1}, Ljava/io/FileReader;-><init>(Ljava/lang/String;)V
    new-instance v1, Ljava/io/BufferedReader;
    invoke-direct {v1, v0}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V
  :line
    invoke-virtual {v1}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v2
    if-eqz v2, :close
    const-string v3, "VmHWM:"
    invoke-virtual {v2, v3}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    if-nez v3, :log
    const-string v3, "VmRSS:"
    invoke-virtual {v2, v3}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    if-eqz v3, :line
  :log
    const-string v3, "NativeUiProcessMemory"
    invoke-static {v3, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    goto :line
  :close
    invoke-virtual {v1}, Ljava/io/BufferedReader;->close()V
    invoke-static {}, Landroid/os/Debug;->getPss()J
    move-result-wide v0
    invoke-static {v0, v1}, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v0
    const-string v1, "NativeUiProcessPssKiB"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    invoke-static {}, Landroid/os/Process;->getElapsedCpuTime()J
    move-result-wide v0
    invoke-static {v0, v1}, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v0
    const-string v1, "NativeUiProcessCpuMs"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
  :read_end
    .catch Ljava/io/IOException; {:read_begin .. :read_end} :unavailable
    return-void
  :unavailable
    move-exception v0
    const-string v1, "NativeUiProcessMemory"
    const-string v2, "NOT_AVAILABLE process status"
    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
.end method
.method public onStart()V
    .locals 12
  :begin
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v8
    new-instance v0, Landroid/content/Intent;
    invoke-direct {v0}, Landroid/content/Intent;-><init>()V
    const-string v1, "org.isomorphisms.fastchat.diskstreaming.arena"
    const-string v2, "android.app.NativeActivity"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const v1, 0x10000000
    invoke-virtual {v0, v1}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    const-string v1, "fastchat_acceptance_store"
    const-string v2, "fc-m4-native-ui"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    const-string v1, "fastchat_acceptance_fixture"
    const-string v2, ":long"
    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->startActivitySync(Landroid/content/Intent;)Landroid/app/Activity;
    move-result-object v7
    const-string v0, "Message, multiline draft"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->node(Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v6
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J
    move-result-wide v10
    sub-long/2addr v10, v8
    invoke-static {v10, v11}, Ljava/lang/Long;->toString(J)Ljava/lang/String;
    move-result-object v0
    const-string v1, "NativeUiLaunchToComposerMs"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    const-wide/16 v0, 0x7d0
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    const-string v0, "Response page position"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    const-string v0, "Next"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->click(Ljava/lang/String;)V
    const-wide/16 v0, 0x1f4
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    const-string v0, "Response page position"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v5
    const-string v4, "Page 2"
    invoke-virtual {v5, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-nez v0, :paged
    const-string v0, "FAIL native paging did not change the stored byte range"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :paged
    const-string v0, "Stop"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->click(Ljava/lang/String;)V
    const-wide/16 v0, 0x3e8
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    const-string v0, "FastChat generation status"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "cancelled"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :stopped
    const-string v0, "FAIL Stop did not cancel the real durable attempt"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :stopped
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE"
    const-string v2, "First line\nTürkçe é שלום\nLast line"
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putCharSequence(Ljava/lang/String;Ljava/lang/CharSequence;)V
    const v1, 0x200000
    invoke-virtual {v6, v1, v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(ILandroid/os/Bundle;)Z
    move-result v0
    if-eqz v0, :editor_failed
    const-string v0, "Message, multiline draft"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :editor_ok
  :editor_failed
    const-string v0, "FAIL multiline combining-mark and RTL composer text"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :editor_ok
    const-string v0, "Assistant response, selectable text"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    const-string v0, "Copy"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->click(Ljava/lang/String;)V
    const-string v0, "clipboard"
    invoke-virtual {v7, v0}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/content/ClipboardManager;
    invoke-virtual {v0}, Landroid/content/ClipboardManager;->getPrimaryClip()Landroid/content/ClipData;
    move-result-object v0
    const/4 v1, 0
    invoke-virtual {v0, v1}, Landroid/content/ClipData;->getItemAt(I)Landroid/content/ClipData$Item;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/ClipData$Item;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v4, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :copied
    const-string v0, "FAIL source-faithful bounded response clipboard"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :copied
    iget-boolean v0, p0, Lacceptance/presentation/FastChatUi;->timeline:Z
    if-eqz v0, :timeline_done
    invoke-direct {p0}, Lacceptance/presentation/FastChatUi;->assertTimeline()V
  :timeline_done
    invoke-static {}, Lacceptance/presentation/FastChatUi;->logProcessMemory()V
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v1, "stream"
    const-string v2, "PASS actual FastChat framework paging Stop multiline Unicode and exact page copy"
    invoke-virtual {v0, v1, v2}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, -1
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :failed
  :failed
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v1
    new-instance v0, Landroid/os/Bundle;
    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V
    const-string v2, "stream"
    invoke-virtual {v0, v2, v1}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v1, 0
    invoke-virtual {p0, v1, v0}, Landroid/app/Instrumentation;->finish(ILandroid/os/Bundle;)V
    return-void
.end method

.method private assertTimeline()V
    .locals 5
    const-string v0, "Send"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->click(Ljava/lang/String;)V
    const/16 v4, 0x64
  :wait_completed
    const-string v0, "FastChat generation status"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "completed"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :completed
    const-wide/16 v0, 0x64
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v4, v4, -1
    if-gtz v4, :wait_completed
    const-string v0, "FAIL second durable timeline turn completion"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :completed
    const-string v0, "Conversation timeline"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->node(Ljava/lang/String;)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v3
    const/16 v4, 0x8
  :scroll_top
    const/16 v0, 0x2000
    invoke-virtual {v3, v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    const-wide/16 v0, 0xc8
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v4, v4, -1
    if-gtz v4, :scroll_top
    const-string v0, "Earlier user message, turn 1"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, ":long"
    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :user_ok
    const-string v0, "FAIL timeline prior source prompt and role"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :user_ok
    const-string v0, "Earlier assistant response preview, turn 1"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v0
    if-gtz v0, :assistant_ok
    const-string v0, "FAIL timeline prior stored assistant response"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :assistant_ok
    const/16 v4, 0x4
  :scroll_read
    const/16 v0, 0x1000
    invoke-virtual {v3, v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->performAction(I)Z
    const-wide/16 v0, 0xc8
    invoke-static {v0, v1}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v4, v4, -1
    if-gtz v4, :scroll_read
    const-string v0, "Read turn 1"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->click(Ljava/lang/String;)V
    const-string v0, "FastChat generation status"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "Turn 1 / 2"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :selected
    const-string v0, "FAIL timeline Button selects its real durable request"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :selected
    const-string v0, "Latest"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->click(Ljava/lang/String;)V
    const-string v0, "FastChat generation status"
    invoke-direct {p0, v0}, Lacceptance/presentation/FastChatUi;->text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "Turn 2 / 2"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v0
    if-nez v0, :latest
    const-string v0, "FAIL timeline return to latest durable request"
    invoke-static {v0}, Lacceptance/presentation/FastChatUi;->fail(Ljava/lang/String;)V
  :latest
    const-string v0, "NativeTimelineAcceptance"
    const-string v1, "PASS actual prior roles source text request selection and return to latest"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
.end method
