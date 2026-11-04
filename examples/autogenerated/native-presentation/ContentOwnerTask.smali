.class public final Lacceptance/presentation/ContentOwnerTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private owner:Landroid/app/Activity;
.field public attached:Z
.field public settings:Z

.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/ContentOwnerTask;->owner:Landroid/app/Activity;
    return-void
.end method
.method public run()V
    .locals 4
    const/4 v0, 0
    iput-boolean v0, p0, Lacceptance/presentation/ContentOwnerTask;->attached:Z
    iget-object v0, p0, Lacceptance/presentation/ContentOwnerTask;->owner:Landroid/app/Activity;
    const/16 v1, 0x69
    iget-boolean v2, p0, Lacceptance/presentation/ContentOwnerTask;->settings:Z
    if-eqz v2, :find
    const/16 v1, 0x6a
  :find
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    instance-of v2, v1, Landroid/widget/Button;
    if-eqz v2, :done
    invoke-virtual {v1}, Landroid/view/View;->getContext()Landroid/content/Context;
    move-result-object v2
    if-ne v0, v2, :done
    invoke-virtual {v1}, Landroid/view/View;->getRootView()Landroid/view/View;
    move-result-object v1
    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v0
    iget-boolean v2, p0, Lacceptance/presentation/ContentOwnerTask;->settings:Z
    if-eqz v2, :decor
    invoke-virtual {v0}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;
    move-result-object v2
    iget v2, v2, Landroid/view/WindowManager$LayoutParams;->flags:I
    and-int/lit16 v2, v2, 0x2000
    if-eqz v2, :done
  :decor
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v0
    if-ne v0, v1, :done
    const/4 v0, 1
    iput-boolean v0, p0, Lacceptance/presentation/ContentOwnerTask;->attached:Z
  :done
    return-void
.end method
