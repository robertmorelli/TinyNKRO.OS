const std = @import("std");

const mmu = @import("mmu.zig");
const pte_t = u32;
const pde_t = u32;
const pagedirPointers = [mmu.NPDENTRIES]*[mmu.PGSIZE]u8;
const pagedir = union { pointers: pagedirPointers, table: [mmu.NPDENTRIES]pde_t };
const pagetablePointers = [mmu.NPDENTRIES][*]u8;
const pagetable = union { pointers: pagetablePointers, table: [mmu.NPDENTRIES]pte_t };

var gdt: [mmu.NSEGS]mmu.segdesc = std.mem.zeroes([mmu.NSEGS]mmu.segdesc);
var gdtdesc: gdtdesc = gdtdesc{ .limit = @sizeOf(gdt) - 1, .base = &gdt[0] };

const trs: [*]allowzero u8 = @ptrFromInt(0);
pub var entry_pgtable1: pagetable align(mmu.PGSIZE) = make_pte: {
    var result: pagetablePointers = undefined;
    @setEvalBranchQuota(mmu.NPTENTRIES + 1);
    for (0..mmu.NPTENTRIES) |i| {
        result[i] = @as([*]u8, @ptrCast(&trs[((0x001000 * @as(u32, i)) | mmu.PTE_P | mmu.PTE_W)]));
    }
    break :make_pte .{ .pointers = result };
};

pub var entry_pgtable2: pagetable align(mmu.PGSIZE) = make_pte: {
    var result: pagetablePointers = undefined;
    @setEvalBranchQuota(mmu.NPTENTRIES + 1);
    for (0..mmu.NPTENTRIES) |i| {
        result[i] = @as([*]u8, @ptrCast(&trs[(0x80000 | (0x001000 * @as(u32, i)) | mmu.PTE_P | mmu.PTE_W)]));
    }
    break :make_pte .{ .pointers = result };
};

pub var entry_pgdir: pagedir align(mmu.PGSIZE) = make_pdt: {
    var result: pagedirPointers = undefined;
    result[0] = @ptrCast(&@as([*]u8, @ptrCast(&entry_pgtable1))[mmu.PTE_P | mmu.PTE_W]);
    result[1] = @ptrCast(&@as([*]u8, @ptrCast(&entry_pgtable2))[mmu.PTE_P | mmu.PTE_W]);
    break :make_pdt .{ .pointers = result };
};
