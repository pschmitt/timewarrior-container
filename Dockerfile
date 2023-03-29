FROM rust:alpine as jirapush

# NOTE Cargo won't build a static binary, but this should be fine
# ldd /tmp/timewarrior-jirapush/target/release/jirapush
#         /lib/ld-musl-x86_64.so.1 (0x7fe852798000)
#         libssl.so.3 => /lib/libssl.so.3 (0x7fe85236c000)
#         libcrypto.so.3 => /lib/libcrypto.so.3 (0x7fe851e00000)
#         libc.musl-x86_64.so.1 => /lib/ld-musl-x86_64.so.1 (0x7fe852798000)
RUN apk add --no-cache git musl-dev openssl-dev && \
  git clone https://github.com/FoxAmes/timewarrior-jirapush \
    /tmp/timewarrior-jirapush && \
  cd /tmp/timewarrior-jirapush && \
  cargo build --release

FROM alpine:3.17

RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> \
      /etc/apk/repositories && \
    apk add --no-cache task timewarrior@testing && \
    apk add --no-cache --virtual builddeps git py3-pip py3-cffi && \
    pip install --no-cache-dir git+https://github.com/ralphbean/bugwarrior jira keyring && \
    pip install --no-cache-dir timewsync && \
    adduser user01 -u 1000 -D

COPY --from=jirapush /tmp/timewarrior-jirapush/target/release/jirapush /usr/local/bin/jirapush

USER user01
