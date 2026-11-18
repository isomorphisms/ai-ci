.class public final Lacceptance/ParcelableObserver;
.super Ljava/lang/Object;

.method private static failure()V
    .registers 2
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL native Shizuku Parcelable Binder identity"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x49
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
.end method

# Write using the SDK, read using the candidate Creator. This cannot pass
# merely because a candidate writer and reader share the same wire mistake.
.method private static readFromSdk(Landroid/os/IBinder;)Lmoe/shizuku/api/BinderContainer;
    .registers 4
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;
    move-result-object v0
    invoke-virtual {v0, p0}, Landroid/os/Parcel;->writeStrongBinder(Landroid/os/IBinder;)V
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroid/os/Parcel;->setDataPosition(I)V
    sget-object v1, Lmoe/shizuku/api/BinderContainer;->CREATOR:Landroid/os/Parcelable$Creator;
    invoke-interface {v1, v0}, Landroid/os/Parcelable$Creator;->createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;
    move-result-object v2
    check-cast v2, Lmoe/shizuku/api/BinderContainer;
    invoke-virtual {v0}, Landroid/os/Parcel;->dataAvail()I
    move-result v1
    if-nez v1, :failed
    invoke-virtual {v0}, Landroid/os/Parcel;->recycle()V
    iget-object v1, v2, Lmoe/shizuku/api/BinderContainer;->binder:Landroid/os/IBinder;
    if-ne v1, p0, :failed
    return-object v2
  :failed
    invoke-static {}, Lacceptance/ParcelableObserver;->failure()V
    return-object v2
.end method

# Write using the candidate, read using the SDK.
.method private static writeToSdk(Lmoe/shizuku/api/BinderContainer;Landroid/os/IBinder;)V
    .registers 5
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;
    move-result-object v0
    const/4 v1, 0x0
    invoke-virtual {p0, v0, v1}, Lmoe/shizuku/api/BinderContainer;->writeToParcel(Landroid/os/Parcel;I)V
    invoke-virtual {v0, v1}, Landroid/os/Parcel;->setDataPosition(I)V
    invoke-virtual {v0}, Landroid/os/Parcel;->readStrongBinder()Landroid/os/IBinder;
    move-result-object v2
    if-ne v2, p1, :failed
    invoke-virtual {v0}, Landroid/os/Parcel;->dataAvail()I
    move-result v1
    if-nez v1, :failed
    invoke-virtual {v0}, Landroid/os/Parcel;->recycle()V
    return-void
  :failed
    invoke-static {}, Lacceptance/ParcelableObserver;->failure()V
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 9
    new-instance v0, Landroid/os/Binder;
    invoke-direct {v0}, Landroid/os/Binder;-><init>()V
    new-instance v1, Landroid/os/Binder;
    invoke-direct {v1}, Landroid/os/Binder;-><init>()V
    invoke-static {v0}, Lacceptance/ParcelableObserver;->readFromSdk(Landroid/os/IBinder;)Lmoe/shizuku/api/BinderContainer;
    move-result-object v2
    invoke-static {v1}, Lacceptance/ParcelableObserver;->readFromSdk(Landroid/os/IBinder;)Lmoe/shizuku/api/BinderContainer;
    move-result-object v3
    iget-object v4, v2, Lmoe/shizuku/api/BinderContainer;->binder:Landroid/os/IBinder;
    if-ne v4, v0, :failed
    invoke-static {v2, v0}, Lacceptance/ParcelableObserver;->writeToSdk(Lmoe/shizuku/api/BinderContainer;Landroid/os/IBinder;)V
    invoke-static {v3, v1}, Lacceptance/ParcelableObserver;->writeToSdk(Lmoe/shizuku/api/BinderContainer;Landroid/os/IBinder;)V
    invoke-virtual {v2}, Lmoe/shizuku/api/BinderContainer;->describeContents()I
    move-result v4
    if-nez v4, :failed
    const/4 v4, 0x0
    invoke-static {v4}, Lacceptance/ParcelableObserver;->readFromSdk(Landroid/os/IBinder;)Lmoe/shizuku/api/BinderContainer;
    move-result-object v5
    invoke-static {v5, v4}, Lacceptance/ParcelableObserver;->writeToSdk(Lmoe/shizuku/api/BinderContainer;Landroid/os/IBinder;)V

    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;
    move-result-object v5
    invoke-virtual {v5, v2, v4}, Landroid/os/Parcel;->writeParcelable(Landroid/os/Parcelable;I)V
    invoke-virtual {v5, v4}, Landroid/os/Parcel;->setDataPosition(I)V
    const-class v6, Lmoe/shizuku/api/BinderContainer;
    invoke-virtual {v6}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;
    move-result-object v6
    invoke-virtual {v5, v6}, Landroid/os/Parcel;->readParcelable(Ljava/lang/ClassLoader;)Landroid/os/Parcelable;
    move-result-object v7
    check-cast v7, Lmoe/shizuku/api/BinderContainer;
    iget-object v7, v7, Lmoe/shizuku/api/BinderContainer;->binder:Landroid/os/IBinder;
    if-ne v7, v0, :failed
    invoke-virtual {v5}, Landroid/os/Parcel;->recycle()V
    sget-object v5, Lmoe/shizuku/api/BinderContainer;->CREATOR:Landroid/os/Parcelable$Creator;
    const/4 v6, 0x2
    invoke-interface {v5, v6}, Landroid/os/Parcelable$Creator;->newArray(I)[Ljava/lang/Object;
    move-result-object v7
    check-cast v7, [Lmoe/shizuku/api/BinderContainer;
    array-length v7, v7
    if-ne v7, v6, :failed
  :large_start
    const/16 v6, 0x1001
    invoke-interface {v5, v6}, Landroid/os/Parcelable$Creator;->newArray(I)[Ljava/lang/Object;
  :large_end
    goto :failed
    .catch Ljava/lang/IllegalArgumentException; {:large_start .. :large_end} :large_refused
  :large_refused
    move-exception v6
  :null_start
    invoke-interface {v5, v4}, Landroid/os/Parcelable$Creator;->createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;
  :null_end
    goto :failed
    .catch Ljava/lang/IllegalArgumentException; {:null_start .. :null_end} :null_refused
  :null_refused
    move-exception v6
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent native Shizuku Parcelable wire on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
  :failed
    invoke-static {}, Lacceptance/ParcelableObserver;->failure()V
    return-void
.end method
