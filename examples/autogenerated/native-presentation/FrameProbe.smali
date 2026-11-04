.class public final Lacceptance/presentation/FrameProbe;
.super Ljava/lang/Object;
.method private static near(II)Z
    .locals 5
    const/4 v0, 0
  :channel
    shr-int v1, p0, v0
    and-int/lit16 v1, v1, 0xff
    shr-int v2, p1, v0
    and-int/lit16 v2, v2, 0xff
    sub-int/2addr v1, v2
    if-gez v1, :positive
    neg-int v1, v1
  :positive
    const/4 v2, 2
    if-gt v1, v2, :bad
    add-int/lit8 v0, v0, 8
    const/16 v3, 24
    if-lt v0, v3, :channel
    const/4 v0, 1
    return v0
  :bad
    const/4 v0, 0
    return v0
.end method
.method public static assertVisible(Landroid/app/Instrumentation;Landroid/app/Activity;)V
    .locals 11
    const/4 v9, 0
    const/4 v10, 0
  :control
    const/16 v1, 105
    if-eqz v9, :create
    const/16 v1, 104
  :create
    new-instance v0, Lacceptance/presentation/FrameTask;
    invoke-direct {v0, p1, v1}, Lacceptance/presentation/FrameTask;-><init>(Landroid/app/Activity;I)V
    const/16 v1, 30
    const/4 v8, 0
  :sample
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-boolean v3, v0, Lacceptance/presentation/FrameTask;->valid:Z
    if-eqz v3, :wait
    const/4 v8, 1
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v2
    invoke-virtual {v2}, Landroid/app/UiAutomation;->takeScreenshot()Landroid/graphics/Bitmap;
    move-result-object v2
    if-eqz v2, :wait
    iget v3, v0, Lacceptance/presentation/FrameTask;->x:I
    iget v4, v0, Lacceptance/presentation/FrameTask;->y:I
    if-ltz v3, :recycle
    if-ltz v4, :recycle
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getWidth()I
    move-result v7
    if-ge v3, v7, :recycle
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->getHeight()I
    move-result v7
    if-ge v4, v7, :recycle
    iget v5, v0, Lacceptance/presentation/FrameTask;->color:I
    invoke-virtual {v2, v3, v4}, Landroid/graphics/Bitmap;->getPixel(II)I
    move-result v6
    invoke-static {v5, v6}, Lacceptance/presentation/FrameProbe;->near(II)Z
    move-result v7
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->recycle()V
    if-nez v7, :matched
    goto :wait
  :recycle
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->recycle()V
  :wait
    const-wide/16 v2, 0x32
    invoke-static {v2, v3}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v1, v1, -1
    if-gtz v1, :sample
    const-string v1, "FAIL actual frame sampling control"
    if-eqz v8, :throw
    const-string v1, "FAIL framework controls are visible in the compositor"
    goto :throw
  :matched
    if-nez v9, :second
    move v10, v5
    const/4 v9, 1
    goto :control
  :second
    if-eq v10, v5, :same
    const-string v0, "NativeCompositorAcceptance"
    const-string v1, "PASS compositor pixels match actual filled and neutral framework controls"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
  :same
    const-string v1, "FAIL distinct semantic control surfaces"
  :throw
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method
