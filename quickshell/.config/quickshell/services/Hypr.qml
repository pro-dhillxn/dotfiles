pragma Singleton
import Quickshell
import Quickshell.Hyprland

// Hypr — service: thin, Lua-aware dispatch helpers.
//
// Hyprland runs a Lua config, so `Hyprland.dispatch(str)` evaluates the string
// as Lua (`hl.dispatch(...)`). A classic `workspace 2` string is then a Lua
// syntax error, so every helper branches on `Hyprland.usingLua` and sends the
// Lua table form — the same one your hyprland.lua already uses
// (e.g. `hl.dsp.focus({ workspace = i })`).
//
// Two gotchas that are easy to break and hard to spot (the error only shows
// in `qs log` on click, not in the UI):
//   - the `pragma Singleton` line above is REQUIRED. Without it, Quickshell's
//     auto-generated qmldir registers Hypr as a plain component and
//     `Hypr.focusWorkspace(...)` throws "Property 'focusWorkspace' of object
//     Hypr is not a function".
//   - `import Quickshell.Hyprland` is required so `Hyprland` resolves inside
//     this file (it is NOT re-exported by plain `import Quickshell`).
//
// Only `focusWorkspace` is needed by the bar today; add more helpers here as
// modules (launcher, etc.) need them.
Singleton {
    function focusWorkspace(ws) {
        Hyprland.dispatch(
            Hyprland.usingLua
                ? `hl.dsp.focus({ workspace = ${JSON.stringify(String(ws))} })`
                : `workspace ${ws}`
        )
    }
}
