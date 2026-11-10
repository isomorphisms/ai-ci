.class public final Lacceptance/TextNumberCastObserver;
.super Ljava/lang/Object;

.method private static failure()V
    .registers 2
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL checked Text numeric cast"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
    return-void
.end method

.method private static expect(Ljava/lang/String;Ljava/lang/String;)V
    .registers 4
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "STAGE Text numeric input"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v0, p0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {p0}, LIdric/Generated;->integer_text(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :passed
    invoke-static {}, Lacceptance/TextNumberCastObserver;->failure()V
  :passed
    return-void
.end method

.method private static refuses(Ljava/lang/String;)V
    .registers 2
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    invoke-virtual {v0, p0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
  :start
    invoke-static {p0}, LIdric/Generated;->integer_text(Ljava/lang/String;)Ljava/lang/String;
  :end
    invoke-static {}, Lacceptance/TextNumberCastObserver;->failure()V
    return-void
    .catch Ljava/lang/UnsupportedOperationException; {:start .. :end} :refused
  :refused
    move-exception v0
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 4
    const-string v0, "83"
    const-string v1, "83"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "+00083"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "-83"
    const-string v1, "-83"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "123456789012345678901234567890"
    const-string v1, "123456789012345678901234567890"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "-0"
    const-string v1, "0"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, ""
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "invalid"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "83x"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, " 83"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "83 "
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "١٢"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "#x10"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "0x10"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "3/0"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "1/2"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "-3/2"
    const-string v1, "-1"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "-1.9"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "1.9"
    const-string v1, "1"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "1e3"
    const-string v1, "1000"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "1d2"
    const-string v1, "100"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "1e100"
    const-string v1, "10000000000000000159028911097599180468360808563945281389781327557747838772170381060813469985856815104"
    invoke-static {v0, v1}, Lacceptance/TextNumberCastObserver;->expect(Ljava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "STAGE Text numeric width wrapping"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const-string v0, "255"
    invoke-static {v0}, LIdric/Generated;->signed_byte(Ljava/lang/String;)I
    move-result v1
    const/4 v2, -0x1
    if-ne v1, v2, :failed
    const-string v0, "-1"
    invoke-static {v0}, LIdric/Generated;->unsigned_byte(Ljava/lang/String;)I
    move-result v1
    const/16 v2, 0xff
    if-ne v1, v2, :failed
    const-string v0, "128"
    invoke-static {v0}, LIdric/Generated;->signed_byte(Ljava/lang/String;)I
    move-result v1
    const/16 v2, -0x80
    if-ne v1, v2, :failed
    const-string v0, "256"
    invoke-static {v0}, LIdric/Generated;->unsigned_byte(Ljava/lang/String;)I
    move-result v1
    if-nez v1, :failed
    const-string v0, "1+0i"
    invoke-static {v0}, Lacceptance/TextNumberCastObserver;->refuses(Ljava/lang/String;)V
    const-string v0, "1.0|24"
    invoke-static {v0}, Lacceptance/TextNumberCastObserver;->refuses(Ljava/lang/String;)V
    const-string v0, "+inf.0"
    invoke-static {v0}, Lacceptance/TextNumberCastObserver;->refuses(Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS checked Text numeric casts on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
  :failed
    invoke-static {}, Lacceptance/TextNumberCastObserver;->failure()V
    return-void
.end method
