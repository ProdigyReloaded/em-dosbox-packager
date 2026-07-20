# em-dosbox-packager

Docker build harness that produces the in-browser DOSBox runtime used by
Prodigy Reloaded, plus a packager that turns a directory of DOS files into
an emscripten virtual-filesystem bundle.

## What it does

1. Builds em-dosbox (github.com/ProdigyReloaded/em-dosbox, branch
   `prodigy-reloaded-changes`, pinned by SHA in the Dockerfile) under
   emscripten with SDL2 and SDL2_net,
   linking `websocket-config.js` as a pre-js so the emulated serial/modem
   path speaks WebSocket to the delivery-system TCS bridge.
2. Packages a mounted directory of DOS files with em-dosbox's
   `packager.py` into a loadable data bundle.

## Usage

```
./em-dosbox-packager.sh /path/to/client/dir OUTPUT_NAME FILE_TO_RUN
```

The first run builds the `em-dosbox-packager` Docker image (linux/amd64);
subsequent runs reuse it. Example, packaging a Prodigy Reception System
file set from the (private) client-bundles repo:

```
./em-dosbox-packager.sh ../client-bundles/6.03.17 rs-6.03.17 PRODIGY.BAT
```

## Outputs

Dropped into the mounted directory:

- `dosbox.js`, `dosbox.wasm` - the emulator runtime
- `<OUTPUT_NAME>.data` - the packed virtual filesystem
- `<OUTPUT_NAME>.html` - a generated standalone page
- `loader.js` - the Module data-loader extracted from the generated
  page, for sites (like the portal `/start` page) that supply their own
  html

## Consumers

`ProdigyReloaded/delivery-system` serves the bundle from
`apps/portal/priv/static/start/` (expects `dosbox.js`, `dosbox.wasm`,
`loader.js`, `rs-<version>.data`, alongside the portal's own hand-written
`init.js` glue).

## Automation

Pushing a `v*` tag builds the image with the pinned emsdk and em-dosbox
versions, pushes it to `ghcr.io/prodigyreloaded/em-dosbox-packager`
(`:<tag>` and `:latest`), and attaches `dosbox.js`/`dosbox.wasm` to a
GitHub Release. `workflow_dispatch` builds and pushes a `sha-*` image
without a release. Local packaging can pull the GHCR image instead of
building it (the wrapper script builds locally only when the
`em-dosbox-packager` image is absent; `docker pull` + `docker tag` the
GHCR image to that name to reuse it).

## Licensing

This repository's own files (the Dockerfile, the shell scripts, and
`websocket-config.js`) are licensed AGPL-3.0-or-later; see `LICENSE`.

DOSBox and em-dosbox are GPL-2.0-or-later; their sources are fetched at
image build time from the ProdigyReloaded/em-dosbox fork at the SHA
pinned in the Dockerfile. `websocket-config.js` is linked into the
DOSBox build as a pre-js, so the resulting `dosbox.js`/`dosbox.wasm`
combine AGPL-3.0 and GPL-2.0-or-later code (GPL-2.0-or-later upgrades to
GPL-3.0, with which AGPL-3.0 is compatible). Complete corresponding
source for any distributed build is available from that fork and this
repository.
