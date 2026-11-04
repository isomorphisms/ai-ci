ICK ?= false
PRODUCER ?= producer
CFLAGS ?= -fno-link-libatomic -std=c11 -O2 -Wall -Wextra -Werror -pedantic

.PHONY: check clean

build/check: check.c $(PRODUCER)/src/autofile_api.c $(PRODUCER)/src/autofile_api.h $(PRODUCER)/src/af_json.c $(PRODUCER)/src/af_json.h
	mkdir -p build
	$(ICK) $(CFLAGS) -I$(PRODUCER)/src -o $@ check.c \
	  $(PRODUCER)/src/autofile_api.c $(PRODUCER)/src/af_json.c

check: build/check
	./build/check

clean:
	rm -rf build

