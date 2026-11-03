.class public final Lacceptance/shizuku/EarlyLinkTouchProbe;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.implements Landroid/view/ViewTreeObserver$OnPreDrawListener;
.implements Landroid/view/View$OnTouchListener;

.field private activity:Landroid/app/Activity;
.field private body:Landroid/widget/TextView;
.field private oldText:Ljava/lang/CharSequence;
.field public ready:Ljava/util/concurrent/CountDownLatch;
.field public volatile mode:I
.field public volatile frameAt:J
.field public volatile frameCommittedAt:J
.field public volatile downs:I
.field public volatile ups:I
.field public volatile downAt:J
.field public volatile upAt:J
.field public volatile problem:Ljava/lang/String;

.method public constructor <init>(Landroid/app/Activity;)V
    .registers 4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->activity:Landroid/app/Activity;
    new-instance v0, Ljava/util/concurrent/CountDownLatch;
    const/4 v1, 1
    invoke-direct {v0, v1}, Ljava/util/concurrent/CountDownLatch;-><init>(I)V
    iput-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->ready:Ljava/util/concurrent/CountDownLatch;
    return-void
.end method

# Mode0 arms on the UI thread; mode2 records the real frame-commit callback;
# mode3 removes observers. No callback changes scroll, selection or focus.
.method public run()V
    .registers 6
  :begin
    iget v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->mode:I
    if-eqz v0, :arm
    const/4 v1, 3
    if-eq v0, v1, :cleanup
    const/4 v1, 2
    if-ne v0, v1, :invalid
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v0
    iput-wide v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->frameCommittedAt:J
    iget-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->ready:Ljava/util/concurrent/CountDownLatch;
    invoke-virtual {v0}, Ljava/util/concurrent/CountDownLatch;->countDown()V
    return-void
  :arm
    iget-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->activity:Landroid/app/Activity;
    invoke-virtual {v0}, Landroid/app/Activity;->hasWindowFocus()Z
    move-result v1
    if-eqz v1, :invalid
    const v1, 0x7f030000
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v2
    check-cast v2, Landroid/widget/TextView;
    if-eqz v2, :invalid
    invoke-virtual {v2}, Landroid/view/View;->isShown()Z
    move-result v1
    if-eqz v1, :invalid
    invoke-virtual {v2}, Landroid/view/View;->isHardwareAccelerated()Z
    move-result v1
    if-eqz v1, :invalid
    iput-object v2, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->body:Landroid/widget/TextView;
    invoke-virtual {v2}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->oldText:Ljava/lang/CharSequence;
    invoke-virtual {v2, p0}, Landroid/view/View;->setOnTouchListener(Landroid/view/View$OnTouchListener;)V
    invoke-virtual {v2}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;
    move-result-object v0
    invoke-virtual {v0, p0}, Landroid/view/ViewTreeObserver;->addOnPreDrawListener(Landroid/view/ViewTreeObserver$OnPreDrawListener;)V
    const/4 v0, 1
    iput v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->mode:I
    return-void
  :cleanup
    iget-object v2, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->body:Landroid/widget/TextView;
    if-eqz v2, :done
    const/4 v0, 0
    invoke-virtual {v2, v0}, Landroid/view/View;->setOnTouchListener(Landroid/view/View$OnTouchListener;)V
    invoke-virtual {v2}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;
    move-result-object v0
    invoke-virtual {v0, p0}, Landroid/view/ViewTreeObserver;->removeOnPreDrawListener(Landroid/view/ViewTreeObserver$OnPreDrawListener;)V
  :done
    return-void
  :invalid
    const-string v0, "FAIL early-touch probe requires the focused hardware-rendered native document"
    iput-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->problem:Ljava/lang/String;
    iget-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->ready:Ljava/util/concurrent/CountDownLatch;
    invoke-virtual {v0}, Ljava/util/concurrent/CountDownLatch;->countDown()V
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :caught
  :caught
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->problem:Ljava/lang/String;
    iget-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->ready:Ljava/util/concurrent/CountDownLatch;
    invoke-virtual {v0}, Ljava/util/concurrent/CountDownLatch;->countDown()V
    return-void
.end method

.method public onPreDraw()Z
    .registers 7
  :begin
    iget v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->mode:I
    const/4 v1, 1
    if-ne v0, v1, :draw
    iget-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->body:Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    iget-object v2, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->oldText:Ljava/lang/CharSequence;
    if-eq v1, v2, :draw
    invoke-virtual {v0}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;
    move-result-object v1
    invoke-virtual {v1, p0}, Landroid/view/ViewTreeObserver;->removeOnPreDrawListener(Landroid/view/ViewTreeObserver$OnPreDrawListener;)V
    invoke-static {}, Landroid/view/animation/AnimationUtils;->currentAnimationTimeMillis()J
    move-result-wide v2
    iput-wide v2, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->frameAt:J
    const/4 v0, 2
    iput v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->mode:I
    invoke-virtual {v1, p0}, Landroid/view/ViewTreeObserver;->registerFrameCommitCallback(Ljava/lang/Runnable;)V
  :draw
    const/4 v0, 1
    return v0
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :caught
  :caught
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->problem:Ljava/lang/String;
    iget-object v0, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->ready:Ljava/util/concurrent/CountDownLatch;
    invoke-virtual {v0}, Ljava/util/concurrent/CountDownLatch;->countDown()V
    const/4 v0, 1
    return v0
.end method

.method public onTouch(Landroid/view/View;Landroid/view/MotionEvent;)Z
    .registers 8
    invoke-virtual {p2}, Landroid/view/MotionEvent;->getActionMasked()I
    move-result v0
    if-eqz v0, :down
    const/4 v1, 1
    if-ne v0, v1, :done
    iget v1, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->ups:I
    add-int/lit8 v1, v1, 1
    iput v1, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->ups:I
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    iput-wide v2, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->upAt:J
    goto :done
  :down
    iget v1, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->downs:I
    add-int/lit8 v1, v1, 1
    iput v1, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->downs:I
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    iput-wide v2, p0, Lacceptance/shizuku/EarlyLinkTouchProbe;->downAt:J
  :done
    const/4 v0, 0
    return v0
.end method
