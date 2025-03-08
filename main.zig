const std = @import("std");
const console = @import("console.zig");
const mmu = @import("mmu.zig");
extern "C" fn read_cr0() u32;
extern "C" fn write_cr0(u32) void;
extern "C" fn write_cr3(u32) void;
extern "C" fn halt() void;
extern "C" fn write_gdt(*u32, i32) void;

export fn main() void {
    write_cr3(@intFromPtr(&mmu.entry_pgdir));
    var cr0: u32 = read_cr0();
    cr0 |= mmu.CR0_PG;
    write_cr0(cr0);
    console.uartinit();
    console.printk("Hello from C\n");
}
