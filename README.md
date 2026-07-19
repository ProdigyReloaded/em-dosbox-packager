# dosbox-wasm

Docker build harness that produces the in-browser DOSBox runtime used by
Prodigy Reloaded, plus a packager that turns a directory of DOS files into
an emscripten virtual-filesystem bundle.

## What it does

1. Builds em-dosbox (github.com/pheller/em-dosbox, branch
   `prodigy-reloaded-changes`) under emscripten with SDL2 and SDL2_net,
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
- `<OUTPUT_NAME>.html` - a generated standalone page. The inline Module
  data-loader script inside it is what the portal uses as `loader.js`.

## Consumers

`ProdigyReloaded/delivery-system` serves the bundle from
`apps/portal/priv/static/start/` (expects `dosbox.js`, `dosbox.wasm`,
`loader.js`, `rs-<version>.data`, alongside the portal's own hand-written
`init.js` glue).

## Licensing

DOSBox and em-dosbox are GPL-2.0; their sources are fetched at image
build time from the fork named above. Complete corresponding source for
any distributed `dosbox.js`/`dosbox.wasm` build is available from that
fork and this repository.
