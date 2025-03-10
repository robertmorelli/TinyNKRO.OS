const std = @import("std");
const STA_X = @as(u32, 0x8);
const STA_W = @as(u32, 0x2);
const STA_R = @as(u32, 0x2);
const SEG_KCODE = @as(u32, 1);
const SEG_KDATA = @as(u32, 2);
const segdescriptor = packed struct {
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

inline fn SEG(_type: u4, _base: u32, _lim: u32, _dpl: u2) segdescriptor {
    return .{
        .lim_15_0 = @truncate((_lim >> 12) & 0xffff),
        .base_15_0 = _base & 0xffff,
        .base_23_16 = @truncate((_base >> 16) & 0xff),
        .type = _type,
        .s = 1,
        .dpl = @truncate(_dpl),
        .p = 1,
        .lim_19_16 = _lim >> 28,
        .avl = 0,
        .rsv1 = 0,
        .db = 1,
        .g = 1,
        .base_31_24 = @truncate(_base >> @as(u32, 24)),
    };
}

export const gdt: [3]segdescriptor = gdtd: {
    var table: [3]segdescriptor = undefined;
    table[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
    table[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
    break :gdtd table;
};

// waiting on andrew kelly

// const gdtdescriptor = packed struct(u64) {
//     _: u16,
//     limit: u16,
//     base: *const [3]segdescriptor,
// };

// const gdtdescint = gdtdescriptor{
//     ._ = 0,
//     .limit = @sizeOf([3]segdescriptor) - 1,
//     .base = &gdt,
// };

// @export(&gdtdescint.limit, .{ .name = "gdtdesc", .linkage = .strong });
