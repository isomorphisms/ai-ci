.class public final Lacceptance/shizuku/GoogleResultPoint;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private activity:Landroid/app/Activity;
.field public x:F
.field public y:F
.field public problem:Ljava/lang/String;
.field public target:Ljava/lang/String;
.field public excluded:Ljava/lang/String;
.field private bestOffset:I
.field private positioned:Z
.field private settleUntil:J
.field private originalDisplay:Ljava/lang/String;

.method public constructor <init>(Landroid/app/Activity;)V
    .registers 3
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/shizuku/GoogleResultPoint;->activity:Landroid/app/Activity;
    const/4 v0, -0x1
    iput v0, p0, Lacceptance/shizuku/GoogleResultPoint;->bestOffset:I
    return-void
.end method

.method private static stopParentScroll(Landroid/widget/TextView;)Z
    .registers 4
    invoke-virtual {p0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v0
    instance-of v1, v0, Landroid/widget/ScrollView;
    if-eqz v1, :unsupported
    check-cast v0, Landroid/widget/ScrollView;
    invoke-virtual {v0}, Landroid/view/View;->getScrollX()I
    move-result v1
    invoke-virtual {v0}, Landroid/view/View;->getScrollY()I
    move-result v2
    # Two same-clock public calls abort a residual zero-distance scroller.
    invoke-virtual {v0, v1, v2}, Landroid/widget/ScrollView;->smoothScrollTo(II)V
    invoke-virtual {v0, v1, v2}, Landroid/widget/ScrollView;->smoothScrollTo(II)V
    const/4 v0, 0x1
    return v0
  :unsupported
    const/4 v0, 0x0
    return v0
.end method


.method private static privateField(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    .registers 5
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;
    move-result-object v0
    invoke-virtual {v0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;
    move-result-object v1
    const/4 v2, 1
    invoke-virtual {v1, v2}, Ljava/lang/reflect/Field;->setAccessible(Z)V
    invoke-virtual {v1, p0}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0
    return-object v0
.end method

.method private static googleHost(Ljava/lang/String;)Z
    .registers 4
    if-eqz p0, :yes
    const-string v0, "google.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :yes
    const-string v0, ".google.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :yes
    const-string v0, "gstatic.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :yes
    const-string v0, ".gstatic.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :yes
    const-string v0, "googleusercontent.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :yes
    const-string v0, ".googleusercontent.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :yes
    const-string v0, "googleadservices.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :yes
    const-string v0, ".googleadservices.com"
    invoke-virtual {p0, v0}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :yes
    const/4 v0, 0
    return v0
  :yes
    const/4 v0, 1
    return v0
.end method

.method private static destination(Ljava/lang/String;)Ljava/lang/String;
    .registers 8
    invoke-static {p0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0
    invoke-virtual {v0}, Landroid/net/Uri;->getHost()Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lacceptance/shizuku/GoogleResultPoint;->googleHost(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :direct
    invoke-virtual {v0}, Landroid/net/Uri;->getPath()Ljava/lang/String;
    move-result-object v1
    const-string v2, "/url"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :invalid
    const-string v1, "url"
    invoke-virtual {v0, v1}, Landroid/net/Uri;->getQueryParameter(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    if-nez v3, :validate
    const-string v1, "q"
    invoke-virtual {v0, v1}, Landroid/net/Uri;->getQueryParameter(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    goto :validate
  :direct
    move-object v3, p0
  :validate
    if-eqz v3, :invalid
    invoke-static {v3}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v0
    invoke-virtual {v0}, Landroid/net/Uri;->getScheme()Ljava/lang/String;
    move-result-object v1
    const-string v2, "https"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :host
    const-string v2, "http"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-eqz v2, :invalid
  :host
    invoke-virtual {v0}, Landroid/net/Uri;->getHost()Ljava/lang/String;
    move-result-object v1
    invoke-static {v1}, Lacceptance/shizuku/GoogleResultPoint;->googleHost(Ljava/lang/String;)Z
    move-result v2
    if-nez v2, :invalid
    return-object v3
  :invalid
    const/4 v0, 0
    return-object v0
.end method

.method private findOffset(Landroid/widget/TextView;Ljava/lang/String;)I
    .registers 14
    const-string v0, "projection"
    invoke-static {p1, v0}, Lacceptance/shizuku/GoogleResultPoint;->privateField(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    if-eqz v0, :invalid
    const-string v1, "displayText"
    invoke-static {v0, v1}, Lacceptance/shizuku/GoogleResultPoint;->privateField(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    invoke-virtual {p2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :invalid
    const-string v1, "coordinatesText"
    invoke-static {v0, v1}, Lacceptance/shizuku/GoogleResultPoint;->privateField(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Ljava/lang/String;
    const-string v1, "\n"
    const/4 v2, -1
    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v0
    const/4 v1, 0
    aget-object v3, v0, v1
    const-string v4, "IBP1"
    invoke-virtual {v4, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-eqz v3, :invalid
    const/4 v1, 1
    array-length v2, v0
  :next
    if-ge v1, v2, :finished
    aget-object v3, v0, v1
    invoke-virtual {v3}, Ljava/lang/String;->length()I
    move-result v4
    if-eqz v4, :advance
    const-string v4, "\t"
    const/4 v5, -1
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v4
    array-length v5, v4
    const/4 v6, 6
    if-ne v5, v6, :invalid
    const/4 v5, 5
    aget-object v6, v4, v5
    invoke-static {v6}, Lacceptance/shizuku/GoogleResultPoint;->destination(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v7
    if-eqz v7, :advance
    iget-object v8, p0, Lacceptance/shizuku/GoogleResultPoint;->excluded:Ljava/lang/String;
    if-eqz v8, :eligible_target
    new-instance v9, Ljava/lang/StringBuilder;
    const-string v10, "\n"
    invoke-direct {v9, v10}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v9, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v9
    invoke-virtual {v8, v9}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v8
    if-nez v8, :advance
  :eligible_target
    const/4 v5, 0
    aget-object v8, v4, v5
    invoke-static {v8}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v8
    if-ltz v8, :invalid
    const/4 v5, 1
    aget-object v9, v4, v5
    invoke-static {v9}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v9
    if-le v9, v8, :invalid
    add-int/lit8 v10, v8, 1
    if-ge v10, v9, :offset_ready
    invoke-virtual {p2, v8}, Ljava/lang/String;->charAt(I)C
    move-result v5
    invoke-static {v5}, Ljava/lang/Character;->isHighSurrogate(C)Z
    move-result v5
    if-eqz v5, :simple_offset
    add-int/lit8 v10, v8, 2
  :simple_offset
    if-ge v10, v9, :offset_ready
    move v8, v10
  :offset_ready
    iget v5, p0, Lacceptance/shizuku/GoogleResultPoint;->bestOffset:I
    if-gez v5, :prefer
    iput v8, p0, Lacceptance/shizuku/GoogleResultPoint;->bestOffset:I
    iput-object v6, p0, Lacceptance/shizuku/GoogleResultPoint;->target:Ljava/lang/String;
  :prefer
    const-string v5, "https://en.wikipedia.org/"
    invoke-virtual {v7, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v5
    if-eqz v5, :advance
    iput-object v6, p0, Lacceptance/shizuku/GoogleResultPoint;->target:Ljava/lang/String;
    return v8
  :advance
    add-int/lit8 v1, v1, 1
    goto :next
  :finished
    iget v0, p0, Lacceptance/shizuku/GoogleResultPoint;->bestOffset:I
    return v0
  :invalid
    const/4 v0, -1
    return v0
.end method

.method public run()V
    .registers 14
  :begin
    iget-object v0, p0, Lacceptance/shizuku/GoogleResultPoint;->activity:Landroid/app/Activity;
    const v1, 0x7f030000
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    check-cast v0, Landroid/widget/TextView;
    invoke-virtual {v0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    iget-object v11, p0, Lacceptance/shizuku/GoogleResultPoint;->originalDisplay:Ljava/lang/String;
    if-nez v11, :same_source
    iput-object v1, p0, Lacceptance/shizuku/GoogleResultPoint;->originalDisplay:Ljava/lang/String;
    goto :source_ready
  :same_source
    invoke-virtual {v11, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v11
    if-eqz v11, :changed_source
  :source_ready
    const/4 v11, -0x1
    iput v11, p0, Lacceptance/shizuku/GoogleResultPoint;->bestOffset:I
    invoke-direct {p0, v0, v1}, Lacceptance/shizuku/GoogleResultPoint;->findOffset(Landroid/widget/TextView;Ljava/lang/String;)I
    move-result v2
    if-ltz v2, :failed
    iget-boolean v11, p0, Lacceptance/shizuku/GoogleResultPoint;->positioned:Z
    if-nez v11, :positioned
    invoke-virtual {v0, v2}, Landroid/widget/TextView;->bringPointIntoView(I)Z
    const/4 v11, 0x1
    iput-boolean v11, p0, Lacceptance/shizuku/GoogleResultPoint;->positioned:Z
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v6
    const-wide/16 v8, 0x1f4
    add-long/2addr v6, v8
    iput-wide v6, p0, Lacceptance/shizuku/GoogleResultPoint;->settleUntil:J
    goto :failed
  :positioned
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v6
    iget-wide v8, p0, Lacceptance/shizuku/GoogleResultPoint;->settleUntil:J
    cmp-long v10, v6, v8
    if-ltz v10, :failed
    invoke-static {v0}, Lacceptance/shizuku/GoogleResultPoint;->stopParentScroll(Landroid/widget/TextView;)Z
    move-result v7
    if-eqz v7, :failed
    invoke-virtual {v0}, Landroid/widget/TextView;->getLayout()Landroid/text/Layout;
    move-result-object v1
    if-eqz v1, :failed
    invoke-virtual {v1, v2}, Landroid/text/Layout;->getLineForOffset(I)I
    move-result v3
    invoke-virtual {v1, v3}, Landroid/text/Layout;->getLineTop(I)I
    move-result v4
    invoke-virtual {v1, v3}, Landroid/text/Layout;->getLineBottom(I)I
    move-result v5
    add-int/2addr v4, v5
    div-int/lit8 v4, v4, 0x2
    invoke-virtual {v1, v2}, Landroid/text/Layout;->getPrimaryHorizontal(I)F
    move-result v5
    invoke-virtual {v0}, Landroid/widget/TextView;->getTotalPaddingLeft()I
    move-result v6
    invoke-virtual {v0}, Landroid/view/View;->getScrollX()I
    move-result v7
    sub-int/2addr v6, v7
    int-to-float v6, v6
    add-float/2addr v5, v6
    invoke-virtual {v0}, Landroid/widget/TextView;->getTotalPaddingTop()I
    move-result v6
    invoke-virtual {v0}, Landroid/view/View;->getScrollY()I
    move-result v7
    sub-int/2addr v6, v7
    add-int/2addr v4, v6
    int-to-float v4, v4
    # Independent SDK inverse hit-test must identify the chosen display point.
    invoke-virtual {v0, v5, v4}, Landroid/widget/TextView;->getOffsetForPosition(FF)I
    move-result v7
    if-ne v7, v2, :failed
    const/4 v6, 0x2
    new-array v6, v6, [I
    invoke-virtual {v0, v6}, Landroid/view/View;->getLocationOnScreen([I)V
    const/4 v7, 0x0
    aget v7, v6, v7
    int-to-float v7, v7
    add-float/2addr v5, v7
    const/4 v7, 0x1
    aget v7, v6, v7
    int-to-float v7, v7
    add-float/2addr v4, v7
    invoke-virtual {v0}, Landroid/view/View;->isShown()Z
    move-result v7
    if-eqz v7, :failed
    new-instance v8, Landroid/graphics/Rect;
    invoke-direct {v8}, Landroid/graphics/Rect;-><init>()V
    invoke-virtual {v0, v8}, Landroid/view/View;->getGlobalVisibleRect(Landroid/graphics/Rect;)Z
    move-result v7
    if-eqz v7, :failed
    float-to-int v9, v5
    float-to-int v10, v4
    invoke-virtual {v8, v9, v10}, Landroid/graphics/Rect;->contains(II)Z
    move-result v7
    if-eqz v7, :failed
    iput v5, p0, Lacceptance/shizuku/GoogleResultPoint;->x:F
    iput v4, p0, Lacceptance/shizuku/GoogleResultPoint;->y:F
    const/4 v11, 0x0
    iput-object v11, p0, Lacceptance/shizuku/GoogleResultPoint;->problem:Ljava/lang/String;
    return-void
  :changed_source
    const-string v0, "FAIL Google source changed while settling the actual touch viewport"
    iput-object v0, p0, Lacceptance/shizuku/GoogleResultPoint;->problem:Ljava/lang/String;
    return-void
  :failed
    const-string v0, "FAIL Google response has no visible public result link"
    iput-object v0, p0, Lacceptance/shizuku/GoogleResultPoint;->problem:Ljava/lang/String;
    return-void
  :end
    .catch Ljava/lang/Throwable; {:begin .. :end} :caught
  :caught
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/shizuku/GoogleResultPoint;->problem:Ljava/lang/String;
    return-void
.end method
