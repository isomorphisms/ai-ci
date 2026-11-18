.class public final Lacceptance/shizuku/FakeUnprivilegedServer;
.super Landroid/os/Binder;

# Independent negative peer only. A normal application UID must never reach
# this attach handler through IB's provider, even with a well-formed container.
.method public constructor <init>()V
    .registers 3
    invoke-direct {p0}, Landroid/os/Binder;-><init>()V
    const/4 v0, 0x0
    const-string v1, "moe.shizuku.server.IShizukuService"
    invoke-virtual {p0, v0, v1}, Landroid/os/Binder;->attachInterface(Landroid/os/IInterface;Ljava/lang/String;)V
    return-void
.end method

.method public onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z
    .registers 7
    const/16 v0, 0x12
    if-ne p1, v0, :refused
    if-eqz p3, :refused
    const-string v0, "moe.shizuku.server.IShizukuService"
    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V
    const/4 v0, 0x1
    return v0
  :refused
    const/4 v0, 0x0
    return v0
.end method
