const std = @import("std");
// Eflags register
pub const FL_IF: u32 = 0x00000200;

// Control Register flags
pub const CR0_PE: u32 = 0x00000001;
pub const CR0_WP: u32 = 0x00010000;
//pub const CR0_PG: u32 = 0x80000000; in main now

pub const CR4_PSE: u32 = 0x00000010;

// Segment selectors.
pub const SEG_KCODE: u32 = 1; // kernel code
pub const SEG_KDATA: u32 = 2; // kernel data+stack

pub const NSEGS: u32 = 3;

// GDT descriptor (packed)
pub const gdtdesctype = extern struct {
    limit: u16,
    base: *segdesc,
};

// The segment descriptor (segdesc) is represented as a u32 with fields packed manually.
// Layout (from LSB to MSB):
//   Bits  0-15: lim_15_0
//   Bits 16-31: base_15_0
//   Bits 32-39: base_23_16
//   Bits 40-43: type
//   Bit       44: s
//   Bits 45-46: dpl
//   Bit       47: p
//   Bits 48-51: lim_19_16
//   Bit       52: avl
//   Bit       53: rsv1
//   Bit       54: db
//   Bit       55: g
//   Bits 56-63: base_31_24

// DPL and segment type bits.
pub const DPL_USER: u32 = 0x3;

pub const STA_X: u32 = 0x8; // Executable segment
pub const STA_W: u32 = 0x2; // Writable (non-executable segments)
pub const STA_R: u32 = 0x2; // Readable (executable segments)

pub const STS_T32A: u32 = 0x9; // Available 32-bit TSS
pub const STS_IG32: u32 = 0xE; // 32-bit Interrupt Gate
pub const STS_TG32: u32 = 0xF; // 32-bit Trap Gate

// Virtual address manipulation.
// A virtual address 'va' is split into:
//    Page Directory Index | Page Table Index | Offset
pub const PTXSHIFT: u32 = 12;
pub const PDXSHIFT: u32 = 22;

pub fn PDX(va: u32) u32 {
    return (va >> PDXSHIFT) & 0x3FF;
}

pub fn PTX(va: u32) u32 {
    return (va >> PTXSHIFT) & 0x3FF;
}

pub fn PGADDR(d: u32, t: u32, o: u32) u32 {
    return (d << PDXSHIFT) | (t << PTXSHIFT) | o;
}

const segdesc = packed struct {
    lim_15_0: u16,
    base_15_0: u16,
    base_23_16: u8,
    type: u4,
    s: u1,
    dpl: u2,
    p: u1,
    lim_19_16: u4,
    avl: u1,
    rsv1: u1,
    db: u1,
    g: u1,
    base_31_24: u8,
};

fn SEG(_type: u32, _base: u32, _lim: u32, _dpl: u32) segdesc {
    return .{
        .lim_15_0 = @as(u16, @truncate((_lim >> 12) & 0xffff)),
        .base_15_0 = @as(u16, @truncate(_base & 0xffff)),
        .base_23_16 = @as(u8, @truncate((_base >> 16) & 0xff)),
        .type = @as(u4, @truncate(_type)),
        .s = 1,
        .dpl = _dpl,
        .p = 1,
        .lim_19_16 = @as(u4, @truncate(_lim >> 28)),
        .avl = 0,
        .rsv1 = 0,
        .db = 1,
        .g = 1,
        .base_31_24 = @as(u8, @truncate(_base >> 24)),
    };
}

// var gdt: [NSEGS]segdesc = gdt: {
//     var empty = std.mem.zeroes([NSEGS]segdesc);
//     empty[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
//     empty[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
//     break :gdt empty;
// };

// const gdtdescint: gdtdesctype = gdtdesctype{ .limit = @sizeOf([NSEGS]segdesc) - 1, .base = &gdt[0] };
// comptime {
//     @export(&gdtdescint, .{ .name = "gdtdesc", .linkage = .strong });
// }
