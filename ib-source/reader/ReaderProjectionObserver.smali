.class public final Lacceptance/ReaderProjectionObserver;
.super Ljava/lang/Object;

# Independent observer only. The candidate is emitted from maintained IB Idriç.
.method private static observations()Ljava/lang/String;
    .registers 1
    const-string v0, "fixture\t1\tfc4ee8291bd87c7c4f1bca908b2846fcf801cc92c4e3019310d95ef825f48642\tfc4ee8291bd87c7c4f1bca908b2846fcf801cc92c4e3019310d95ef825f48642\t83\t83\thttps://example.com/a/start\thttps://example.com/a/start\ttext/html\tutf-8\t200\tverified-utf8\tcomplete"
    return-object v0
.end method

.method private static expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    .registers 10
    const-string v0, "<title>café 🦉</title><h1>Hello</h1><p>aaaa bb cc dddd</p><a href=\"next\">Go</a>\n"
    invoke-static {p0, v0, p1, p2}, LIdric/Generated;->project_committed_html(Ljava/lang/String;Ljava/lang/String;II)Ljava/lang/String;
    move-result-object v1
    invoke-virtual {p3, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :passed
    sget-object v0, Ljava/lang/System;->err:Ljava/io/PrintStream;
    const-string v2, "FAIL "
    invoke-virtual {v2, p4}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v0, v2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 73
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
  :passed
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 9
    invoke-static {}, Lacceptance/ReaderProjectionObserver;->observations()Ljava/lang/String;
    move-result-object v0
    const/16 v6, 10
    const/4 v7, 0
    const-string v1, "ib-prepaint\t1\nrevision\t0\tcomplete\nrequested-url\thttps://example.com/a/start\nresolved-url\thttps://example.com/a/start\ntitle\tcafé 🦉\nheading\t1\tHello\ntext\taaaa bb cc dddd\nlink\tGo\thttps://example.com/a/next\nend\n\nsource-codepoint-ranges\n0=0:5;\n1=0:11;11:15;\n2=0:2;\n"
    const-string v5, "greedy-reflow"
    invoke-static {v0, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const/4 v7, 1
    const-string v1, "ib-prepaint\t1\nrevision\t0\tcomplete\nrequested-url\thttps://example.com/a/start\nresolved-url\thttps://example.com/a/start\ntitle\tcafé 🦉\nheading\t1\tHello\ntext\taaaa bb cc dddd\nlink\tGo\thttps://example.com/a/next\nend\n\nsource-codepoint-ranges\n0=0:5;\n1=0:8;8:15;\n2=0:2;\n"
    const-string v5, "squared-reflow"
    invoke-static {v0, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const/4 v7, 0

    const-string v3, "\t83\t83\t"
    const-string v4, "\t83\t82\t"
    invoke-virtual {v0, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v2
    const-string v1, "refused:bad-reopened-byte-count"
    const-string v5, "count-mismatch-refusal"
    invoke-static {v2, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V

    const-string v3, "fc4ee8291bd87c7c4f1bca908b2846fcf801cc92c4e3019310d95ef825f48642\t83"
    const-string v4, "0000000000000000000000000000000000000000000000000000000000000000\t83"
    invoke-virtual {v0, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v2
    const-string v1, "refused:missing-or-mismatched-sha256"
    const-string v5, "digest-mismatch-refusal"
    invoke-static {v2, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V

    const-string v3, "\tutf-8\t"
    const-string v4, "\tunsupported\t"
    invoke-virtual {v0, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v2
    const-string v1, "refused:unsupported-charset"
    const-string v5, "charset-refusal"
    invoke-static {v2, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V

    const-string v3, "\t200\t"
    const-string v4, "\t500\t"
    invoke-virtual {v0, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v2
    const-string v1, "refused:unadmitted-http-status"
    const-string v5, "http-failure-refusal"
    invoke-static {v2, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V

    const-string v3, "\tcomplete"
    const-string v4, "\tincomplete"
    invoke-virtual {v0, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v2
    const-string v1, "refused:incomplete-or-stale-source"
    const-string v5, "incomplete-source-refusal"
    invoke-static {v2, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V

    const-string v3, "verified-utf8"
    const-string v4, "invalid-utf8"
    invoke-virtual {v0, v3, v4}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v2
    const-string v1, "refused:invalid-utf8"
    const-string v5, "utf8-refusal"
    invoke-static {v2, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V

    const/4 v6, 0
    const-string v1, "refused:invalid-viewport-width"
    const-string v5, "zero-width-refusal"
    invoke-static {v0, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    const/16 v6, 10
    const/16 v7, 9
    const-string v1, "refused:unsupported-reflow"
    const-string v5, "unknown-reflow-refusal"
    invoke-static {v0, v6, v7, v1, v5}, Lacceptance/ReaderProjectionObserver;->expect(Ljava/lang/String;IILjava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS checked IB admission, Prepaint and source reflow on ART"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
