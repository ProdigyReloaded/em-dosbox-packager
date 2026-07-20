// Reads window.PRODIGY_TCS_PATH if present, falling back to /tcs. Lets the
// /start page's (future) era/environment dropdown set window.PRODIGY_TCS_PATH
// to something like "/early/alpha/tcs" without needing to rebuild the WASM
// bundle from the em-dosbox-packager.
Module["websocket"] = {
    url: `${window.location.protocol.replace('http', 'ws')}//${window.location.host}${window.PRODIGY_TCS_PATH || '/tcs'}`
};
