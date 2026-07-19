# vim: set ts=2 sw=2 noai et:

FROM emscripten/emsdk
RUN apt-get update && apt-get install -y autoconf automake python-is-python3
RUN git clone --depth 1 -b prodigy-reloaded-changes https://github.com/pheller/em-dosbox.git /src/em-dosbox
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
