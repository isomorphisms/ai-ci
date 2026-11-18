.class public final Lacceptance/admin/AdminCallback;
.super Ljava/lang/Object;
.implements Landroid/webkit/ValueCallback;

.field public volatile value:Ljava/lang/String;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public onReceiveValue(Ljava/lang/Object;)V
    .locals 2
    instance-of v1, p1, Ljava/lang/String;
    if-eqz v1, :invalid
    check-cast p1, Ljava/lang/String;
    iput-object p1, p0, Lacceptance/admin/AdminCallback;->value:Ljava/lang/String;
    return-void
  :invalid
    const-string v1, "null"
    iput-object v1, p0, Lacceptance/admin/AdminCallback;->value:Ljava/lang/String;
    return-void
.end method
