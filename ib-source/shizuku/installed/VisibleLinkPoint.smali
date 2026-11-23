.class public final Lacceptance/shizuku/VisibleLinkPoint;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private activity:Landroid/app/Activity;
.field public x:F
.field public y:F
.field public problem:Ljava/lang/String;

.method public constructor <init>(Landroid/app/Activity;)V
    .registers 2
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/VisibleLinkPoint;->activity:Landroid/app/Activity;
    return-void
.end method

.method public run()V
    .registers 14
  :begin
    iget-object v0, p0, Lacceptance/shizuku/VisibleLinkPoint;->activity:Landroid/app/Activity;
    const v1, 0x7f030000
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    check-cast v0, Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "Next"
    invoke-virtual {v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
    move-result v2
    if-ltz v2, :failed
    add-int/lit8 v2, v2, 0x1
    invoke-virtual {v0}, Landroid/widget/TextView;->getLayout()Landroid/text/Layout;
    move-result-object v1
    if-eqz v1, :failed
    invoke-virtual {v1, v2}, Landroid/text/Layout;->getLineForOffset(I)I
    move-result v3
    invoke-virtual {v1, v3}, Landroid/text/Layout;->getLineTop(I)I
    move-result v4
    invoke-virtual {v1, v3}, Landroid/text/Layout;->getLineBottom(I)I
    move-result v5
    add-int/2addr v4, v5
    div-int/lit8 v4, v4, 0x2
    invoke-virtual {v1, v2}, Landroid/text/Layout;->getPrimaryHorizontal(I)F
    move-result v5
    invoke-virtual {v0}, Landroid/widget/TextView;->getTotalPaddingLeft()I
    move-result v6
    invoke-virtual {v0}, Landroid/view/View;->getScrollX()I
    move-result v7
    sub-int/2addr v6, v7
    int-to-float v6, v6
    add-float/2addr v5, v6
    invoke-virtual {v0}, Landroid/widget/TextView;->getTotalPaddingTop()I
    move-result v6
    invoke-virtual {v0}, Landroid/view/View;->getScrollY()I
    move-result v7
    sub-int/2addr v6, v7
    add-int/2addr v4, v6
    int-to-float v4, v4
    const/4 v6, 0x2
    new-array v6, v6, [I
    invoke-virtual {v0, v6}, Landroid/view/View;->getLocationOnScreen([I)V
    const/4 v7, 0x0
    aget v7, v6, v7
    int-to-float v7, v7
    add-float/2addr v5, v7
    const/4 v7, 0x1
    aget v7, v6, v7
    int-to-float v7, v7
    add-float/2addr v4, v7
    invoke-virtual {v0}, Landroid/view/View;->isShown()Z
    move-result v7
    if-eqz v7, :failed
    new-instance v8, Landroid/graphics/Rect;
    invoke-direct {v8}, Landroid/graphics/Rect;-><init>()V
    invoke-virtual {v0, v8}, Landroid/view/View;->getGlobalVisibleRect(Landroid/graphics/Rect;)Z
    move-result v7
    if-eqz v7, :failed
    float-to-int v9, v5
    float-to-int v10, v4
    invoke-virtual {v8, v9, v10}, Landroid/graphics/Rect;->contains(II)Z
    move-result v7
    if-eqz v7, :failed
    iput v5, p0, Lacceptance/shizuku/VisibleLinkPoint;->x:F
    iput v4, p0, Lacceptance/shizuku/VisibleLinkPoint;->y:F
    return-void
  :failed
    const-string v0, "FAIL Next link has no visible SDK text-layout point"
    iput-object v0, p0, Lacceptance/shizuku/VisibleLinkPoint;->problem:Ljava/lang/String;
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :caught
  :caught
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/VisibleLinkPoint;->problem:Ljava/lang/String;
    return-void
.end method
