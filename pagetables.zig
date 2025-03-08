const std = @import("std");
const mmu = @import("mmu.zig");
const pte_t = u32;
const pde_t = u32;
const pagedirPointers = [mmu.NPDENTRIES]*[mmu.PGSIZE]u8;
const pagedir = union { pointers: pagedirPointers, table: [mmu.NPDENTRIES]pde_t };

var gdt: [mmu.NSEGS]mmu.segdesc = std.mem.zeroes([mmu.NSEGS]mmu.segdesc);
var gdtdesc: gdtdesc = gdtdesc{ .limit = @sizeOf(gdt) - 1, .base = &gdt[0] };

pub var entry_pgtable1: [mmu.NPDENTRIES]pte_t align(mmu.PGSIZE) = make_pte: {
    var result: [mmu.NPDENTRIES]pte_t = undefined;
    @setEvalBranchQuota(mmu.NPTENTRIES + 1);
    for (0..mmu.NPTENTRIES) |i| {
        result[i] = ((0x001000 * @as(u32, i)) | mmu.PTE_P | mmu.PTE_W);
    }
    break :make_pte result;
};

pub var entry_pgtable2: [mmu.NPDENTRIES]pte_t align(mmu.PGSIZE) = make_pte: {
    var result: [mmu.NPDENTRIES]pte_t = undefined;
    @setEvalBranchQuota(mmu.NPTENTRIES + 1);
    for (0..mmu.NPTENTRIES) |i| {
        result[i] = (0x80000 | (0x001000 * @as(u32, i)) | mmu.PTE_P | mmu.PTE_W);
    }
    break :make_pte result;
};

pub var entry_pgdir: pagedir align(mmu.PGSIZE) = make_pdt: {
    var result: pagedirPointers = undefined;
    result[0] = @ptrCast(&@as([*]u8, @ptrCast(&entry_pgtable1))[mmu.PTE_P | mmu.PTE_W]);
    result[1] = @ptrCast(&@as([*]u8, @ptrCast(&entry_pgtable2))[mmu.PTE_P | mmu.PTE_W]);
    break :make_pdt .{ .pointers = result };
};
