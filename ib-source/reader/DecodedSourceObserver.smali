.class public final Lacceptance/DecodedSourceObserver;
.super Ljava/lang/Object;

# Independent literal expectations over the real committed-document export.
.method private static observations()Ljava/lang/String;
    .registers 1
    const-string v0, "arena:windows\t7\tf75de31144f8a4bcd321f0d54f8298fc7d429c8a9213c45c86e1abfc29f01a54\tf75de31144f8a4bcd321f0d54f8298fc7d429c8a9213c45c86e1abfc29f01a54\t35\t35\thttps://example.com/\thttps://example.com/\ttext/html\tiso-8859-1\t200\tinvalid-utf8\tcomplete"
    return-object v0
.end method

.method private static expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .registers 8
    invoke-static {p0, p1}, LIdric/Generated;->project_committed_representation(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :passed
    sget-object v2, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v1, "FAIL "
    invoke-virtual {v1, p3}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v2, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v2, v0}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-static {}, Lacceptance/AssertionFailure;->terminate()V
  :passed
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 10
    invoke-static {}, Lacceptance/DecodedSourceObserver;->observations()Ljava/lang/String;
    move-result-object v0
    const-string v1, "<title>caf\u00e9</title><p>\u0080 \u0093texte\u0094</p>"
    const-string v2, "arena:windows\n7\nf75de31144f8a4bcd321f0d54f8298fc7d429c8a9213c45c86e1abfc29f01a54\niso-8859-1\noriginal-invalid-utf8\nwhatwg-windows-1252-e56d49d9176e9a4-v1:windows-1252\narena:windows;generation=7;sha256=f75de31144f8a4bcd321f0d54f8298fc7d429c8a9213c45c86e1abfc29f01a54;decoder=whatwg-windows-1252-e56d49d9176e9a4-v1;encoding=windows-1252\n€ “texte”"
    const-string v3, "decoded source original evidence and exact selection"
    invoke-static {v0, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v4, "\t200\t"
    const-string v5, "\t404\t"
    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v6
    const-string v2, "refused:unadmitted-http-status"
    const-string v3, "decoded source HTTP status admission"
    invoke-static {v6, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v4, "\t35\t35\t"
    const-string v5, "\t34\t34\t"
    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v6
    const-string v2, "refused:decoded-original-byte-count-mismatch"
    const-string v3, "decoded source actual original octet count"
    invoke-static {v6, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v4, "\t35\t35\t"
    const-string v5, "\t35\t34\t"
    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v6
    const-string v2, "refused:bad-reopened-byte-count"
    const-string v3, "decoded source independently reopened count"
    invoke-static {v6, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v4, "f75de31144f8a4bcd321f0d54f8298fc7d429c8a9213c45c86e1abfc29f01a54\t35"
    const-string v5, "0000000000000000000000000000000000000000000000000000000000000000\t35"
    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v6
    const-string v2, "refused:missing-or-mismatched-sha256"
    const-string v3, "decoded source original digest admission"
    invoke-static {v6, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v4, "\ttext/html\t"
    const-string v5, "\timage/png\t"
    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v6
    const-string v2, "refused:unsupported-mime"
    const-string v3, "decoded source MIME admission"
    invoke-static {v6, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v4, "\tcomplete"
    const-string v5, "\tincomplete"
    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v6
    const-string v2, "refused:incomplete-or-stale-source"
    const-string v3, "decoded source complete acquisition"
    invoke-static {v6, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v4, "iso-8859-1"
    const-string v5, "utf-7"
    invoke-virtual {v0, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v6
    const-string v2, "refused:unsupported-charset"
    const-string v3, "decoded source unsupported encoding"
    invoke-static {v6, v1, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v7, "\u0100"
    const-string v2, "refused:invalid-original-octet-carrier"
    const-string v3, "decoded source octet carrier rejects scalar truncation"
    invoke-static {v0, v7, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    const-string v7, "\u00ef\u00bb\u00bf<p>x</p>"
    const-string v2, "refused:bom-selects-an-unimplemented-decoder"
    const-string v3, "decoded source BOM cannot select the wrong decoder"
    invoke-static {v0, v7, v2, v3}, Lacceptance/DecodedSourceObserver;->expect(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent committed non-UTF-8 admission original evidence derivative identity and exact selected text"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
