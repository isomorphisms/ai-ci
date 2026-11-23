.class public final Lacceptance/shizuku/ReaderAddressSnapshot;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private activity:Landroid/app/Activity;
.field public address:Ljava/lang/String;
.method public constructor <init>(Landroid/app/Activity;)V
    .registers 2
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/ReaderAddressSnapshot;->activity:Landroid/app/Activity;
    return-void
.end method
.method public run()V
    .registers 3
    iget-object v0, p0, Lacceptance/shizuku/ReaderAddressSnapshot;->activity:Landroid/app/Activity;
    const v1, 0x7f030001
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    check-cast v0, Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/ReaderAddressSnapshot;->address:Ljava/lang/String;
    return-void
.end method
