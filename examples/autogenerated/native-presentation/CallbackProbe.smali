.class public final Lacceptance/presentation/CallbackProbe;
.super Ljava/lang/Object;

.method public static main([Ljava/lang/String;)V
    .locals 6
  :lookup_begin
    const-string v0, "org.isomorphisms.nativeui.Action"
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v0
    const-class v1, Landroid/view/View$OnClickListener;
    invoke-virtual {v1, v0}, Ljava/lang/Class;->isAssignableFrom(Ljava/lang/Class;)Z
    move-result v1
    if-eqz v1, :fail
    const/4 v1, 1
    new-array v1, v1, [Ljava/lang/Class;
    const-class v2, Landroid/view/View;
    const/4 v3, 0
    aput-object v2, v1, v3
    const-string v2, "onClick"
    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/reflect/Method;->getModifiers()I
    move-result v1
    and-int/lit16 v1, v1, 0x100
    if-eqz v1, :fail
    invoke-virtual {v0}, Ljava/lang/reflect/Method;->getReturnType()Ljava/lang/Class;
    move-result-object v1
    sget-object v2, Ljava/lang/Void;->TYPE:Ljava/lang/Class;
    if-ne v1, v2, :fail
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent exact framework callback declaration on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
  :lookup_end
    .catch Ljava/lang/NoSuchMethodException; {:lookup_begin .. :lookup_end} :incompatible
  :fail
    new-instance v0, Ljava/lang/AssertionError;
    const-string v1, "FAIL framework View callback contract"
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :incompatible
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v1
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x2a
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    return-void
.end method
