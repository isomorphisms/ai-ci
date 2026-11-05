.class public final Lacceptance/presentation/FrameTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private owner:Landroid/app/Activity;
.field private identity:I
.field public valid:Z
.field public x:I
.field public y:I
.field public color:I
.field public failure:Ljava/lang/String;
.field public mutation:I
.method public constructor <init>(Landroid/app/Activity;I)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/FrameTask;->owner:Landroid/app/Activity;
    iput p2, p0, Lacceptance/presentation/FrameTask;->identity:I
    return-void
.end method
.method public run()V
    .locals 10
    const/4 v0, 0
    iput-boolean v0, p0, Lacceptance/presentation/FrameTask;->valid:Z
    iput-object v0, p0, Lacceptance/presentation/FrameTask;->failure:Ljava/lang/String;
    iget-object v0, p0, Lacceptance/presentation/FrameTask;->owner:Landroid/app/Activity;
    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v7
    iget v6, p0, Lacceptance/presentation/FrameTask;->mutation:I
    const/4 v4, 1
    if-ne v6, v4, :mutate_nav
    const v4, -0x1
    invoke-virtual {v7, v4}, Landroid/view/Window;->setStatusBarColor(I)V
  :mutate_nav
    const/4 v4, 2
    if-ne v6, v4, :window_ready
    const v4, -0x1
    invoke-virtual {v7, v4}, Landroid/view/Window;->setNavigationBarColor(I)V
  :window_ready
    const v4, 0xff212121
    invoke-virtual {v7}, Landroid/view/Window;->getStatusBarColor()I
    move-result v6
    if-ne v4, v6, :charcoal_bad
    invoke-virtual {v7}, Landroid/view/Window;->getNavigationBarColor()I
    move-result v6
    if-ne v4, v6, :charcoal_bad
    invoke-virtual {v7}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v7
    iget v6, p0, Lacceptance/presentation/FrameTask;->mutation:I
    const/4 v4, 3
    if-ne v6, v4, :icons_ready
    const/16 v6, 0x2010
    invoke-virtual {v7, v6}, Landroid/view/View;->setSystemUiVisibility(I)V
  :icons_ready
    const v4, 0xff212121
    invoke-virtual {v7}, Landroid/view/View;->getSystemUiVisibility()I
    move-result v6
    and-int/lit16 v6, v6, 0x2010
    if-nez v6, :charcoal_bad
    iget v1, p0, Lacceptance/presentation/FrameTask;->identity:I
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :done
    const v6, 0x01020002
    invoke-virtual {v0, v6}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v9
    move-object v7, v1
    const/16 v8, 16
  :root_ancestor
    invoke-virtual {v7}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v5
    if-eq v5, v9, :root_found
    instance-of v6, v5, Landroid/view/View;
    if-eqz v6, :charcoal_bad
    check-cast v5, Landroid/view/View;
    move-object v7, v5
    add-int/lit8 v8, v8, -1
    if-gtz v8, :root_ancestor
    goto :charcoal_bad
  :root_found
    iget v6, p0, Lacceptance/presentation/FrameTask;->mutation:I
    const/4 v4, 4
    if-ne v6, v4, :root_ready
    const v4, -0x1
    invoke-virtual {v7, v4}, Landroid/view/View;->setBackgroundColor(I)V
  :root_ready
    const v4, 0xff212121
    invoke-virtual {v7}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v7
    instance-of v6, v7, Landroid/graphics/drawable/ColorDrawable;
    if-eqz v6, :charcoal_bad
    check-cast v7, Landroid/graphics/drawable/ColorDrawable;
    invoke-virtual {v7}, Landroid/graphics/drawable/ColorDrawable;->getColor()I
    move-result v6
    if-ne v4, v6, :charcoal_bad
    iget v1, p0, Lacceptance/presentation/FrameTask;->identity:I
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    instance-of v2, v1, Landroid/widget/Button;
    if-eqz v2, :done
    invoke-virtual {v1}, Landroid/view/View;->getWidth()I
    move-result v2
    invoke-virtual {v1}, Landroid/view/View;->getHeight()I
    move-result v3
    if-lez v2, :done
    if-lez v3, :done
    invoke-virtual {v1}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v4
    instance-of v6, v4, Landroid/graphics/drawable/RippleDrawable;
    if-eqz v6, :done
    check-cast v4, Landroid/graphics/drawable/RippleDrawable;
    const/4 v6, 0
    invoke-virtual {v4, v6}, Landroid/graphics/drawable/RippleDrawable;->getDrawable(I)Landroid/graphics/drawable/Drawable;
    move-result-object v4
    instance-of v6, v4, Landroid/graphics/drawable/GradientDrawable;
    if-eqz v6, :done
    check-cast v4, Landroid/graphics/drawable/GradientDrawable;
    iget v6, p0, Lacceptance/presentation/FrameTask;->mutation:I
    const/4 v7, 5
    if-ne v6, v7, :surface_ready
    const v6, -0x1
    invoke-virtual {v4, v6}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
  :surface_ready
    invoke-virtual {v4}, Landroid/graphics/drawable/GradientDrawable;->getColor()Landroid/content/res/ColorStateList;
    move-result-object v4
    if-eqz v4, :done
    invoke-virtual {v4}, Landroid/content/res/ColorStateList;->getDefaultColor()I
    move-result v4
    const v6, 0xffffff
    and-int/2addr v6, v4
    if-eqz v6, :done
    iput v4, p0, Lacceptance/presentation/FrameTask;->color:I
    const/4 v4, 2
    new-array v5, v4, [I
    invoke-virtual {v1, v5}, Landroid/view/View;->getLocationOnScreen([I)V
    const/4 v4, 0
    aget v6, v5, v4
    div-int/lit8 v2, v2, 2
    add-int/2addr v6, v2
    iput v6, p0, Lacceptance/presentation/FrameTask;->x:I
    const/4 v4, 1
    aget v6, v5, v4
    div-int/lit8 v3, v3, 4
    add-int/2addr v6, v3
    iput v6, p0, Lacceptance/presentation/FrameTask;->y:I
    const/4 v0, 1
    iput-boolean v0, p0, Lacceptance/presentation/FrameTask;->valid:Z
  :done
    return-void
  :charcoal_bad
    const-string v1, "FAIL charcoal root, system bars or light icons"
    iput-object v1, p0, Lacceptance/presentation/FrameTask;->failure:Ljava/lang/String;
    return-void
.end method
