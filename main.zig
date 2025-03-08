const std = @import("std");
const console = @import("console.zig");
const mmu = @import("mmu.zig");
extern "C" fn read_cr0() u32;
extern "C" fn write_cr0(u32) void;
extern "C" fn write_cr3(u32) void;
extern "C" fn halt() void;
extern "C" fn write_gdt(*u32, i32) void;

var gdt: [mmu.NSEGS]mmu.segdesc = std.mem.zeroes([mmu.NSEGS]mmu.segdesc);
var gdtdesc: mmu.gdtdesc = mmu.gdtdesc{ .limit = @sizeOf(gdt) - 1, .base = &gdt[0] };

var entry_pgtable1: [mmu.NPTENTRIES]mmu.pte_t align(mmu.PGSIZE) = undefined;
var entry_pgtable2: [mmu.NPTENTRIES]mmu.pte_t align(mmu.PGSIZE) = undefined;
var entry_pgdir: [mmu.NPDENTRIES]mmu.pde_t align(mmu.PGSIZE) = undefined;

export fn main() void {
    entry_pgdir[0] = @as(u32, @intFromPtr(&entry_pgtable1)) | mmu.PTE_P | mmu.PTE_W;
    entry_pgdir[1] = @as(u32, @intFromPtr(&entry_pgtable2)) | mmu.PTE_P | mmu.PTE_W;
    for (0..mmu.NPTENTRIES) |i| {
        entry_pgtable1[i] = (0x001000 * @as(u32, i)) | mmu.PTE_P | mmu.PTE_W;
        entry_pgtable2[i] = 0x80000 | (0x001000 * @as(u32, i)) | mmu.PTE_P | mmu.PTE_W;
    }
    write_cr3(@intFromPtr(&entry_pgdir));
    var cr0: u32 = read_cr0();
    cr0 |= mmu.CR0_PG;
    write_cr0(cr0);
    console.uartinit();
    console.printk("Hello from C\n");
}
