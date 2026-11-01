.class public final Lacceptance/ChordReaderObserver;
.super Ljava/lang/Object;

# Independent black-box oracle. Every result is returned by the supplied
# compiler-produced application_request export; no music implementation lives here.
.method private static reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .registers 6
    invoke-static {p0}, LIdric/Generated;->application_request(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :ok
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    invoke-virtual {v0, p2}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x5d
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    :ok
    return-void
.end method

.method private static refuse(Ljava/lang/String;)V
    .registers 4
    invoke-static {p0}, LIdric/Generated;->application_request(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    const-string v1, "0"
    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :ok
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "FAIL independent ChordReader malformed-input refusal"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    const/16 v0, 0x5e
    invoke-static {v0}, Ljava/lang/System;->exit(I)V
    :ok
    return-void
.end method

.method public static main([Ljava/lang/String;)V
    .registers 4
    const-string v0, "r1:11:14:A/C♯"
    const-string v1, "1B♭/D"
    const-string v2, "FAIL independent ChordReader written minor second"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "pA/D♭"
    const-string v1, "1A/D♭"
    const-string v2, "FAIL independent ChordReader intentional chromatic spelling"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "pC#7b9"
    const-string v1, "1C♯7♭9"
    const-string v2, "FAIL independent ChordReader extensions"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "pG7(b9,#11)"
    const-string v1, "1G7♭9♯11"
    const-string v2, "FAIL independent ChordReader recursive grouped alterations"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "pF𝄪m"
    const-string v1, "1F♯♯m"
    const-string v2, "FAIL independent ChordReader supplementary accidental"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "pCm(maj7)"
    const-string v1, "1CmΔ7"
    const-string v2, "FAIL independent ChordReader minor major quality"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "r1:01:04:A/C♯"
    const-string v1, "1A/C♯"
    const-string v2, "FAIL independent ChordReader zero interval preserves slash spelling"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "r2:-12:-11:C"
    const-string v1, "1B"
    const-string v2, "FAIL independent ChordReader descending written interval"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "k7:A major8:B♭ major"
    const-string v1, "11\t1\tA major\tB♭ major"
    const-string v2, "FAIL independent ChordReader declared major keys"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "k7:A minor7:B minor"
    const-string v1, "11\t2\tA minor\tB minor"
    const-string v2, "FAIL independent ChordReader declared minor keys"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "nA♭ major"
    const-string v1, "1A♭ major"
    const-string v2, "FAIL independent ChordReader flat tonic identity"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "c🧪 [A/C♯] la\n"
    const-string v1, "13\t7\t6\t12\t4\t8\tA/C♯\t9|C|1\n"
    const-string v2, "FAIL independent ChordReader Unicode chart offsets"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "e2:242:101:0"
    const-string v1, "10\t240"
    const-string v2, "FAIL independent ChordReader fractional scrolling"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "g7:Ukulele1:C7:0 0 0 3"
    const-string v1, "1C\t0,0,0,3"
    const-string v2, "FAIL independent ChordReader custom fingering"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "k7:A minor7:B major"
    invoke-static {v0}, Lacceptance/ChordReaderObserver;->refuse(Ljava/lang/String;)V
    const-string v0, "pAmazing"
    invoke-static {v0}, Lacceptance/ChordReaderObserver;->refuse(Ljava/lang/String;)V
    const-string v0, "r20:x"
    invoke-static {v0}, Lacceptance/ChordReaderObserver;->refuse(Ljava/lang/String;)V
    const-string v0, "g7:Ukulele1:C13:0 wrong 0 0 3"
    invoke-static {v0}, Lacceptance/ChordReaderObserver;->refuse(Ljava/lang/String;)V
    const-string v0, "vnot a library"
    invoke-static {v0}, Lacceptance/ChordReaderObserver;->refuse(Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent ChordReader managed ART: 19 assertions"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
