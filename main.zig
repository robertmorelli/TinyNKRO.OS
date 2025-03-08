const std = @import("std");
const console = @import("console.zig");
const c = @import("mmu.zig");

// Global arrays from mmu.h, with proper alignment.
var entry_pgtable1: [c.NPTENTRIES]c.pte_t align(c.PGSIZE) = undefined;
var entry_pgtable2: [c.NPTENTRIES]c.pte_t align(c.PGSIZE) = undefined;
var entry_pgdir: [c.NPDENTRIES]c.pde_t align(c.PGSIZE) = undefined;

// Global GDT and its descriptor.
var gdt: [c.NSEGS]c.segdesc = undefined;
var gdtdesc: c.gdtdesc = c.gdtdesc{ .limit = @sizeOf(gdt) - 1, .base = &gdt[0] };

fn halt() void {
    asm volatile ("hlt");
}

/// Build and load a new GDT.
fn write_gdt(p: *c.segdesc, size: i32) void {
    var pd: [3]c.ushort = .{ 0, 0, 0 };
    pd[0] = @as(c.ushort, size - 1);
    pd[1] = @as(c.ushort, p);
    pd[2] = @as(c.ushort, p >> 16);
    asm volatile ("lgdt (%[ptr])"
        : [ptr] "r" (pd),
    );
}

/// Read CR0 using inline assembly.
fn read_cr0() u32 {
    return asm volatile ("movl %%cr0, %[val]"
        : [val] "=&r" (-> u32),
    );
}

fn write_cr0(val: u32) void {
    asm volatile ("movl %[val], %%cr0"
        :
        : [val] "r" (val),
    );
}

fn write_cr3(val: u32) void {
    asm volatile ("movl %[val], %%cr3"
        :
        : [val] "r" (val),
    );
}

export fn main() void {
    entry_pgdir[0] = @as(u32, @intFromPtr(&entry_pgtable1)) + c.PTE_P + c.PTE_W;
    entry_pgdir[1] = @as(u32, @intFromPtr(&entry_pgtable2)) + c.PTE_P + c.PTE_W;

    for (0..c.NPTENTRIES) |i| {
        entry_pgtable1[i] = (0x001000 * @as(c.uint, i)) | c.PTE_P | c.PTE_W;
        entry_pgtable2[i] = 0x80000 | (0x001000 * @as(c.uint, i)) | c.PTE_P | c.PTE_W;
    }

    write_cr3(@intFromPtr(&entry_pgdir));
    var cr0: c.uint = read_cr0();
    cr0 |= c.CR0_PG;
    write_cr0(cr0);
    console.uartinit();
    console.printk("Hello from C\n");
}
