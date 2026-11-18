.class public final Lacceptance/admin/AdminEvidence;
.super Ljava/lang/Object;

# Test-only transport. No product debug flag, exported provider, or shell UID.
.method private static require(ZLjava/lang/String;)V
    .locals 1
    if-nez p0, :done
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :done
    return-void
.end method

.method private static identity(Landroid/app/Instrumentation;)I
    .locals 5
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v1
    const-string v2, "org.isomorphisms.ib.prepaint"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :failed
    invoke-virtual {v0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v1
    iget v2, v1, Landroid/content/pm/ApplicationInfo;->uid:I
    invoke-static {}, Landroid/os/Process;->myUid()I
    move-result v3
    if-ne v2, v3, :failed
    const/16 v4, 10000
    if-lt v2, v4, :failed
    iget v3, v1, Landroid/content/pm/ApplicationInfo;->flags:I
    and-int/lit8 v3, v3, 2
    if-nez v3, :failed
    return v2
  :failed
    const/4 v0, 0
    const-string v1, "FAIL observer is not the unchanged non-debuggable target UID"
    invoke-static {v0, v1}, Lacceptance/admin/AdminEvidence;->require(ZLjava/lang/String;)V
    const/4 v0, 0
    return v0
.end method

.method public static preflight(Landroid/app/Instrumentation;)V
    .locals 6
    invoke-static {p0}, Lacceptance/admin/AdminEvidence;->identity(Landroid/app/Instrumentation;)I
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getFilesDir()Ljava/io/File;
    move-result-object v0
    new-instance v1, Ljava/io/File;
    const-string v2, "state/longview-current"
    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->toPath()Ljava/nio/file/Path;
    move-result-object v1
    const-class v2, Ljava/nio/file/attribute/BasicFileAttributes;
    const/4 v3, 1
    new-array v3, v3, [Ljava/nio/file/LinkOption;
    const/4 v4, 0
    sget-object v5, Ljava/nio/file/LinkOption;->NOFOLLOW_LINKS:Ljava/nio/file/LinkOption;
    aput-object v5, v3, v4
  :read_start
    invoke-static {v1, v2, v3}, Ljava/nio/file/Files;->readAttributes(Ljava/nio/file/Path;Ljava/lang/Class;[Ljava/nio/file/LinkOption;)Ljava/nio/file/attribute/BasicFileAttributes;
  :read_end
    .catch Ljava/nio/file/NoSuchFileException; {:read_start .. :read_end} :absent
    const/4 v0, 0
    const-string v1, "FAIL protected admin namespace already has a task"
    invoke-static {v0, v1}, Lacceptance/admin/AdminEvidence;->require(ZLjava/lang/String;)V
    return-void
  :absent
    move-exception v0
    return-void
.end method

.method public static measure(Landroid/app/Instrumentation;)Landroid/os/Bundle;
    .locals 7
    invoke-static {p0}, Lacceptance/admin/AdminEvidence;->identity(Landroid/app/Instrumentation;)I
    move-result v4
    invoke-virtual {p0}, Landroid/app/Instrumentation;->getTargetContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v1
    iget-object v2, v1, Landroid/content/pm/ApplicationInfo;->storageUuid:Ljava/util/UUID;
    if-nez v2, :volume
    sget-object v2, Landroid/os/storage/StorageManager;->UUID_DEFAULT:Ljava/util/UUID;
  :volume
    const-string v1, "storagestats"
    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/app/usage/StorageStatsManager;
    invoke-virtual {v0, v2, v4}, Landroid/app/usage/StorageStatsManager;->queryStatsForUid(Ljava/util/UUID;I)Landroid/app/usage/StorageStats;
    move-result-object v0
    new-instance v1, Landroid/os/Bundle;
    invoke-direct {v1}, Landroid/os/Bundle;-><init>()V
    const-string v2, "target_uid"
    invoke-virtual {v1, v2, v4}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    const-string v2, "target_debuggable"
    const/4 v4, 0
    invoke-virtual {v1, v2, v4}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    invoke-virtual {v0}, Landroid/app/usage/StorageStats;->getDataBytes()J
    move-result-wide v3
    const-string v2, "data_bytes"
    invoke-virtual {v1, v2, v3, v4}, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V
    invoke-virtual {v0}, Landroid/app/usage/StorageStats;->getCacheBytes()J
    move-result-wide v3
    const-string v2, "cache_bytes"
    invoke-virtual {v1, v2, v3, v4}, Landroid/os/Bundle;->putLong(Ljava/lang/String;J)V
    return-object v1
.end method

.method public static exportArtifact(Landroid/app/Instrumentation;Ljava/lang/String;[B)V
    .locals 12
    invoke-static {p0}, Lacceptance/admin/AdminEvidence;->identity(Landroid/app/Instrumentation;)I
    const-string v0, "(?:admin-(?:before-lifecycle|after-lifecycle|before-renderer|after-renderer|after-activity|after-host)\\.task|admin-(?:first-action|after-activity)\\.png|public-(?:search|miwam)\\.png)"
    invoke-virtual {p1, v0}, Ljava/lang/String;->matches(Ljava/lang/String;)Z
    move-result v0
    const-string v1, "FAIL unapproved observer artifact name"
    invoke-static {v0, v1}, Lacceptance/admin/AdminEvidence;->require(ZLjava/lang/String;)V
    array-length v4, p2
    const-string v0, ".task"
    invoke-virtual {p1, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v0
    const v1, 2097152
    if-eqz v0, :limit
    const/16 v1, 8192
  :limit
    if-lez v4, :too_large
    if-gt v4, v1, :too_large
    const-string v0, "SHA-256"
    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;
    move-result-object v0
    invoke-virtual {v0, p2}, Ljava/security/MessageDigest;->digest([B)[B
    move-result-object v0
    new-instance v1, Ljava/math/BigInteger;
    const/4 v2, 1
    invoke-direct {v1, v2, v0}, Ljava/math/BigInteger;-><init>(I[B)V
    new-array v11, v2, [Ljava/lang/Object;
    const/4 v2, 0
    aput-object v1, v11, v2
    const-string v0, "%064x"
    invoke-static {v0, v11}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v1
    const/4 v2, 2
    invoke-static {p2, v2}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v3
    add-int/lit16 v3, v3, 11999
    div-int/lit16 v3, v3, 12000
    const/4 v2, 0
  :chunk
    mul-int/lit16 v5, v2, 12000
    add-int/lit16 v6, v5, 12000
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v9
    invoke-static {v6, v9}, Ljava/lang/Math;->min(II)I
    move-result v6
    new-instance v7, Ljava/lang/StringBuilder;
    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V
    const-string v9, "1\t"
    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v9, "\t"
    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v5, v6}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v9
    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v7
    new-instance v8, Landroid/os/Bundle;
    invoke-direct {v8}, Landroid/os/Bundle;-><init>()V
    const-string v9, "ib_admin_chunk"
    invoke-virtual {v8, v9, v7}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V
    const/4 v9, 0
    invoke-virtual {p0, v9, v8}, Landroid/app/Instrumentation;->sendStatus(ILandroid/os/Bundle;)V
    add-int/lit8 v2, v2, 1
    if-lt v2, v3, :chunk
    return-void
  :too_large
    const/4 v0, 0
    const-string v1, "FAIL observer artifact exceeds bounded transport"
    invoke-static {v0, v1}, Lacceptance/admin/AdminEvidence;->require(ZLjava/lang/String;)V
    return-void
.end method
