.class public final Lacceptance/presentation/FrameTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private owner:Landroid/app/Activity;
.field private identity:I
.field public valid:Z
.field public x:I
.field public y:I
.field public color:I
.method public constructor <init>(Landroid/app/Activity;I)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/FrameTask;->owner:Landroid/app/Activity;
    iput p2, p0, Lacceptance/presentation/FrameTask;->identity:I
    return-void
.end method
.method public run()V
    .locals 8
    const/4 v0, 0
    iput-boolean v0, p0, Lacceptance/presentation/FrameTask;->valid:Z
    iget-object v0, p0, Lacceptance/presentation/FrameTask;->owner:Landroid/app/Activity;
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
.end method
