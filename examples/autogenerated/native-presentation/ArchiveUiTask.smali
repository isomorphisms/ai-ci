.class public final Lacceptance/presentation/ArchiveUiTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field public activity:Landroid/app/Activity;
.field public phase:I
.field public ready:Z
.field public refused:Z
.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/ArchiveUiTask;->activity:Landroid/app/Activity;
    return-void
.end method
.method private static require(ZLjava/lang/String;)V
    .locals 1
    if-nez p0, :ok
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :ok
    return-void
.end method
.method private static walk(Landroid/view/View;)V
    .locals 3
    instance-of v0, p0, Landroid/webkit/WebView;
    if-nez v0, :bad
    instance-of v0, p0, Landroid/widget/EditText;
    if-eqz v0, :children
  :bad
    new-instance v0, Ljava/lang/AssertionError;
    const-string v1, "FAIL archive read-only entry has acquisition or composer View"
    invoke-direct {v0, v1}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :children
    instance-of v0, p0, Landroid/view/ViewGroup;
    if-eqz v0, :done
    check-cast p0, Landroid/view/ViewGroup;
    const/4 v0, 0
  :loop
    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1
    if-ge v0, v1, :done
    invoke-virtual {p0, v0}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v2
    invoke-static {v2}, Lacceptance/presentation/ArchiveUiTask;->walk(Landroid/view/View;)V
    add-int/lit8 v0, v0, 1
    goto :loop
  :done
    return-void
.end method
.method public run()V
    .locals 8
    iget-object v0, p0, Lacceptance/presentation/ArchiveUiTask;->activity:Landroid/app/Activity;
    const/16 v1, 1010
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v2
    check-cast v2, Landroid/widget/TextView;
    if-eqz v2, :done
    invoke-virtual {v2}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v2
    invoke-interface {v2}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "Saved archive refused:"
    invoke-virtual {v2, v3}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    iput-boolean v3, p0, Lacceptance/presentation/ArchiveUiTask;->refused:Z
    if-eqz v3, :verified
    const/16 v1, 1011
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Landroid/widget/TextView;
    invoke-virtual {v1}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->length()I
    move-result v1
    const/4 v3, 1
    if-eqz v1, :empty
    const/4 v3, 0
  :empty
    const-string v1, "FAIL corrupt archive exposed retained content"
    invoke-static {v3, v1}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    invoke-static {v1}, Lacceptance/presentation/ArchiveUiTask;->walk(Landroid/view/View;)V
  :verified
    const-string v3, "Read-only saved conversation 1/1"
    invoke-virtual {v2, v3}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v3
    iput-boolean v3, p0, Lacceptance/presentation/ArchiveUiTask;->ready:Z
    if-eqz v3, :done
    iget v3, p0, Lacceptance/presentation/ArchiveUiTask;->phase:I
    const/4 v4, 1
    if-eq v3, v4, :branches
    const/4 v4, 2
    if-eq v3, v4, :all
    const/4 v4, 3
    if-eq v3, v4, :copy
    const/4 v4, 4
    if-eq v3, v4, :close
    const-string v3, "Selected parent path: message 1/1"
    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    const-string v4, "FAIL actual selected archive path"
    invoke-static {v3, v4}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    const-string v3, "Message ID: message-1"
    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    const-string v4, "FAIL actual archive message identity"
    invoke-static {v3, v4}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    const-string v3, "Role: assistant"
    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    const-string v4, "FAIL actual archive author role"
    invoke-static {v3, v4}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    const-string v3, "Source SHA-256: [0-9a-f]{64}"
    invoke-static {v3}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;
    move-result-object v3
    invoke-virtual {v3, v2}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;
    move-result-object v3
    invoke-virtual {v3}, Ljava/util/regex/Matcher;->find()Z
    move-result v3
    const-string v4, "FAIL actual archive source provenance"
    invoke-static {v3, v4}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v3
    invoke-virtual {v3}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v3
    invoke-static {v3}, Lacceptance/presentation/ArchiveUiTask;->walk(Landroid/view/View;)V
    goto :content
  :branches
    const/16 v1, 1006
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/View;->performClick()Z
    return-void
  :all
    const-string v3, "All branches (inventory order)"
    invoke-virtual {v2, v3}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    const-string v4, "FAIL actual archive inventory mode"
    invoke-static {v3, v4}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
  :content
    const/16 v1, 1011
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Landroid/widget/TextView;
    invoke-virtual {v1}, Landroid/widget/TextView;->isTextSelectable()Z
    move-result v2
    const-string v3, "FAIL actual archive text selection"
    invoke-static {v2, v3}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    invoke-virtual {v1}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v2
    invoke-interface {v2}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v3, "Synthetic Android capture"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    const-string v3, "FAIL actual archive source text"
    invoke-static {v2, v3}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    return-void
  :copy
    const/16 v1, 1011
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Landroid/widget/TextView;
    invoke-virtual {v1}, Landroid/widget/TextView;->requestFocus()Z
    invoke-virtual {v1}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v2
    check-cast v2, Landroid/text/Spannable;
    const/4 v3, 0
    const/16 v4, 25
    invoke-static {v2, v3, v4}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;II)V
    const v3, 0x1020021
    invoke-virtual {v1, v3}, Landroid/widget/TextView;->onTextContextMenuItem(I)Z
    move-result v2
    const-string v3, "FAIL actual framework copy action"
    invoke-static {v2, v3}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    const-string v1, "clipboard"
    invoke-virtual {v0, v1}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/content/ClipboardManager;
    invoke-virtual {v1}, Landroid/content/ClipboardManager;->getPrimaryClip()Landroid/content/ClipData;
    move-result-object v1
    const/4 v2, 0
    invoke-virtual {v1, v2}, Landroid/content/ClipData;->getItemAt(I)Landroid/content/ClipData$Item;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/ClipData$Item;->getText()Ljava/lang/CharSequence;
    move-result-object v1
    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "Synthetic Android capture"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    const-string v2, "FAIL actual source-faithful archive clipboard"
    invoke-static {v1, v2}, Lacceptance/presentation/ArchiveUiTask;->require(ZLjava/lang/String;)V
    return-void
  :close
    const/16 v1, 1008
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/View;->performClick()Z
  :done
    return-void
.end method
