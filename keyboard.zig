const std = @import("std");
extern "C" fn in_b(a: u16) u8;

pub var key_state: [256]bool = std.mem.zeroes([256]bool);

pub fn key_to_ascii(scancode: u16) u8 {
    switch (scancode) {
        0x1E => return 'a',
        0x30 => return 'b',
        0x2E => return 'c',
        0x20 => return 'd',
        0x12 => return 'e',
        0x21 => return 'f',
        0x22 => return 'g',
        0x23 => return 'h',
        0x17 => return 'i',
        0x24 => return 'j',
        0x25 => return 'k',
        0x26 => return 'l',
        0x32 => return 'm',
        0x31 => return 'n',
        0x18 => return 'o',
        0x19 => return 'p',
        0x10 => return 'q',
        0x13 => return 'r',
        0x1F => return 's',
        0x14 => return 't',
        0x16 => return 'u',
        0x2F => return 'v',
        0x11 => return 'w',
        0x2D => return 'x',
        0x15 => return 'y',
        0x2C => return 'z',
        else => return 0,
    }
}

pub fn update_key_state() void {
    const scan = in_b(0x60);
    if (scan < 0x80) {
        key_state[scan] = true;
    } else {
        key_state[scan - 0x80] = false;
    }
}
