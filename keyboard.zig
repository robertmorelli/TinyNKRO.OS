const std = @import("std");
extern "C" fn in_b(a: u16) u8;

pub var key_state: [256]bool = std.mem.zeroes([256]bool);

pub fn key_to_ascii(scancode: u16) u16 {
    return switch (scancode) {
        0x1E => 'a',
        0x30 => 'b',
        0x2E => 'c',
        0x20 => 'd',
        0x12 => 'e',
        0x21 => 'f',
        0x22 => 'g',
        0x23 => 'h',
        0x17 => 'i',
        0x24 => 'j',
        0x25 => 'k',
        0x26 => 'l',
        0x32 => 'm',
        0x31 => 'n',
        0x18 => 'o',
        0x19 => 'p',
        0x10 => 'q',
        0x13 => 'r',
        0x1F => 's',
        0x14 => 't',
        0x16 => 'u',
        0x2F => 'v',
        0x11 => 'w',
        0x2D => 'x',
        0x15 => 'y',
        0x2C => 'z',
        0x4D => '>',
        0x4B => '<',
        0x50 => '.',
        0x48 => '^',
        else => 0,
    };
}

pub fn update_key_state() void {
    const scan = in_b(0x60);
    if (scan < 0x80) {
        key_state[scan] = true;
    } else {
        key_state[scan - 0x80] = false;
    }
}
