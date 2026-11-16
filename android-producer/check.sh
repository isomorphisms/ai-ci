#!/bin/sh
# Foreign compatibility boundary. It cannot bootstrap or select an interpreter,
# policy, release or trust root from the caller's PATH/environment.
exec /usr/bin/env -i PATH=/usr/bin:/bin /opt/aici/android-producer/current/runtime/ysh /opt/aici/android-producer/current/policy/android-producer/check.ysh "$@"
