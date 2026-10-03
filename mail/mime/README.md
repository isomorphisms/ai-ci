# MIME observations

The leaf payload files are literal author-supplied answers. No MIME/base64/QP
decoder generates them. Multipart construction explicitly assigns the CRLF
before a delimiter to the delimiter, including the empty-part example.

plain, base64, wrapped-base64 and quoted-printable examples all decode to the
same seven octets `hello CR LF`. Their source hashes differ. These are both
positive decoded-equivalence controls and negative raw-equality controls.
Nested mixed/alternative parts retain ordering, HTML stays separate from plain
text, and an attachment contains NUL, 0xff, CR and LF. Its filename splits a UTF-8
octet sequence across RFC 2231 parameter continuations. A message/rfc822 container
contains an inner encoded leaf; this does not authorize illegal base64 encoding
of a multipart container.

Malformed base64/QP, missing closing delimiters, encoded multiparts and boundary
prefix collisions await retained-parser recovery policy. The valid boundary-
looking payload has text before the delimiter-shaped substring; it is not a
delimiter at line start. Do not make a generic substring splitter the oracle.
