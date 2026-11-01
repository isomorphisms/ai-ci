.class public final Lacceptance/NativeReferenceFieldsObserver;
.super Ljava/lang/Object;

.method private static failure()V
    .registers 2
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL native reference field ownership"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x49
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
.end method

.method private static interfaceFailure()V
    .registers 2
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL native class interface ownership"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x49
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
.end method

.method private static constructorFailure()V
    .registers 2
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL native constructor incoming values"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x49
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 10
    const-class v0, Lqualification/ReferenceContainer;
    const-string v1, "binder"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/reflect/Field;->getModifiers()I
    move-result v3
    invoke-static {v3}, Ljava/lang/reflect/Modifier;->isStatic(I)Z
    move-result v4
    if-nez v4, :failed
    invoke-static {v3}, Ljava/lang/reflect/Modifier;->isPublic(I)Z
    move-result v4
    if-eqz v4, :failed
    invoke-virtual {v2}, Ljava/lang/reflect/Field;->getType()Ljava/lang/Class;
    move-result-object v3
    const-class v4, Landroid/os/IBinder;
    if-ne v3, v4, :failed

    new-instance v5, Lqualification/ReferenceContainer;
    invoke-direct {v5}, Lqualification/ReferenceContainer;-><init>()V
    new-instance v6, Lqualification/ReferenceContainer;
    invoke-direct {v6}, Lqualification/ReferenceContainer;-><init>()V
    invoke-virtual {v2, v5}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v3
    if-nez v3, :failed
    new-instance v7, Landroid/os/Binder;
    invoke-direct {v7}, Landroid/os/Binder;-><init>()V
    invoke-virtual {v2, v5, v7}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
    invoke-virtual {v2, v5}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v3
    if-ne v3, v7, :failed
    invoke-virtual {v2, v6}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v3
    if-nez v3, :failed
    new-instance v8, Landroid/os/Binder;
    invoke-direct {v8}, Landroid/os/Binder;-><init>()V
    invoke-virtual {v2, v6, v8}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
    invoke-virtual {v2, v5}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v3
    if-ne v3, v7, :failed
    invoke-virtual {v2, v6}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v3
    if-ne v3, v8, :failed

    const-string v1, "privateBinder"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/reflect/Field;->getModifiers()I
    move-result v3
    invoke-static {v3}, Ljava/lang/reflect/Modifier;->isStatic(I)Z
    move-result v4
    if-nez v4, :failed
    invoke-static {v3}, Ljava/lang/reflect/Modifier;->isPrivate(I)Z
    move-result v4
    if-eqz v4, :failed
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    invoke-virtual {v2, v5, v8}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
    invoke-virtual {v2, v6}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v3
    if-nez v3, :failed

    const-string v1, "shared"
    invoke-virtual {v0, v1}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/reflect/Field;->getModifiers()I
    move-result v3
    invoke-static {v3}, Ljava/lang/reflect/Modifier;->isStatic(I)Z
    move-result v4
    if-eqz v4, :failed
    invoke-virtual {v2, v5, v7}, Ljava/lang/reflect/Field;->set(Ljava/lang/Object;Ljava/lang/Object;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v4
    if-ne v4, v7, :failed
    invoke-virtual {v2, v6}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v4
    if-ne v4, v7, :failed

    const-class v0, Lqualification/Runner;
    invoke-virtual {v0}, Ljava/lang/Class;->getInterfaces()[Ljava/lang/Class;
    move-result-object v1
    array-length v2, v1
    const/4 v3, 0x1
    if-ne v2, v3, :interfaces_failed
    const/4 v3, 0x0
    aget-object v2, v1, v3
    const-class v4, Ljava/lang/Runnable;
    if-ne v2, v4, :interfaces_failed
    const-class v0, Lqualification/ZPlain;
    invoke-virtual {v0}, Ljava/lang/Class;->getInterfaces()[Ljava/lang/Class;
    move-result-object v1
    array-length v2, v1
    if-nez v2, :interfaces_failed
    const-string v0, "source ☕ 𝄞"
    invoke-static {v0}, Ljava/util/Collections;->singletonList(Ljava/lang/Object;)Ljava/util/List;
    move-result-object v1
    new-instance v2, Lqualification/CollectionBox;
    invoke-direct {v2, v1}, Lqualification/CollectionBox;-><init>(Ljava/util/Collection;)V
    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I
    move-result v3
    const/4 v4, 0x1
    if-ne v3, v4, :constructors_failed
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v1
    if-ne v0, v1, :constructors_failed
    const-wide v4, 0x100000001L
    new-instance v2, Lqualification/WideDate;
    invoke-direct {v2, v4, v5}, Lqualification/WideDate;-><init>(J)V
    invoke-virtual {v2}, Ljava/util/Date;->getTime()J
    move-result-wide v6
    cmp-long v3, v4, v6
    if-nez v3, :constructors_failed
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent native reference field ownership on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
  :failed
    invoke-static {}, Lacceptance/NativeReferenceFieldsObserver;->failure()V
    return-void
  :interfaces_failed
    invoke-static {}, Lacceptance/NativeReferenceFieldsObserver;->interfaceFailure()V
    return-void
  :constructors_failed
    invoke-static {}, Lacceptance/NativeReferenceFieldsObserver;->constructorFailure()V
    return-void
.end method
