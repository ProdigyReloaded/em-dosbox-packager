# vim: set ts=2 sw=2 noai et:

# Copyright 2026, Phillip Heller
#
# This file is part of Prodigy Reloaded.
#
# Prodigy Reloaded is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# Prodigy Reloaded is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
# the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Prodigy Reloaded. If not,
# see <https://www.gnu.org/licenses/>.

# emsdk pinned to the version recorded in the producers section of the
# shipped dosbox.wasm; bump deliberately, since emscripten upgrades can
# change codegen for this old em-dosbox tree.
FROM emscripten/emsdk:4.0.13
LABEL org.opencontainers.image.source=https://github.com/ProdigyReloaded/em-dosbox-packager
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
# Keep the raw debug build as dosbox-debug.wasm; ship the stripped one.
# llvm-strip --strip-all reproduces the historically shipped dosbox.wasm
# byte-for-byte (2.9M vs 15.8M raw).
RUN cd /src/em-dosbox/src \
  && cp dosbox.wasm dosbox-debug.wasm \
  && /emsdk/upstream/bin/llvm-strip --strip-all dosbox.wasm
RUN cd /src/em-dosbox/src && cp dosbox.html template.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /src/em-dosbox/src
ENTRYPOINT ["/entrypoint.sh"]
