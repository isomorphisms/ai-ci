.class public final Lacceptance/presentation/ReaderTintTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private owner:Landroid/app/Activity;
.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/ReaderTintTask;->owner:Landroid/app/Activity;
    return-void
.end method
.method public run()V
    .locals 3
    iget-object v0, p0, Lacceptance/presentation/ReaderTintTask;->owner:Landroid/app/Activity;
    const v1, 0x7f030003
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    const v1, 0xff292929
    invoke-static {v1}, Landroid/content/res/ColorStateList;->valueOf(I)Landroid/content/res/ColorStateList;
    move-result-object v1
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackgroundTintList(Landroid/content/res/ColorStateList;)V
    return-void
.end method
