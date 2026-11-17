.class public final Lacceptance/admin/AdminDiagnosticCallback;
.super Ljava/lang/Object;
.implements Landroid/webkit/ValueCallback;

.field private final target:Landroid/webkit/ValueCallback;
.field private final observer:Lacceptance/admin/AdminInstrumentation;

.method public constructor <init>(Landroid/webkit/ValueCallback;Lacceptance/admin/AdminInstrumentation;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/admin/AdminDiagnosticCallback;->target:Landroid/webkit/ValueCallback;
    iput-object p2, p0, Lacceptance/admin/AdminDiagnosticCallback;->observer:Lacceptance/admin/AdminInstrumentation;
    return-void
.end method

.method public onReceiveValue(Ljava/lang/Object;)V
    .locals 2
  :try_start
    iget-object v0, p0, Lacceptance/admin/AdminDiagnosticCallback;->target:Landroid/webkit/ValueCallback;
    invoke-interface {v0, p1}, Landroid/webkit/ValueCallback;->onReceiveValue(Ljava/lang/Object;)V
  :try_end
    .catch Ljava/lang/Throwable; {:try_start .. :try_end} :failed
    goto :done
  :failed
    move-exception v0
    iget-object v0, p0, Lacceptance/admin/AdminDiagnosticCallback;->observer:Lacceptance/admin/AdminInstrumentation;
    const-string v1, "FAIL real diagnostic callback raised an exception"
    iput-object v1, v0, Lacceptance/admin/AdminInstrumentation;->uiFailure:Ljava/lang/String;
  :done
    iget-object v0, p0, Lacceptance/admin/AdminDiagnosticCallback;->observer:Lacceptance/admin/AdminInstrumentation;
    const/4 v1, 1
    iput v1, v0, Lacceptance/admin/AdminInstrumentation;->diagnosticDone:I
    return-void
.end method
