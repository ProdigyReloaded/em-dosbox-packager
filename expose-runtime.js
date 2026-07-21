// Expose the emscripten FS and IDBFS objects on Module so page-level glue
// (the portal's init.js) can mount persistent IndexedDB-backed storage over
// the client's drive.
//
// This runs as a --pre-js, which emscripten emits near the top of the module
// (before the `var FS = {...}` / `var IDBFS = {...}` definitions), so copying
// the references here directly would capture `undefined`. Defer the copy to a
// preRun callback — by then FS/IDBFS are defined — and unshift it so it runs
// before any page-supplied preRun that consumes them. addRunDependency /
// removeRunDependency are already on Module.
Module["preRun"] = Module["preRun"] || [];
Module["preRun"].unshift(function () {
  Module["FS"] = FS;
  Module["IDBFS"] = IDBFS;
});
