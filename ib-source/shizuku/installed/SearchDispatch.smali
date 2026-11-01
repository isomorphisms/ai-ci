.class public final Lacceptance/shizuku/SearchDispatch;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private activity:Landroid/app/Activity;
.field private request:Landroid/content/Intent;
.field private warm:Z
.method public constructor <init>(Landroid/app/Activity;Landroid/content/Intent;Z)V
    .registers 4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/SearchDispatch;->activity:Landroid/app/Activity;
    iput-object p2, p0, Lacceptance/shizuku/SearchDispatch;->request:Landroid/content/Intent;
    iput-boolean p3, p0, Lacceptance/shizuku/SearchDispatch;->warm:Z
    return-void
.end method
.method public run()V
    .registers 4
    iget-object v0, p0, Lacceptance/shizuku/SearchDispatch;->activity:Landroid/app/Activity;
    iget-object v1, p0, Lacceptance/shizuku/SearchDispatch;->request:Landroid/content/Intent;
    iget-boolean v2, p0, Lacceptance/shizuku/SearchDispatch;->warm:Z
    if-eqz v2, :fresh
    const/high16 v2, 0x20000000
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {v0, v1}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V
    return-void
  :fresh
    const/16 v2, 0x104d
    invoke-virtual {v0, v1, v2}, Landroid/app/Activity;->startActivityForResult(Landroid/content/Intent;I)V
    return-void
.end method
