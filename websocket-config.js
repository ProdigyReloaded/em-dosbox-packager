// Copyright 2026, Phillip Heller
//
// This file is part of Prodigy Reloaded.
//
// Prodigy Reloaded is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
// Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// Prodigy Reloaded is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
// the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License along with Prodigy Reloaded. If not,
// see <https://www.gnu.org/licenses/>.

// Reads window.PRODIGY_TCS_PATH if present, falling back to /tcs. Lets the
// /start page's (future) era/environment dropdown set window.PRODIGY_TCS_PATH
// to something like "/early/alpha/tcs" without needing to rebuild the WASM
// bundle from the em-dosbox-packager.
Module["websocket"] = {
    url: `${window.location.protocol.replace('http', 'ws')}//${window.location.host}${window.PRODIGY_TCS_PATH || '/tcs'}`
};
