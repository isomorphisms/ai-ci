#include "autofile_api.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    af_http_method method;
    const char *path;
    const char *body;
    af_transport_result transport;
    unsigned status;
    const char *response;
    const char *workspace;
} expected_call;

typedef struct {
    const expected_call *calls;
    size_t count;
    size_t next;
    unsigned patches;
    int failed;
} witness;

static af_transport_result observe(void *context, const af_request *request,
                                   af_response *response)
{
    witness *witness_state = context;
    if (witness_state->next >= witness_state->count) {
        witness_state->failed = 1;
        return AF_TRANSPORT_REFUSED;
    }
    const expected_call *expected = &witness_state->calls[witness_state->next++];
    if (request->method != expected->method
        || strcmp(request->path, expected->path) != 0
        || strcmp(request->body, expected->body) != 0) witness_state->failed = 1;
    if (request->method == AF_HTTP_PATCH) {
        ++witness_state->patches;
        if (request->retry_permitted) witness_state->failed = 1;
    }
    response->status = expected->status;
    response->body = (const unsigned char *)expected->response;
    response->body_length = expected->response == NULL ? 0 : strlen(expected->response);
    response->workspace_fingerprint = expected->workspace;
    return expected->transport;
}

static af_client make_client(witness *state)
{
    af_client client = { observe, state, "workspace-fingerprint", 1000000 };
    return client;
}

static af_move_intent make_intent(void)
{
    af_move_intent intent = {
        "conversation-17", "g-p-destination", "",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        1
    };
    return intent;
}

static const char *catalog =
    "{\"items\":[{\"gizmo\":{\"gizmo\":{\"id\":\"g-p-destination\","
    "\"display\":{\"name\":\"Destination\"},"
    "\"current_user_permission\":{\"can_write\":true},"
    "\"is_archived\":false}}}],\"cursor\":null}";

static int finished(const witness *state)
{
    return !state->failed && state->next == state->count;
}

static int verified_one_write(void)
{
    const expected_call calls[] = {
        { AF_HTTP_GET, "/backend-api/gizmos/snorlax/sidebar?owned_only=false&conversations_per_gizmo=0&limit=20", "", AF_TRANSPORT_DELIVERED, 200, catalog, "workspace-fingerprint" },
        { AF_HTTP_GET, "/backend-api/conversation/conversation-17", "", AF_TRANSPORT_DELIVERED, 200, "{\"id\":\"conversation-17\",\"gizmo_id\":null}", "workspace-fingerprint" },
        { AF_HTTP_PATCH, "/backend-api/conversation/conversation-17", "{\"gizmo_id\":\"g-p-destination\"}", AF_TRANSPORT_DELIVERED, 200, "{\"success\":true}", "workspace-fingerprint" },
        { AF_HTTP_GET, "/backend-api/conversation/conversation-17", "", AF_TRANSPORT_DELIVERED, 200, "{\"id\":\"conversation-17\",\"gizmo_id\":\"g-p-destination\"}", "workspace-fingerprint" }
    };
    witness state = { calls, 4, 0, 0, 0 };
    af_client client = make_client(&state);
    af_move_intent intent = make_intent();
    af_move_receipt receipt;
    return af_move_thread(&client, &intent, &receipt) == AF_OK
        && receipt.verdict == AF_MOVE_VERIFIED
        && receipt.patch_attempts == 1 && state.patches == 1 && finished(&state);
}

static int false_success_rejected(void)
{
    const expected_call calls[] = {
        { AF_HTTP_GET, "/backend-api/gizmos/snorlax/sidebar?owned_only=false&conversations_per_gizmo=0&limit=20", "", AF_TRANSPORT_DELIVERED, 200, catalog, "workspace-fingerprint" },
        { AF_HTTP_GET, "/backend-api/conversation/conversation-17", "", AF_TRANSPORT_DELIVERED, 200, "{\"id\":\"conversation-17\",\"gizmo_id\":null}", "workspace-fingerprint" },
        { AF_HTTP_PATCH, "/backend-api/conversation/conversation-17", "{\"gizmo_id\":\"g-p-destination\"}", AF_TRANSPORT_DELIVERED, 200, "{\"success\":true}", "workspace-fingerprint" },
        { AF_HTTP_GET, "/backend-api/conversation/conversation-17", "", AF_TRANSPORT_DELIVERED, 200, "{\"id\":\"conversation-17\",\"gizmo_id\":null}", "workspace-fingerprint" }
    };
    witness state = { calls, 4, 0, 0, 0 };
    af_client client = make_client(&state);
    af_move_intent intent = make_intent();
    af_move_receipt receipt;
    af_status status = af_move_thread(&client, &intent, &receipt);
    return status != AF_OK && receipt.verdict == AF_MOVE_UNKNOWN
        && state.patches == 1 && finished(&state);
}

static int stale_source_rejected(void)
{
    const expected_call calls[] = {
        { AF_HTTP_GET, "/backend-api/gizmos/snorlax/sidebar?owned_only=false&conversations_per_gizmo=0&limit=20", "", AF_TRANSPORT_DELIVERED, 200, catalog, "workspace-fingerprint" },
        { AF_HTTP_GET, "/backend-api/conversation/conversation-17", "", AF_TRANSPORT_DELIVERED, 200, "{\"id\":\"conversation-17\",\"gizmo_id\":\"g-p-other\"}", "workspace-fingerprint" }
    };
    witness state = { calls, 2, 0, 0, 0 };
    af_client client = make_client(&state);
    af_move_intent intent = make_intent();
    af_move_receipt receipt;
    return af_move_thread(&client, &intent, &receipt) == AF_STALE_SOURCE
        && state.patches == 0 && finished(&state);
}

static int wrong_workspace_rejected(void)
{
    const expected_call calls[] = {
        { AF_HTTP_GET, "/backend-api/gizmos/snorlax/sidebar?owned_only=false&conversations_per_gizmo=0&limit=20", "", AF_TRANSPORT_DELIVERED, 200, catalog, "wrong-workspace" }
    };
    witness state = { calls, 1, 0, 0, 0 };
    af_client client = make_client(&state);
    af_move_intent intent = make_intent();
    af_move_receipt receipt;
    return af_move_thread(&client, &intent, &receipt) == AF_WRONG_WORKSPACE
        && state.patches == 0 && finished(&state);
}

static int forged_approval_rejected(void)
{
    witness state = { NULL, 0, 0, 0, 0 };
    af_client client = make_client(&state);
    af_move_intent intent = make_intent();
    af_move_receipt receipt;
    intent.approval_digest =
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
    return af_move_thread(&client, &intent, &receipt) == AF_NOT_AUTHORIZED
        && state.next == 0 && state.patches == 0;
}

int main(void)
{
    struct { const char *name; int (*run)(void); } cases[] = {
        { "verified-one-write", verified_one_write },
        { "false-success-rejected", false_success_rejected },
        { "stale-source-rejected", stale_source_rejected },
        { "wrong-workspace-rejected", wrong_workspace_rejected },
        { "forged-approval-rejected", forged_approval_rejected }
    };
    for (size_t index = 0; index < sizeof(cases) / sizeof(cases[0]); ++index) {
        if (!cases[index].run()) {
            fprintf(stderr, "FAIL %s\n", cases[index].name);
            return 1;
        }
        printf("PASS %s\n", cases[index].name);
    }
    return 0;
}
