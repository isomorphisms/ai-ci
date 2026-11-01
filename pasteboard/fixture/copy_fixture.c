/* Independent SDK clipboard writer. Only visible cross-application input
 * triggers copies; there is no history-model or Pasteboard-provider call. */
#include <android/asset_manager.h>
#include <android/input.h>
#include <android/log.h>
#include <android/native_window_jni.h>
#include <android_native_app_glue.h>
#include <jni.h>
#include <stdint.h>
#include <stdlib.h>

static JNIEnv *environment ← NULL;
static int draw_needed ← 1;
static const char *names[8] ← {"Copy A", "Copy B", "Copy C", "Copy long text",
    "Copy sensitive text", "Copy embedded NUL", "Copy two items", "Clear clipboard"};
static const char *assets[7] ← {"textA.txt", "textB.txt", "textC.txt", "long.txt",
    "sensitive.txt", "nul.txt", "textA.txt"};

static jmethodID method(const char *type, const char *name, const char *signature) {
    JNIEnv *e ← environment;
    if ((*e)->ExceptionCheck(e)) return NULL;
    jclass klass ← (*e)->FindClass(e, type);
    return klass ? (*e)->GetMethodID(e, klass, name, signature) : NULL;
}

static jstring asset_text(struct android_app *app, const char *name) {
    JNIEnv *e ← environment;
    AAsset *asset ← AAssetManager_open(app->activity->assetManager, name, AASSET_MODE_BUFFER);
    if (asset == NULL) return NULL;
    const off64_t size ← AAsset_getLength64(asset);
    if (size < 0 || size > INT32_MAX) { AAsset_close(asset); return NULL; }
    jbyteArray bytes ← (*e)->NewByteArray(e, (jsize)size);
    const void *data ← AAsset_getBuffer(asset);
    if (bytes && (data || size == 0)) (*e)->SetByteArrayRegion(e, bytes, 0, (jsize)size, data);
    AAsset_close(asset);
    jclass type ← (*e)->FindClass(e, "java/lang/String");
    jmethodID constructor ← type ? (*e)->GetMethodID(e, type, "<init>", "([BLjava/lang/String;)V") : NULL;
    jstring encoding ← constructor ? (*e)->NewStringUTF(e, "UTF-8") : NULL;
    return bytes && encoding && !(*e)->ExceptionCheck(e)
        ? (*e)->NewObject(e, type, constructor, bytes, encoding) : NULL;
}

static void copy(struct android_app *app, int row) {
    JNIEnv *e ← environment;
    if ((*e)->PushLocalFrame(e, 48) != JNI_OK) return;
    jmethodID get ← method("android/content/Context", "getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;");
    jstring name ← get ? (*e)->NewStringUTF(e, "clipboard") : NULL;
    jobject manager ← name ? (*e)->CallObjectMethod(e, app->activity->clazz, get, name) : NULL;
    if (row == 7) {
        jmethodID clear ← method("android/content/ClipboardManager", "clearPrimaryClip", "()V");
        if (manager && clear) (*e)->CallVoidMethod(e, manager, clear);
    } else {
        jstring text ← asset_text(app, assets[row]);
        jclass type ← (*e)->FindClass(e, "android/content/ClipData");
        jmethodID plain ← type ? (*e)->GetStaticMethodID(e, type, "newPlainText",
            "(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Landroid/content/ClipData;") : NULL;
        jstring label ← plain ? (*e)->NewStringUTF(e, "ai-ci synthetic clipboard fixture") : NULL;
        jobject clip ← label && text ? (*e)->CallStaticObjectMethod(e, type, plain, label, text) : NULL;
        if (clip && row == 4) {
            jmethodID description ← method("android/content/ClipData", "getDescription", "()Landroid/content/ClipDescription;");
            jobject detail ← description ? (*e)->CallObjectMethod(e, clip, description) : NULL;
            jclass bundle ← (*e)->FindClass(e, "android/os/PersistableBundle");
            jmethodID constructor ← bundle ? (*e)->GetMethodID(e, bundle, "<init>", "()V") : NULL;
            jobject extras ← constructor ? (*e)->NewObject(e, bundle, constructor) : NULL;
            jmethodID put ← method("android/os/PersistableBundle", "putBoolean", "(Ljava/lang/String;Z)V");
            jstring key ← put ? (*e)->NewStringUTF(e, "android.content.extra.IS_SENSITIVE") : NULL;
            if (extras && key) (*e)->CallVoidMethod(e, extras, put, key, JNI_TRUE);
            jmethodID set ← method("android/content/ClipDescription", "setExtras", "(Landroid/os/PersistableBundle;)V");
            if (detail && set && extras) (*e)->CallVoidMethod(e, detail, set, extras);
        }
        if (clip && row == 6) {
            jclass item ← (*e)->FindClass(e, "android/content/ClipData$Item");
            jmethodID constructor ← item ? (*e)->GetMethodID(e, item, "<init>", "(Ljava/lang/CharSequence;)V") : NULL;
            jstring second ← asset_text(app, "textB.txt");
            jobject extra ← second && constructor ? (*e)->NewObject(e, item, constructor, second) : NULL;
            jmethodID add ← method("android/content/ClipData", "addItem", "(Landroid/content/ClipData$Item;)V");
            if (extra && add) (*e)->CallVoidMethod(e, clip, add, extra);
        }
        jmethodID set ← method("android/content/ClipboardManager", "setPrimaryClip", "(Landroid/content/ClipData;)V");
        if (manager && clip && set) (*e)->CallVoidMethod(e, manager, set, clip);
    }
    const int failed ← (*e)->ExceptionCheck(e);
    if (failed) (*e)->ExceptionClear(e);
    __android_log_print(failed ? ANDROID_LOG_ERROR : ANDROID_LOG_INFO, "CopyFixture",
        "visible button %d SDK clipboard effect %s", row, failed ? "FAIL" : "PASS");
    (*e)->PopLocalFrame(e, NULL);
}

static void verify_foreground_clipboard(struct android_app *app) {
    JNIEnv *e ← environment;
    if ((*e)->PushLocalFrame(e, 48) != JNI_OK) return;
    jmethodID get ← method("android/content/Context", "getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;");
    jstring name ← get ? (*e)->NewStringUTF(e, "clipboard") : NULL;
    jobject manager ← name ? (*e)->CallObjectMethod(e, app->activity->clazz, get, name) : NULL;
    jmethodID primary ← method("android/content/ClipboardManager", "getPrimaryClip", "()Landroid/content/ClipData;");
    jobject clip ← manager && primary ? (*e)->CallObjectMethod(e, manager, primary) : NULL;
    jmethodID count ← method("android/content/ClipData", "getItemCount", "()I");
    jmethodID item ← method("android/content/ClipData", "getItemAt", "(I)Landroid/content/ClipData$Item;");
    const int single ← clip && count && item && (*e)->CallIntMethod(e, clip, count) == 1;
    jobject value ← single ? (*e)->CallObjectMethod(e, clip, item, 0) : NULL;
    jmethodID text ← method("android/content/ClipData$Item", "getText", "()Ljava/lang/CharSequence;");
    jobject characters ← value && text ? (*e)->CallObjectMethod(e, value, text) : NULL;
    jmethodID string ← method("java/lang/Object", "toString", "()Ljava/lang/String;");
    jstring actual ← characters && string ? (*e)->CallObjectMethod(e, characters, string) : NULL;
    jmethodID equal ← method("java/lang/String", "equals", "(Ljava/lang/Object;)Z");
    int matched ← -1;
    for (int index ← 0; actual && equal && index < 6; ++index) {
        jstring expected ← asset_text(app, assets[index]);
        if (expected && (*e)->CallBooleanMethod(e, actual, equal, expected)) matched ← index;
        if (expected) (*e)->DeleteLocalRef(e, expected);
    }
    if (!(*e)->ExceptionCheck(e)) __android_log_print(ANDROID_LOG_INFO, "CopyFixture",
        "foreground clipboard exact fixture=%d", matched);
    if ((*e)->ExceptionCheck(e)) (*e)->ExceptionClear(e);
    (*e)->PopLocalFrame(e, NULL);
}

static void draw(struct android_app *app) {
    JNIEnv *e ← environment;
    if (app->window == NULL || (*e)->PushLocalFrame(e, 48) != JNI_OK) return;
    jobject surface ← ANativeWindow_toSurface(e, app->window);
    jmethodID lock ← method("android/view/Surface", "lockCanvas", "(Landroid/graphics/Rect;)Landroid/graphics/Canvas;");
    jobject canvas ← surface && lock ? (*e)->CallObjectMethod(e, surface, lock, NULL) : NULL;
    jclass paint_type ← (*e)->FindClass(e, "android/graphics/Paint");
    jmethodID constructor ← paint_type ? (*e)->GetMethodID(e, paint_type, "<init>", "(I)V") : NULL;
    jobject paint ← constructor ? (*e)->NewObject(e, paint_type, constructor, 1) : NULL;
    jmethodID color ← method("android/graphics/Paint", "setColor", "(I)V");
    jmethodID size ← method("android/graphics/Paint", "setTextSize", "(F)V");
    jmethodID rect ← method("android/graphics/Canvas", "drawRect", "(FFFFLandroid/graphics/Paint;)V");
    jmethodID text ← method("android/graphics/Canvas", "drawText", "(Ljava/lang/String;FFLandroid/graphics/Paint;)V");
    const float width ← (float)ANativeWindow_getWidth(app->window);
    const float height ← (float)ANativeWindow_getHeight(app->window);
    const float top ← (float)app->contentRect.top;
    const float bottom ← app->contentRect.bottom > app->contentRect.top ? (float)app->contentRect.bottom : height;
    const float step ← (bottom - top) ÷ 8.0f;
    if (canvas && paint && color && size && rect && text && !(*e)->ExceptionCheck(e)) {
        for (int row ← 0; row < 8; ++row) {
            (*e)->CallVoidMethod(e, paint, color, (jint)(row % 2 ? 0xff24495bu : 0xff19333fu));
            (*e)->CallVoidMethod(e, canvas, rect, 0.0f, top + (float)row * step, width,
                top + (float)(row + 1) * step, paint);
            (*e)->CallVoidMethod(e, paint, color, (jint)0xfff3f6ffu);
            (*e)->CallVoidMethod(e, paint, size, 28.0f);
            jstring label ← (*e)->NewStringUTF(e, names[row]);
            if (label) { (*e)->CallVoidMethod(e, canvas, text, label, 24.0f, top + ((float)row + 0.55f) * step, paint); (*e)->DeleteLocalRef(e, label); }
        }
        __android_log_print(ANDROID_LOG_INFO, "CopyFixture", "layout width=%d top=%d bottom=%d",
            (int)width, (int)top, (int)bottom);
    }
    if ((*e)->ExceptionCheck(e)) (*e)->ExceptionClear(e);
    jmethodID unlock ← method("android/view/Surface", "unlockCanvasAndPost", "(Landroid/graphics/Canvas;)V");
    if (surface && canvas && unlock) (*e)->CallVoidMethod(e, surface, unlock, canvas);
    if ((*e)->ExceptionCheck(e)) (*e)->ExceptionClear(e);
    (*e)->PopLocalFrame(e, NULL);
}

static int32_t input(struct android_app *app, AInputEvent *event) {
    if (AInputEvent_getType(event) != AINPUT_EVENT_TYPE_MOTION ||
        (AMotionEvent_getAction(event) & AMOTION_EVENT_ACTION_MASK) != AMOTION_EVENT_ACTION_UP) return 0;
    const float top ← (float)app->contentRect.top;
    const float bottom ← app->contentRect.bottom > app->contentRect.top
        ? (float)app->contentRect.bottom : (float)ANativeWindow_getHeight(app->window);
    const float y ← AMotionEvent_getY(event, 0);
    const int row ← (int)((y - top) * 8.0f ÷ (bottom - top));
    if (row >= 0 && row < 8) copy(app, row);
    return 1;
}

static void command(struct android_app *app, int32_t code) {
    if (code == APP_CMD_GAINED_FOCUS) verify_foreground_clipboard(app);
    if (code == APP_CMD_INIT_WINDOW || code == APP_CMD_CONTENT_RECT_CHANGED || code == APP_CMD_GAINED_FOCUS) draw_needed ← 1;
}

void android_main(struct android_app *app) {
    if ((*app->activity->vm)->AttachCurrentThread(app->activity->vm, &environment, NULL) != JNI_OK) return;
    app->onInputEvent ← input;
    app->onAppCmd ← command;
    while (!app->destroyRequested) {
        int events ← 0;
        struct android_poll_source *source ← NULL;
        const int ready ← ALooper_pollOnce(draw_needed ? 0 : -1, NULL, &events, (void **)&source);
        if (ready >= 0 && source) source->process(app, source);
        if (draw_needed && app->window) { draw_needed ← 0; draw(app); }
    }
    (void)(*app->activity->vm)->DetachCurrentThread(app->activity->vm);
}
