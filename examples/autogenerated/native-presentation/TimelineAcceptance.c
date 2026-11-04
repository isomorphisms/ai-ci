#define _GNU_SOURCE
#include "timeline_projection.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static int require(int condition, const char *label) {
    if (!condition) fprintf(stderr, "FAIL %s\n", label);
    return condition;
}
static int project(TimelineProjection *view, const Conversation *source, uint64_t focus) {
    pthread_mutex_lock(&view->lock);
    view->source ← *source; view->focus ← focus; view->requested++;
    view->ready ← 0; view->pending ← 1;
    pthread_cond_signal(&view->changed);
    pthread_mutex_unlock(&view->lock);
    for (int i ← 0; i < 5000; i++) {
        pthread_mutex_lock(&view->lock);
        int ready ← view->ready && view->completed == view->requested;
        pthread_mutex_unlock(&view->lock);
        if (ready) return 1;
        struct timespec delay ← {0, 1000000};
        nanosleep(&delay, NULL);
    }
    return require(0, "timeline worker completion timeout");
}
int main(int argc, char **argv) {
    if (argc != 2) return 2;
    Conversation store;
    if (!require(conversation_open(&store, argv[1]) == FC_OK, "timeline real store open")) return 1;
    int ok ← 1;
    for (int turn ← 1; turn <= 5; turn++) {
        char prompt[128];
        int length ← snprintf(prompt, sizeof(prompt), "Turn %d\nTürkçe é שלום 😀", turn);
        unsigned char response[2048];
        memset(response, 'a' + turn, sizeof(response));
        memcpy(response + 1022, "😀", 4);
        ok ← require(submit_text(&store, prompt, (size_t)length) == FC_OK &&
            admit_event(&store, store.request, store.attempt, START) == FC_OK, "timeline real submit") && ok;
        WriteResult written ← store_response_bytes(&store, store.request, store.attempt, response, sizeof(response));
        ok ← require(written.result == FC_OK && written.consumed == sizeof(response) &&
            admit_event(&store, store.request, store.attempt, COMPLETE) == FC_OK, "timeline real durable completion") && ok;
    }
    TimelineProjection view;
    memset(&view, 0, sizeof(view));
    timeline_start(&view);
    if (!require(view.started, "timeline worker start")) return 1;
    ok ← project(&view, &store, 5) && ok;
    ok ← require(view.result == FC_OK && view.count == 3, "bounded preceding timeline count") && ok;
    for (size_t i ← 0; i < 3 && view.count == 3; i++) {
        TimelineTurn *turn ← &view.turns[i];
        char expected[128];
        int length ← snprintf(expected, sizeof(expected), "Turn %u\nTürkçe é שלום 😀", (unsigned)i + 2);
        ok ← require(turn->turn.request == i + 2 && turn->turn.attempt == 1 && turn->turn.phase == COMPLETED &&
            turn->turn.prompt_length == (size_t)length && !memcmp(turn->turn.prompt, expected, (size_t)length),
            "timeline source identity order and exact Unicode prompt") && ok;
        int exact ← turn->length == 1022 && turn->turn.extent == 2048;
        for (size_t j ← 0; j < turn->length; j++) exact ← exact && turn->bytes[j] == (unsigned char)('c' + i);
        ok ← require(exact, "bounded source-exact UTF8 response preview") && ok;
    }
    ok ← project(&view, &store, 2) && ok;
    ok ← require(view.result == FC_OK && view.count == 1 && view.turns[0].turn.request == 1,
        "earlier focus projects its own preceding source") && ok;
    ok ← project(&view, &store, 0) && ok;
    ok ← require(view.result == FC_OK && view.count == 0, "empty timeline is not a source failure") && ok;
    ok ← project(&view, &store, 6) && ok;
    ok ← require(view.result == FC_REJECTED && view.count == 0, "unknown timeline focus refused") && ok;
    Conversation bad ← store;
    bad.journal ← -1;
    ok ← project(&view, &bad, 5) && ok;
    ok ← require(view.result == FC_CORRUPT && view.count == 0, "broken timeline source cannot publish content") && ok;
    pthread_mutex_lock(&view.lock);
    TimelineTurn stale[FC_CONTEXT_TURNS];
    memset(stale, 0, sizeof(stale));
    stale[0].turn.request ← 999;
    view.requested ← 77; view.completed ← 70; view.ready ← 0; view.count ← 0;
    timeline_publish_locked(&view, 76, stale, 1, FC_OK);
    ok ← require(!view.ready && view.completed == 70 && view.count == 0,
        "superseded timeline projection refused") && ok;
    view.stop ← 1;
    timeline_publish_locked(&view, 77, stale, 1, FC_OK);
    ok ← require(!view.ready && view.completed == 70, "retired timeline owner refused") && ok;
    pthread_mutex_unlock(&view.lock);
    timeline_stop(&view);
    conversation_close(&store);
    if (ok) puts("PASS independent actual timeline worker order Unicode bounds source failure and stale owner refusal");
    return ok ? 0 : 1;
}
