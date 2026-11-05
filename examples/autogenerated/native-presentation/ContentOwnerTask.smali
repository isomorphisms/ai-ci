.class public final Lacceptance/presentation/ContentOwnerTask;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.field private owner:Landroid/app/Activity;
.field public attached:Z
.field public settings:Z
.field public mutation:I
.field public failure:Ljava/lang/String;
.field private count:I
.field private edits:I

.method public constructor <init>(Landroid/app/Activity;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lacceptance/presentation/ContentOwnerTask;->owner:Landroid/app/Activity;
    return-void
.end method
.method public run()V
    .locals 9
    const/4 v0, 0
    iput-boolean v0, p0, Lacceptance/presentation/ContentOwnerTask;->attached:Z
    iput v0, p0, Lacceptance/presentation/ContentOwnerTask;->count:I
    iput v0, p0, Lacceptance/presentation/ContentOwnerTask;->edits:I
    iput-object v0, p0, Lacceptance/presentation/ContentOwnerTask;->failure:Ljava/lang/String;
    iget-object v0, p0, Lacceptance/presentation/ContentOwnerTask;->owner:Landroid/app/Activity;
    const/16 v1, 0x69
    iget-boolean v2, p0, Lacceptance/presentation/ContentOwnerTask;->settings:Z
    if-eqz v2, :find
    const/16 v1, 0x6a
  :find
    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v1
    instance-of v2, v1, Landroid/widget/Button;
    if-eqz v2, :done
    invoke-virtual {v1}, Landroid/view/View;->getContext()Landroid/content/Context;
    move-result-object v2
    if-ne v0, v2, :done
    invoke-virtual {v1}, Landroid/view/View;->getRootView()Landroid/view/View;
    move-result-object v3
    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v4
    invoke-virtual {v4}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v5
    if-ne v3, v5, :done
    iget-boolean v2, p0, Lacceptance/presentation/ContentOwnerTask;->settings:Z
    if-eqz v2, :attached
    invoke-virtual {v4}, Landroid/view/Window;->getAttributes()Landroid/view/WindowManager$LayoutParams;
    move-result-object v2
    iget v2, v2, Landroid/view/WindowManager$LayoutParams;->flags:I
    and-int/lit16 v2, v2, 0x2000
    if-eqz v2, :done
    const v2, 0x01020002
    invoke-virtual {v0, v2}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;
    move-result-object v3
    const/16 v8, 16
  :ancestor
    invoke-virtual {v1}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v2
    if-eq v2, v3, :root
    instance-of v0, v2, Landroid/view/View;
    if-eqz v0, :bad_root
    check-cast v2, Landroid/view/View;
    move-object v1, v2
    add-int/lit8 v8, v8, -1
    if-gtz v8, :ancestor
    goto :bad_root
  :root
    iget v0, p0, Lacceptance/presentation/ContentOwnerTask;->mutation:I
    const/4 v2, 1
    if-ne v0, v2, :root_check
    const v2, -0x1
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
  :root_check
    invoke-virtual {v1}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v2
    instance-of v3, v2, Landroid/graphics/drawable/ColorDrawable;
    if-eqz v3, :bad_root
    check-cast v2, Landroid/graphics/drawable/ColorDrawable;
    invoke-virtual {v2}, Landroid/graphics/drawable/ColorDrawable;->getColor()I
    move-result v2
    const v3, 0xff212121
    if-ne v2, v3, :bad_root
    const/4 v2, 4
    if-ne v0, v2, :bar_check
    const v2, -0x1
    invoke-virtual {v4, v2}, Landroid/view/Window;->setStatusBarColor(I)V
  :bar_check
    invoke-virtual {v4}, Landroid/view/Window;->getStatusBarColor()I
    move-result v2
    if-ne v2, v3, :bad_window
    invoke-virtual {v4}, Landroid/view/Window;->getNavigationBarColor()I
    move-result v2
    if-ne v2, v3, :bad_window
    const/4 v2, 5
    if-ne v0, v2, :icons_check
    const/16 v2, 0x2010
    invoke-virtual {v5, v2}, Landroid/view/View;->setSystemUiVisibility(I)V
  :icons_check
    invoke-virtual {v5}, Landroid/view/View;->getSystemUiVisibility()I
    move-result v2
    and-int/lit16 v2, v2, 0x2010
    if-nez v2, :bad_window
    invoke-direct {p0, v1}, Lacceptance/presentation/ContentOwnerTask;->visit(Landroid/view/View;)Z
    move-result v0
    if-eqz v0, :done
    iget v0, p0, Lacceptance/presentation/ContentOwnerTask;->count:I
    const/16 v1, 14
    if-lt v0, v1, :bad_count
    iget v0, p0, Lacceptance/presentation/ContentOwnerTask;->edits:I
    const/4 v1, 6
    if-ne v0, v1, :bad_count
    const-string v0, "NativeSettingsPaletteAcceptance"
    const-string v1, "PASS actual secure settings root bars icons text hints selection six enabled inputs password semantics; no credential values captured"
    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
  :attached
    const/4 v0, 1
    iput-boolean v0, p0, Lacceptance/presentation/ContentOwnerTask;->attached:Z
  :done
    return-void
  :bad_root
    const-string v0, "FAIL settings palette root"
    goto :reject
  :bad_window
    const-string v0, "FAIL settings palette window"
    goto :reject
  :bad_count
    const-string v0, "FAIL settings palette control count"
  :reject
    invoke-direct {p0, v0}, Lacceptance/presentation/ContentOwnerTask;->reject(Ljava/lang/String;)Z
    return-void
.end method

.method private reject(Ljava/lang/String;)Z
    .locals 1
    iput-object p1, p0, Lacceptance/presentation/ContentOwnerTask;->failure:Ljava/lang/String;
    const/4 v0, 0
    return v0
.end method

.method private visit(Landroid/view/View;)Z
    .locals 7
    instance-of v0, p1, Landroid/widget/TextView;
    if-eqz v0, :children
    move-object v0, p1
    check-cast v0, Landroid/widget/TextView;
    iget v1, p0, Lacceptance/presentation/ContentOwnerTask;->count:I
    iget v2, p0, Lacceptance/presentation/ContentOwnerTask;->mutation:I
    const/4 v3, 2
    if-ne v2, v3, :text_color
    if-nez v1, :text_color
    const v2, 0xff000000
    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTextColor(I)V
  :text_color
    add-int/lit8 v1, v1, 1
    iput v1, p0, Lacceptance/presentation/ContentOwnerTask;->count:I
    invoke-virtual {v0}, Landroid/widget/TextView;->getCurrentTextColor()I
    move-result v1
    const v2, 0xfff4f4f4
    if-eq v1, v2, :edit
    const v2, 0xffb4b4b4
    if-eq v1, v2, :edit
    invoke-virtual {v0}, Landroid/view/View;->isEnabled()Z
    move-result v2
    if-nez v2, :bad_text
    const v2, 0xff858585
    if-eq v1, v2, :edit
  :bad_text
    const-string v0, "FAIL settings palette text"
    invoke-direct {p0, v0}, Lacceptance/presentation/ContentOwnerTask;->reject(Ljava/lang/String;)Z
    move-result v0
    return v0
  :edit
    instance-of v1, p1, Landroid/widget/EditText;
    if-eqz v1, :children
    invoke-virtual {v0}, Landroid/view/View;->isEnabled()Z
    move-result v1
    if-eqz v1, :bad_input
    invoke-virtual {v0}, Landroid/view/View;->isFocusable()Z
    move-result v1
    if-eqz v1, :bad_input
    iget v1, p0, Lacceptance/presentation/ContentOwnerTask;->edits:I
    iget v2, p0, Lacceptance/presentation/ContentOwnerTask;->mutation:I
    const/4 v3, 3
    if-ne v2, v3, :input_background
    if-nez v1, :input_background
    const v2, -0x1
    invoke-virtual {v0, v2}, Landroid/view/View;->setBackgroundColor(I)V
  :input_background
    invoke-virtual {v0}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v2
    instance-of v3, v2, Landroid/graphics/drawable/ColorDrawable;
    if-eqz v3, :input_hint
    check-cast v2, Landroid/graphics/drawable/ColorDrawable;
    invoke-virtual {v2}, Landroid/graphics/drawable/ColorDrawable;->getColor()I
    move-result v2
    const v3, 0xff212121
    if-eq v2, v3, :input_hint
    const v3, 0xff2f2f2f
    if-eq v2, v3, :input_hint
    const v3, 0xff383838
    if-ne v2, v3, :bad_input
  :input_hint
    invoke-virtual {v0}, Landroid/widget/TextView;->getCurrentHintTextColor()I
    move-result v2
    const v3, 0xffb4b4b4
    if-ne v2, v3, :bad_input
    invoke-virtual {v0}, Landroid/widget/TextView;->getHighlightColor()I
    move-result v2
    const v3, 0xff595959
    if-ne v2, v3, :bad_input
    const/4 v2, 4
    if-ne v1, v2, :input_count
    invoke-virtual {v0}, Landroid/widget/TextView;->getInputType()I
    move-result v2
    and-int/lit16 v2, v2, 0xfff
    const/16 v3, 0x81
    if-ne v2, v3, :bad_input
  :input_count
    add-int/lit8 v1, v1, 1
    iput v1, p0, Lacceptance/presentation/ContentOwnerTask;->edits:I
    goto :children
  :bad_input
    const-string v0, "FAIL settings palette input"
    invoke-direct {p0, v0}, Lacceptance/presentation/ContentOwnerTask;->reject(Ljava/lang/String;)Z
    move-result v0
    return v0
  :children
    instance-of v0, p1, Landroid/view/ViewGroup;
    if-eqz v0, :success
    move-object v0, p1
    check-cast v0, Landroid/view/ViewGroup;
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getChildCount()I
    move-result v1
    const/4 v2, 0
  :child
    if-ge v2, v1, :success
    invoke-virtual {v0, v2}, Landroid/view/ViewGroup;->getChildAt(I)Landroid/view/View;
    move-result-object v3
    invoke-direct {p0, v3}, Lacceptance/presentation/ContentOwnerTask;->visit(Landroid/view/View;)Z
    move-result v4
    if-eqz v4, :failure
    add-int/lit8 v2, v2, 1
    goto :child
  :success
    const/4 v0, 1
    return v0
  :failure
    const/4 v0, 0
    return v0
.end method
