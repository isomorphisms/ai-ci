.class public final Lacceptance/shizuku/GoogleSourceSnapshot;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private activity:Landroid/app/Activity;
.field public source:Ljava/lang/String;
.field public problem:Ljava/lang/String;

.method public constructor <init>(Landroid/app/Activity;)V
    .registers 2
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/GoogleSourceSnapshot;->activity:Landroid/app/Activity;
    return-void
.end method

.method private static field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    .registers 4
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v0
    const/4 v1, 1
    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    invoke-virtual {v0, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    return-object v0
.end method

.method private static write(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V
    .registers 7
    invoke-virtual {p2}, Ljava/lang/String;->length()I
    move-result v0
    if-lez v0, :invalid
    const v1, 0x10000
    if-gt v0, v1, :invalid
    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0, p1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    new-instance v0, Ljava/io/FileOutputStream;
    invoke-direct {v0, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    const-string v1, "UTF-8"
    invoke-virtual {p2, v1}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    move-result-object v1
  :writing
    invoke-virtual {v0, v1}, Ljava/io/FileOutputStream;->write([B)V
    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V
    return-void
  :written
    .catch Ljava/lang/Throwable; {:writing .. :written} :close_failed
  :close_failed
    move-exception v1
    invoke-virtual {v0}, Ljava/io/FileOutputStream;->close()V
    throw v1
  :invalid
    new-instance v0, Ljava/lang/IllegalStateException;
    const-string v1, "bounded native Google selection snapshot unavailable"
    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V
    throw v0
.end method

.method public run()V
    .registers 7
  :begin
    iget-object v0, p0, Lacceptance/shizuku/GoogleSourceSnapshot;->activity:Landroid/app/Activity;
    const v1, 0x7f030000
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Landroid/widget/TextView;
    invoke-virtual {v1}, Landroid/view/View;->isShown()Z
    move-result v2
    if-eqz v2, :invalid
    const-string v2, "projection"
    invoke-static {v1, v2}, Lacceptance/shizuku/GoogleSourceSnapshot;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v2
    const-string v3, "sourceText"
    invoke-static {v2, v3}, Lacceptance/shizuku/GoogleSourceSnapshot;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Ljava/lang/String;
    iput-object v3, p0, Lacceptance/shizuku/GoogleSourceSnapshot;->source:Ljava/lang/String;
    const-string v4, "displayText"
    invoke-static {v2, v4}, Lacceptance/shizuku/GoogleSourceSnapshot;->field(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Ljava/lang/String;
    invoke-virtual {v1}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :invalid
    const-string v4, "ib-acceptance-google-source.txt"
    invoke-static {v0, v4, v3}, Lacceptance/shizuku/GoogleSourceSnapshot;->write(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V
    const-string v4, "ib-acceptance-google-display.txt"
    invoke-static {v0, v4, v1}, Lacceptance/shizuku/GoogleSourceSnapshot;->write(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;)V
    return-void
  :invalid
    const-string v0, "FAIL actual native Google projection snapshot correspondence"
    iput-object v0, p0, Lacceptance/shizuku/GoogleSourceSnapshot;->problem:Ljava/lang/String;
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :caught
  :caught
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/GoogleSourceSnapshot;->problem:Ljava/lang/String;
    return-void
.end method
