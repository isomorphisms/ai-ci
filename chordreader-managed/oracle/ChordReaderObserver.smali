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
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:A♭R1:112:reading_song2:-11:01:0"
    const-string v1, "1G"
    const-string v2, "FAIL independent chromatic case 1: A♭ -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:A♭R1:112:reading_song2:-21:01:0"
    const-string v1, "1G♭"
    const-string v2, "FAIL independent chromatic case 2: A♭ -2"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:A♭R1:112:reading_song1:11:01:0"
    const-string v1, "1A"
    const-string v2, "FAIL independent chromatic case 3: A♭ 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:A♭R1:112:reading_song1:21:01:0"
    const-string v1, "1B♭"
    const-string v2, "FAIL independent chromatic case 4: A♭ 2"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T1:BR1:112:reading_song1:11:01:0"
    const-string v1, "1C"
    const-string v2, "FAIL independent chromatic case 5: B 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T1:CR1:112:reading_song2:-11:01:0"
    const-string v1, "1B"
    const-string v2, "FAIL independent chromatic case 6: C -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:A/C♯R1:112:reading_song1:11:01:0"
    const-string v1, "1B♭/D"
    const-string v2, "FAIL independent chromatic case 7: A/C♯ 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:A♭R1:112:reading_song2:121:01:0"
    const-string v1, "1A♭"
    const-string v2, "FAIL independent chromatic case 8: A♭ 12"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:A/D♭R1:112:reading_song1:11:01:0"
    const-string v1, "1A♯/D"
    const-string v2, "FAIL independent chromatic case 9: A/D♭ 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:F♯♯mR1:112:reading_song2:121:01:0"
    const-string v1, "1F♯♯m"
    const-string v2, "FAIL independent chromatic case 10: F♯♯m 12"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:C7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1C♯7♭9"
    const-string v2, "FAIL independent chromatic case 11: C7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:CmR1:112:reading_song2:-11:01:0"
    const-string v1, "1Bm"
    const-string v2, "FAIL independent chromatic case 12: Cm -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T5:C♯7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1D7♭9"
    const-string v2, "FAIL independent chromatic case 13: C♯7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T3:C♯mR1:112:reading_song2:-11:01:0"
    const-string v1, "1Cm"
    const-string v2, "FAIL independent chromatic case 14: C♯m -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:D7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1D♯7♭9"
    const-string v2, "FAIL independent chromatic case 15: D7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:DmR1:112:reading_song2:-11:01:0"
    const-string v1, "1D♭m"
    const-string v2, "FAIL independent chromatic case 16: Dm -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T5:E♭7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1E7♭9"
    const-string v2, "FAIL independent chromatic case 17: E♭7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T3:E♭mR1:112:reading_song2:-11:01:0"
    const-string v1, "1Dm"
    const-string v2, "FAIL independent chromatic case 18: E♭m -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:E7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1F7♭9"
    const-string v2, "FAIL independent chromatic case 19: E7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:EmR1:112:reading_song2:-11:01:0"
    const-string v1, "1E♭m"
    const-string v2, "FAIL independent chromatic case 20: Em -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:F7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1F♯7♭9"
    const-string v2, "FAIL independent chromatic case 21: F7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:FmR1:112:reading_song2:-11:01:0"
    const-string v1, "1Em"
    const-string v2, "FAIL independent chromatic case 22: Fm -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T5:F♯7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1G7♭9"
    const-string v2, "FAIL independent chromatic case 23: F♯7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T3:F♯mR1:112:reading_song2:-11:01:0"
    const-string v1, "1Fm"
    const-string v2, "FAIL independent chromatic case 24: F♯m -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:G7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1G♯7♭9"
    const-string v2, "FAIL independent chromatic case 25: G7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:GmR1:112:reading_song2:-11:01:0"
    const-string v1, "1G♭m"
    const-string v2, "FAIL independent chromatic case 26: Gm -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T5:A♭7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1A7♭9"
    const-string v2, "FAIL independent chromatic case 27: A♭7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T3:A♭mR1:112:reading_song2:-11:01:0"
    const-string v1, "1Gm"
    const-string v2, "FAIL independent chromatic case 28: A♭m -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:A7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1A♯7♭9"
    const-string v2, "FAIL independent chromatic case 29: A7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:AmR1:112:reading_song2:-11:01:0"
    const-string v1, "1A♭m"
    const-string v2, "FAIL independent chromatic case 30: Am -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T5:B♭7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1B7♭9"
    const-string v2, "FAIL independent chromatic case 31: B♭7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T3:B♭mR1:112:reading_song2:-11:01:0"
    const-string v1, "1Am"
    const-string v2, "FAIL independent chromatic case 32: B♭m -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T4:B7♭9R1:112:reading_song1:11:01:0"
    const-string v1, "1C7♭9"
    const-string v2, "FAIL independent chromatic case 33: B7♭9 1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    const-string v0, "bChordReader/Idric/1\nP2:202:246:GuitarS1:11:T2:BmR1:112:reading_song2:-11:01:0"
    const-string v1, "1B♭m"
    const-string v2, "FAIL independent chromatic case 34: Bm -1"
    invoke-static {v0, v1, v2}, Lacceptance/ChordReaderObserver;->reply(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    sget-object v0, Ljava/lang/System;->out:Ljava/io/PrintStream;
    const-string v1, "PASS independent ChordReader managed ART: 53 assertions"
    invoke-virtual {v0, v1}, Ljava/io/PrintStream;->println(Ljava/lang/String;)V
    return-void
.end method
