# vim: set ts=2 sw=2 noai et:

FROM emscripten/emsdk
RUN apt-get update && apt-get install -y autoconf automake python-is-python3

# Pinned commit of ProdigyReloaded/em-dosbox (branch prodigy-reloaded-changes).
# Bump this SHA when emulator source fixes land.
ARG EM_DOSBOX_REPO=https://github.com/ProdigyReloaded/em-dosbox.git
ARG EM_DOSBOX_SHA=7140f3243b30d9d3a818ea4ede0c593d35925519
RUN git init /src/em-dosbox \
  && git -C /src/em-dosbox remote add origin "$EM_DOSBOX_REPO" \
  && git -C /src/em-dosbox fetch --depth 1 origin "$EM_DOSBOX_SHA" \
  && git -C /src/em-dosbox checkout FETCH_HEAD
COPY websocket-config.js /src/em-dosbox
COPY websocket-config.js /src/em-dosbox/src
RUN cd /src/em-dosbox \
  && sh ./autogen.sh \
  && emconfigure ./configure \
    CFLAGS="-O3 -g -s USE_SDL=2 -s USE_SDL_NET=2" \
    CXXFLAGS="-O3 -g -s USE_SDL=2 -s USE_SDL_NET=2" \
    LDFLAGS="--pre-js websocket-config.js -s WEBSOCKET_SUBPROTOCOL=null" \
  && make
RUN cd /src/em-dosbox/src && cp dosbox.html template.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /src/em-dosbox/src
ENTRYPOINT ["/entrypoint.sh"]
