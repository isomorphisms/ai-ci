.class public final Lacceptance/presentation/ReaderFrameProbe;
.super Ljava/lang/Object;
.method private static saveFrame(Landroid/app/Instrumentation;)V
    .locals 6
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getUiAutomation()Landroid/app/UiAutomation;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/UiAutomation;->takeScreenshot()Landroid/graphics/Bitmap;
    move-result-object v0
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v1
    const/4 v2, 0
    invoke-virtual {v1, v2}, Landroid/content/Context;->getExternalFilesDir(Ljava/lang/String;)Ljava/io/File;
    move-result-object v1
    new-instance v2, Ljava/io/File;
    const-string v3, "acceptance-reader-frame.png"
    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v1, Ljava/io/FileOutputStream;
    invoke-direct {v1, v2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    sget-object v2, Landroid/graphics/Bitmap$CompressFormat;->PNG:Landroid/graphics/Bitmap$CompressFormat;
    const/16 v3, 100
    invoke-virtual {v0, v2, v3, v1}, Landroid/graphics/Bitmap;->compress(Landroid/graphics/Bitmap$CompressFormat;ILjava/io/OutputStream;)Z
    move-result v2
    invoke-virtual {v1}, Ljava/io/FileOutputStream;->close()V
    invoke-virtual {v0}, Landroid/graphics/Bitmap;->recycle()V
    if-nez v2, :done
    new-instance v0, Ljava/lang/AssertionError;
    const-string v1, "FAIL IB live compositor capture"
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :done
    return-void
.end method
.method public static awaitTint(Landroid/app/Instrumentation;Landroid/app/Activity;)V
    .locals 10
    new-instance v0, Lacceptance/presentation/FrameTask;
    const v1, 0x7f030003
    invoke-direct {v0, p1, v1}, Lacceptance/presentation/FrameTask;-><init>(Landroid/app/Activity;I)V
    const/16 v1, 40
  :sample
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-object v3, v0, Lacceptance/presentation/FrameTask;->failure:Ljava/lang/String;
    if-eqz v3, :window_valid
    new-instance v1, Ljava/lang/AssertionError;
    invoke-direct {v1, v3}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v1
  :window_valid
    iget-boolean v3, v0, Lacceptance/presentation/FrameTask;->valid:Z
    if-eqz v3, :wait
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
    invoke-virtual {v2, v3, v4}, Landroid/graphics/Bitmap;->getPixel(II)I
    move-result v6
    const v5, 0xff292929
    invoke-static {v5, v6}, Lacceptance/presentation/ReaderFrameProbe;->near(II)Z
    move-result v7
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->recycle()V
    if-nez v7, :drawn
    goto :wait
  :recycle
    invoke-virtual {v2}, Landroid/graphics/Bitmap;->recycle()V
  :wait
    const-wide/16 v2, 0x32
    invoke-static {v2, v3}, Landroid/os/SystemClock;->sleep(J)V
    add-int/lit8 v1, v1, -1
    if-gtz v1, :sample
    new-instance v0, Ljava/lang/AssertionError;
    const-string v1, "FAIL actual tint mutation never reached compositor"
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :drawn
    invoke-static {p0}, Lacceptance/presentation/ReaderFrameProbe;->saveFrame(Landroid/app/Instrumentation;)V
    const-string v0, "IbTintActivation"
    const-string v1, "PASS actual tint mutation reached compositor"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
.end method
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
    const v1, 0x7f030003
    if-eqz v9, :create
    const v1, 0x7f03000f
  :create
    new-instance v0, Lacceptance/presentation/FrameTask;
    invoke-direct {v0, p1, v1}, Lacceptance/presentation/FrameTask;-><init>(Landroid/app/Activity;I)V
    const/16 v1, 30
    const/4 v8, 0
  :sample
    invoke-virtual {p0, v0}, Landroid/app/Instrumentation;->runOnMainSync(Ljava/lang/Runnable;)V
    iget-object v3, v0, Lacceptance/presentation/FrameTask;->failure:Ljava/lang/String;
    if-eqz v3, :window_valid
    move-object v1, v3
    goto :throw
  :window_valid
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
    const v7, 0xff2f2f2f
    if-eq v5, v7, :charcoal_match
    const-string v1, "FAIL fixed charcoal control palette"
    goto :throw
  :charcoal_match
    invoke-virtual {v2, v3, v4}, Landroid/graphics/Bitmap;->getPixel(II)I
    move-result v6
    invoke-static {v5, v6}, Lacceptance/presentation/ReaderFrameProbe;->near(II)Z
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
    const-string v1, "FAIL IB semantic surfaces differ from actual compositor"
    goto :throw
  :matched
    if-nez v9, :second
    move v10, v5
    const/4 v9, 1
    goto :control
  :second
    if-ne v10, v5, :same
    invoke-static {p0}, Lacceptance/presentation/ReaderFrameProbe;->saveFrame(Landroid/app/Instrumentation;)V
    const-string v0, "IbCompositorAcceptance"
    const-string v1, "PASS actual IB source and history controls match the shared neutral surface"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
  :same
    const-string v1, "FAIL IB neutral semantic surfaces disagree"
  :throw
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
.end method

