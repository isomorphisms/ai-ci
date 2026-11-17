.class public final Lacceptance/admin/AdminCallback;
.super Ljava/lang/Object;
.implements Landroid/webkit/ValueCallback;

.field private final observer:Lacceptance/admin/AdminInstrumentation;

.method public constructor <init>(Lacceptance/admin/AdminInstrumentation;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/admin/AdminCallback;->observer:Lacceptance/admin/AdminInstrumentation;
    return-void
.end method

.method public onReceiveValue(Ljava/lang/Object;)V
    .locals 2
    iget-object v0, p0, Lacceptance/admin/AdminCallback;->observer:Lacceptance/admin/AdminInstrumentation;
    instance-of v1, p1, Ljava/lang/String;
    if-eqz v1, :invalid
    check-cast p1, Ljava/lang/String;
    iput-object p1, v0, Lacceptance/admin/AdminInstrumentation;->value:Ljava/lang/String;
    return-void
  :invalid
    const-string v1, "null"
    iput-object v1, v0, Lacceptance/admin/AdminInstrumentation;->value:Ljava/lang/String;
    return-void
.end method
