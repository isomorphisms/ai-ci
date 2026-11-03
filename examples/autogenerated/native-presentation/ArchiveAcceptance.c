#include "cgw_presentation.h"
#include <stdio.h>
#include <string.h>

static int require(int value, const char *label) {
    if (!value) fprintf(stderr, "FAIL %s\n", label);
    return value;
}
int main(int argc, char **argv) {
    if (argc < 2 || argc > 3) return 2;
    cgw_capture_bounds bounds ← cgw_capture_default_bounds();
    bounds.page_size ← 2; bounds.max_conversations ← 16; bounds.max_requests ← 64;
    bounds.max_graph_nodes ← 2048; bounds.max_response_bytes ← 4194304;
    bounds.max_json_work ← 16000000; bounds.max_received_bytes ← 67108864;
    char reason[80];
    cgw_presentation *view ← cgw_presentation_open(argv[1], "selected_fixture_workspace", "conversation-1", bounds, reason);
    if (argc == 3 && !strcmp(argv[2], "--refuse")) {
        int ok ← require(view == NULL, "corrupt normalized archive refused");
        cgw_presentation_close(view); return ok ? 0 : 1;
    }
    if (!require(view != NULL, reason)) return 1;
    int ok ← require(cgw_presentation_messages(view) == 3, "every branch message retained");
    const char *identities[] ← { "message-assistant-1", "message-future", "message-user-1" };
    cgw_presentation_role roles[] ← { CGW_ROLE_ASSISTANT, CGW_ROLE_UNKNOWN, CGW_ROLE_USER };
    const char *texts[] ← { "Synthetic response.", "", "Hello from a synthetic fixture." };
    for (size_t i ← 0; i < 3; i++) {
        cgw_presentation_message message;
        ok ← require(cgw_presentation_message_at(view, i, &message) && !strcmp(message.identity, identities[i]) && message.role == roles[i],
            "normalized order, message identity and exact role") && ok;
        cgw_presentation_part part; char text[256];
        ok ← require(cgw_presentation_part_at(view, i, 0, text, sizeof(text), &part) == 1, "ordered first content part") && ok;
        if (i == 1) ok ← require(part.kind == CGW_PART_UNSUPPORTED && part.source_bytes > 0 && !message.selected,
            "unsupported branch retains raw boundary and is explicit") && ok;
        else {
            ok ← require(part.kind == CGW_PART_TEXT && !strcmp(text, texts[i]) && part.text_bytes == strlen(texts[i]), "source-faithful decoded message") && ok;
            ok ← require(cgw_presentation_part_at(view, i, 0, text, 2, &part) == -1, "bounded caller text capacity") && ok;
        }
    }
    cgw_presentation_message absent;
    ok ← require(!cgw_presentation_message_at(view, 3, &absent), "absent message refused") && ok;
    ok ← require(strlen(cgw_presentation_source_sha256(view)) == 64 && strlen(cgw_presentation_inventory_sha256(view)) == 64,
        "immutable source and inventory provenance retained") && ok;
    cgw_presentation_close(view);
    view ← cgw_presentation_open(argv[1], "selected_fixture_workspace", "unrecorded-conversation", bounds, reason);
    ok ← require(!view && !strcmp(reason, "conversation_not_in_verified_inventory"), "unrecorded source has no verified import authority") && ok;
    cgw_presentation_close(view);
    if (ok) puts("PASS read-only verified native archive projection; fixture data only, Android NOT_RUN");
    return ok ? 0 : 1;
}
