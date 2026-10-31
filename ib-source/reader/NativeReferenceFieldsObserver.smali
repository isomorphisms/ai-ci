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
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent native reference field ownership on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
  :failed
    invoke-static {}, Lacceptance/NativeReferenceFieldsObserver;->failure()V
    return-void
.end method
