const mmu = @import("mmu.zig");
const pts = @import("pagetables.zig");
const scr = @import("render.zig");
extern "C" fn read_cr0() u32;
extern "C" fn write_cr0(u32) void;
extern "C" fn write_cr3(u32) void;
extern "C" fn halt() void;
extern "C" fn write_gdt(*u32, i32) void;
extern "C" fn print_hello_world() void;

export fn main() void {
    write_cr3(@intFromPtr(&pts.entry_pgdir));
    var cr0: u32 = read_cr0();
    cr0 |= mmu.CR0_PG;
    write_cr0(cr0);
    scr.render_loop();
}
