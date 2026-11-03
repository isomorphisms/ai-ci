.class public final Lacceptance/presentation/IbUiTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field public activity:Landroid/app/Activity;
.field public phase:I
.field private body:Landroid/widget/TextView;
.field private text:Ljava/lang/String;
.field private selectionStart:I
.field private selectionEnd:I
.field private scroll:I
.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/IbUiTask;->activity:Landroid/app/Activity;
    return-void
.end method
.method private require(ZLjava/lang/String;)V
    .locals 1
    if-nez p1, :ok
    new-instance v0, Ljava/lang/AssertionError;
    invoke-direct {v0, p2}, Ljava/lang/AssertionError;-><init>(Ljava/lang/Object;)V
    throw v0
  :ok
    return-void
.end method
.method private view(I)Landroid/view/View;
    .locals 1
    iget-object v0, p0, Lacceptance/presentation/IbUiTask;->activity:Landroid/app/Activity;
    invoke-virtual {v0, p1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v0
    return-object v0
.end method
.method private click(I)V
    .locals 3
    invoke-direct {p0, p1}, Lacceptance/presentation/IbUiTask;->view(I)Landroid/view/View;
    move-result-object v0
    instance-of v1, v0, Landroid/widget/Button;
    const-string v2, "FAIL IB action is not an actual framework Button"
    invoke-direct {p0, v1, v2}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    invoke-virtual {v0}, Landroid/view/View;->performClick()Z
    move-result v1
    const-string v2, "FAIL IB Button did not dispatch"
    invoke-direct {p0, v1, v2}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    return-void
.end method
.method public run()V
    .locals 7
    const v0, 0x7f03000e
    invoke-direct {p0, v0}, Lacceptance/presentation/IbUiTask;->view(I)Landroid/view/View;
    move-result-object v0
    check-cast v0, Landroid/widget/ScrollView;
    const v1, 0x7f030010
    invoke-direct {p0, v1}, Lacceptance/presentation/IbUiTask;->view(I)Landroid/view/View;
    move-result-object v1
    const v2, 0x7f03000f
    iget v3, p0, Lacceptance/presentation/IbUiTask;->phase:I
    if-eqz v3, :capture
    const/4 v4, 0x1
    if-eq v3, v4, :history
    const/4 v4, 0x2
    if-eq v3, v4, :return_reader
    const/4 v4, 0x3
    if-eq v3, v4, :select
    goto :selected
  :capture
    const v3, 0x7f030000
    invoke-direct {p0, v3}, Lacceptance/presentation/IbUiTask;->view(I)Landroid/view/View;
    move-result-object v3
    check-cast v3, Landroid/widget/TextView;
    iput-object v3, p0, Lacceptance/presentation/IbUiTask;->body:Landroid/widget/TextView;
    invoke-virtual {v3}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v4
    invoke-interface {v4}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v5
    iput-object v5, p0, Lacceptance/presentation/IbUiTask;->text:Ljava/lang/String;
    invoke-virtual {v5}, Ljava/lang/String;->length()I
    move-result v5
    const/4 v6, 0
    if-lez v5, :body_empty
    const/4 v6, 1
  :body_empty
    const-string v5, "FAIL IB retained reader has no text"
    invoke-direct {p0, v6, v5}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    instance-of v5, v4, Landroid/text/Spannable;
    const-string v6, "FAIL IB reader is not selectable"
    invoke-direct {p0, v5, v6}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    check-cast v4, Landroid/text/Spannable;
    const/4 v5, 0
    const/4 v6, 1
    invoke-static {v4, v5, v6}, Landroid/text/Selection;->setSelection(Landroid/text/Spannable;II)V
    invoke-virtual {v3}, Landroid/widget/TextView;->getSelectionStart()I
    move-result v4
    iput v4, p0, Lacceptance/presentation/IbUiTask;->selectionStart:I
    invoke-virtual {v3}, Landroid/widget/TextView;->getSelectionEnd()I
    move-result v4
    iput v4, p0, Lacceptance/presentation/IbUiTask;->selectionEnd:I
    invoke-virtual {v0}, Landroid/view/View;->getScrollY()I
    move-result v4
    iput v4, p0, Lacceptance/presentation/IbUiTask;->scroll:I
    return-void
  :history
    invoke-direct {p0, v2}, Lacceptance/presentation/IbUiTask;->click(I)V
    invoke-virtual {v1}, Landroid/view/View;->getVisibility()I
    move-result v3
    const/4 v4, 0
    if-nez v3, :history_bad
    invoke-virtual {v0}, Landroid/view/View;->getVisibility()I
    move-result v3
    const/16 v5, 0x8
    if-ne v3, v5, :history_bad
    const/4 v4, 1
  :history_bad
    const-string v5, "FAIL IB history did not replace the visible reader pane"
    invoke-direct {p0, v4, v5}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    return-void
  :return_reader
    invoke-direct {p0, v2}, Lacceptance/presentation/IbUiTask;->click(I)V
    const v3, 0x7f030000
    invoke-direct {p0, v3}, Lacceptance/presentation/IbUiTask;->view(I)Landroid/view/View;
    move-result-object v3
    iget-object v4, p0, Lacceptance/presentation/IbUiTask;->body:Landroid/widget/TextView;
    const/4 v5, 0
    if-ne v3, v4, :view_bad
    invoke-virtual {v1}, Landroid/view/View;->getVisibility()I
    move-result v3
    const/16 v6, 0x8
    if-ne v3, v6, :view_bad
    invoke-virtual {v0}, Landroid/view/View;->getVisibility()I
    move-result v3
    if-nez v3, :view_bad
    const/4 v5, 1
  :view_bad
    const-string v6, "FAIL IB history reconstructed or lost its reader View"
    invoke-direct {p0, v5, v6}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    invoke-virtual {v4}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;
    move-result-object v3
    invoke-interface {v3}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v3
    iget-object v5, p0, Lacceptance/presentation/IbUiTask;->text:Ljava/lang/String;
    invoke-virtual {v5, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    const-string v5, "FAIL IB history changed projected reader text"
    invoke-direct {p0, v3, v5}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    invoke-virtual {v0}, Landroid/view/View;->getScrollY()I
    move-result v3
    iget v5, p0, Lacceptance/presentation/IbUiTask;->scroll:I
    const/4 v6, 0
    if-ne v3, v5, :position_bad
    invoke-virtual {v4}, Landroid/widget/TextView;->getSelectionStart()I
    move-result v3
    iget v5, p0, Lacceptance/presentation/IbUiTask;->selectionStart:I
    if-ne v3, v5, :position_bad
    invoke-virtual {v4}, Landroid/widget/TextView;->getSelectionEnd()I
    move-result v3
    iget v5, p0, Lacceptance/presentation/IbUiTask;->selectionEnd:I
    if-ne v3, v5, :position_bad
    const/4 v6, 1
  :position_bad
    const-string v5, "FAIL IB history lost selection or scroll position"
    invoke-direct {p0, v6, v5}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    return-void
  :select
    invoke-direct {p0, v2}, Lacceptance/presentation/IbUiTask;->click(I)V
    const v3, 0x00f10000
    invoke-direct {p0, v3}, Lacceptance/presentation/IbUiTask;->click(I)V
    return-void
  :selected
    invoke-virtual {v1}, Landroid/view/View;->getVisibility()I
    move-result v3
    const/16 v4, 0x8
    const/4 v5, 0
    if-ne v3, v4, :selected_bad
    invoke-virtual {v0}, Landroid/view/View;->getVisibility()I
    move-result v3
    if-nez v3, :selected_bad
    const/4 v5, 1
  :selected_bad
    const-string v6, "FAIL IB retained source action did not return to reader"
    invoke-direct {p0, v5, v6}, Lacceptance/presentation/IbUiTask;->require(ZLjava/lang/String;)V
    return-void
.end method
