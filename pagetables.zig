const std = @import("std");
extern "C" fn write_cr3(*pagedir) void;
extern "C" fn turn_on_paging() void;

// Page table/directory entry flags.
pub const PTE_P: u32 = 0x001;
pub const PTE_W: u32 = 0x002;

const pte_t = u32;
const pde_t = u32;

// Page directory/table constants.
pub const NPDENTRIES: u32 = 1024;
pub const NPTENTRIES: u32 = 1024;
pub const PGSIZE: u32 = 4096;

const pagedir_pointers = [NPDENTRIES]*[PGSIZE]u8;
const pagedir = union { pointers: pagedir_pointers, table: [NPDENTRIES]pde_t };

pub var entry_pgtable1: [NPDENTRIES]pte_t align(PGSIZE) = make_pte: {
    var result: [NPDENTRIES]pte_t = undefined;
    @setEvalBranchQuota(NPTENTRIES + 1);
    for (0..NPTENTRIES) |i| {
        result[i] = ((0x001000 * @as(u32, i)) | PTE_P | PTE_W);
    }
    break :make_pte result;
};

pub var entry_pgtable2: [NPDENTRIES]pte_t align(PGSIZE) = make_pte: {
    var result: [NPDENTRIES]pte_t = undefined;
    @setEvalBranchQuota(NPTENTRIES + 1);
    for (0..NPTENTRIES) |i| {
        result[i] = (0x80000 | (0x001000 * @as(u32, i)) | PTE_P | PTE_W);
    }
    break :make_pte result;
};

pub var entry_pgdir: pagedir align(PGSIZE) = make_pdt: {
    var result: pagedir_pointers = undefined;
    result[0] = @ptrCast(&@as([*]u8, @ptrCast(&entry_pgtable1))[PTE_P | PTE_W]);
    result[1] = @ptrCast(&@as([*]u8, @ptrCast(&entry_pgtable2))[PTE_P | PTE_W]);
    break :make_pdt .{ .pointers = result };
};

pub fn use_pagetables() void {
    write_cr3(&entry_pgdir);
    turn_on_paging();
}
