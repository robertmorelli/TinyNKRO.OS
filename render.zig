const std = @import("std");
const kb = @import("keyboard.zig");

pub fn put_keys_on_screen() void {
    var x: u16 = 0;
    var y: u16 = 0;
    for (0..256) |i| {
        if (kb.key_state[i]) {
            const ascii = kb.key_to_ascii(@as(u8, @intCast(i)));
            if (ascii != 0) {
                vga_new[y][x] = 0x400 | ascii;
                x += 1;
                if (x == 80) {
                    x = 0;
                    y += 1;
                    if (y == 25) {
                        y = 0;
                    }
                }
            }
        }
    }
}

const screen = [25][80]u16;
const vga: *volatile screen = @ptrFromInt(0xb8000);
var vga_new: screen = std.mem.zeroes(screen);

fn show_screen() void {
    for (0..25) |y| {
        std.mem.copyForwards(u16, @as([]u16, @volatileCast(&(vga.*)[y])), &vga_new[y]);
    }
    std.mem.copyForwards([80]u16, &vga_new, &std.mem.zeroes(screen));
}

pub fn render_loop() void {
    while (true) {
        kb.update_key_state();
        put_keys_on_screen();
        show_screen();
    }
}
