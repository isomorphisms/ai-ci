.class public final Lacceptance/presentation/ImeTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field public owner:Landroid/app/Activity;
.field public editor:Landroid/widget/EditText;
.field public stage:I
.field public broken:Z
.field public height:I
.field public bottom:I
.field public focused:Z
.field public text:Ljava/lang/String;

.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/ImeTask;->owner:Landroid/app/Activity;
    return-void
.end method
.method private static find(Landroid/view/View;I)Landroid/widget/EditText;
    .locals 4
    const/16 v0, 0x10
    if-ge p1, v0, :none
    instance-of v0, p0, Landroid/widget/EditText;
    if-eqz v0, :group
    check-cast p0, Landroid/widget/EditText;
    return-object p0
  :group
    instance-of v0, p0, Landroid/view/ViewGroup;
    if-eqz v0, :none
    check-cast p0, Landroid/view/ViewGroup;
    invoke-virtual {p0}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1
    const/16 v0, 0x40
    if-gt v1, v0, :none
    const/4 v0, 0
  :child
    if-ge v0, v1, :none
    invoke-virtual {p0, v0}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v2
    add-int/lit8 v3, p1, 1
    invoke-static {v2, v3}, Lacceptance/presentation/ImeTask;->find(Landroid/view/View;I)Landroid/widget/EditText;
    move-result-object v2
    if-eqz v2, :next
    return-object v2
  :next
    add-int/lit8 v0, v0, 1
    goto :child
  :none
    const/4 v0, 0
    return-object v0
.end method
.method public run()V
    .locals 6
    iget-object v0, p0, Lacceptance/presentation/ImeTask;->owner:Landroid/app/Activity;
    const v1, 0x1020002
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :done
    iget-object v2, p0, Lacceptance/presentation/ImeTask;->editor:Landroid/widget/EditText;
    if-nez v2, :found
    const/4 v2, 0
    invoke-static {v1, v2}, Lacceptance/presentation/ImeTask;->find(Landroid/view/View;I)Landroid/widget/EditText;
    move-result-object v2
    iput-object v2, p0, Lacceptance/presentation/ImeTask;->editor:Landroid/widget/EditText;
  :found
    if-eqz v2, :done
    iget v3, p0, Lacceptance/presentation/ImeTask;->stage:I
    const/4 v4, 1
    if-eq v3, v4, :show
    if-nez v3, :measure
    iget-boolean v3, p0, Lacceptance/presentation/ImeTask;->broken:Z
    if-eqz v3, :measure
    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v0
    const/16 v3, 0x30
    invoke-virtual {v0, v3}, Landroid/view/Window;->setSoftInputMode(I)V
    goto :measure
  :show
    const-string v3, "Türkçe é שלום\n"
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V
    invoke-virtual {v3}, Ljava/lang/String;->length()I
    move-result v3
    invoke-virtual {v2, v3}, Landroid/widget/EditText;->setSelection(I)V
    invoke-virtual {v2}, Landroid/widget/EditText;->requestFocus()Z
    const-string v3, "input_method"
    invoke-virtual {v0, v3}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/view/inputmethod/InputMethodManager;
    invoke-virtual {v0, v2, v4}, Landroid/view/inputmethod/InputMethodManager;->showSoftInput(Landroid/view/View;I)Z
  :measure
    invoke-virtual {v1}, Landroid/view/View;->getHeight()I
    move-result v0
    iput v0, p0, Lacceptance/presentation/ImeTask;->height:I
    const/4 v0, 2
    new-array v0, v0, [I
    invoke-virtual {v2, v0}, Landroid/widget/EditText;->getLocationOnScreen([I)V
    const/4 v1, 1
    aget v0, v0, v1
    invoke-virtual {v2}, Landroid/widget/EditText;->getHeight()I
    move-result v1
    add-int/2addr v0, v1
    iput v0, p0, Lacceptance/presentation/ImeTask;->bottom:I
    invoke-virtual {v2}, Landroid/widget/EditText;->hasFocus()Z
    move-result v0
    iput-boolean v0, p0, Lacceptance/presentation/ImeTask;->focused:Z
    invoke-virtual {v2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;
    move-result-object v0
    invoke-interface {v0}, Landroid/text/Editable;->toString()Ljava/lang/String;
    move-result-object v0
    iput-object v0, p0, Lacceptance/presentation/ImeTask;->text:Ljava/lang/String;
  :done
    return-void
.end method
