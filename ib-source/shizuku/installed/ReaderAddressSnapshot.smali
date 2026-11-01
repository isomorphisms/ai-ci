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
    invoke-static {v0}, Lacceptance/shizuku/ReaderAddressSnapshot;->describe(Landroid/app/Activity;)V
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

# Read SDK state on the real UI thread; this never changes selection or focus.
.method private static describe(Landroid/app/Activity;)V
    .registers 8
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v1, "boundActivity finishing="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0}, Landroid/app/Activity;->isFinishing()Z
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    const-string v1, " destroyed="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0}, Landroid/app/Activity;->isDestroyed()Z
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    const-string v1, " windowFocus="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p0}, Landroid/app/Activity;->hasWindowFocus()Z
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    const v1, 0x7f030000
    invoke-virtual {p0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v3
    if-nez v3, :body
    const-string v1, " body=missing"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :record
  :body
    check-cast v3, Landroid/widget/TextView;
    const-string v1, " bodyShown="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Landroid/view/View;->isShown()Z
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    const-string v1, " bodyFocused="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Landroid/view/View;->isFocused()Z
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;
    const-string v1, " UTF16length="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v2
    invoke-interface {v2}, Ljava/lang/CharSequence;->length()I
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v1, " SDKselection="
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Landroid/widget/TextView;->getSelectionStart()I
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v1, ","
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Landroid/widget/TextView;->getSelectionEnd()I
    move-result v2
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
  :record
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "IBIndependentReaderSurface"
    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    return-void
.end method
