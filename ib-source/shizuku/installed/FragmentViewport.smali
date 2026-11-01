.class public final Lacceptance/shizuku/FragmentViewport;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private activity:Landroid/app/Activity;
.field private expectedTarget:Z
.field public problem:Ljava/lang/String;
.method public constructor <init>(Landroid/app/Activity;Z)V
    .registers 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/FragmentViewport;->activity:Landroid/app/Activity;
    iput-boolean p2, p0, Lacceptance/shizuku/FragmentViewport;->expectedTarget:Z
    return-void
.end method
.method private static visible(Landroid/widget/TextView;Ljava/lang/String;Ljava/lang/String;)Z
    .registers 15
    invoke-virtual {p1, p2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
    move-result v0
    if-ltz v0, :no
    add-int/lit8 v0, v0, 1
    invoke-virtual {p0}, Landroid/widget/TextView;->getLayout()Landroid/text/Layout;
    move-result-object v1
    if-eqz v1, :no
    invoke-virtual {v1, v0}, Landroid/text/Layout;->getLineForOffset(I)I
    move-result v2
    invoke-virtual {v1, v2}, Landroid/text/Layout;->getLineTop(I)I
    move-result v3
    invoke-virtual {v1, v2}, Landroid/text/Layout;->getLineBottom(I)I
    move-result v4
    add-int/2addr v3, v4
    div-int/lit8 v3, v3, 2
    invoke-virtual {v1, v0}, Landroid/text/Layout;->getPrimaryHorizontal(I)F
    move-result v4
    invoke-virtual {p0}, Landroid/widget/TextView;->getTotalPaddingLeft()I
    move-result v5
    invoke-virtual {p0}, Landroid/view/View;->getScrollX()I
    move-result v6
    sub-int/2addr v5, v6
    int-to-float v5, v5
    add-float/2addr v4, v5
    invoke-virtual {p0}, Landroid/widget/TextView;->getTotalPaddingTop()I
    move-result v5
    invoke-virtual {p0}, Landroid/view/View;->getScrollY()I
    move-result v6
    sub-int/2addr v5, v6
    add-int/2addr v3, v5
    const/4 v5, 2
    new-array v5, v5, [I
    invoke-virtual {p0, v5}, Landroid/view/View;->getLocationOnScreen([I)V
    const/4 v6, 0
    aget v6, v5, v6
    int-to-float v6, v6
    add-float/2addr v4, v6
    const/4 v6, 1
    aget v6, v5, v6
    add-int/2addr v3, v6
    float-to-int v4, v4
    new-instance v5, Landroid/graphics/Rect;
    invoke-direct {v5}, Landroid/graphics/Rect;-><init>()V
    invoke-virtual {p0, v5}, Landroid/view/View;->getGlobalVisibleRect(Landroid/graphics/Rect;)Z
    move-result v6
    if-eqz v6, :no
    invoke-virtual {p0}, Landroid/view/View;->isShown()Z
    move-result v6
    if-eqz v6, :no
    invoke-virtual {v5, v4, v3}, Landroid/graphics/Rect;->contains(II)Z
    move-result v0
    return v0
  :no
    const/4 v0, 0
    return v0
.end method
.method public run()V
    .registers 8
  :begin
    iget-object v0, p0, Lacceptance/shizuku/FragmentViewport;->activity:Landroid/app/Activity;
    const v1, 0x7f030000
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    check-cast v0, Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "Target"
    invoke-static {v0, v1, v2}, Lacceptance/shizuku/FragmentViewport;->visible(Landroid/widget/TextView;Ljava/lang/String;Ljava/lang/String;)Z
    move-result v2
    const-string v3, "Next"
    invoke-static {v0, v1, v3}, Lacceptance/shizuku/FragmentViewport;->visible(Landroid/widget/TextView;Ljava/lang/String;Ljava/lang/String;)Z
    move-result v3
    iget-boolean v4, p0, Lacceptance/shizuku/FragmentViewport;->expectedTarget:Z
    if-eqz v4, :top
    if-eqz v2, :target_failed
    if-nez v3, :target_failed
    const-string v0, "target visible; beginning outside viewport"
    goto :pass
  :top
    if-nez v2, :top_failed
    if-eqz v3, :top_failed
    const-string v0, "beginning visible; target outside viewport"
    goto :pass
  :target_failed
    const-string v0, "FAIL fragment target is outside the native viewport"
    iput-object v0, p0, Lacceptance/shizuku/FragmentViewport;->problem:Ljava/lang/String;
    return-void
  :top_failed
    const-string v0, "FAIL document beginning is outside the native viewport"
    iput-object v0, p0, Lacceptance/shizuku/FragmentViewport;->problem:Ljava/lang/String;
    return-void
  :pass
    const-string v1, "IBIndependentFragmentViewport"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :caught
  :caught
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/FragmentViewport;->problem:Ljava/lang/String;
    return-void
.end method
