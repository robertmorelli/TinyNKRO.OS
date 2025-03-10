const pts = @import("pagetables.zig");
const scr = @import("render.zig");

export fn main() void {
    pts.use_pagetables();
    scr.render_loop();
}
