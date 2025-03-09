extern "C" fn in_b(a: u16) u8;
const vga_width = 80;
const vga_height = 25;
pub const char = u16;
pub const c = enum(u8) {
    ba = 0x0,
    bu = 0x1,
    ge = 0x2,
    cy = 0x3,
    re = 0x4,
    mg = 0x5,
    br = 0x6,
    lg = 0x7,
    dg = 0x8,
    lb = 0x9,
    le = 0xA,
    ly = 0xB,
    lr = 0xC,
    lm = 0xD,
    ye = 0xE,
    wh = 0xF,
};
const vga: *volatile [80][25]char = @ptrFromInt(0xb8000);
pub fn render(x: u16, y: u16, d: u16) void {
    vga[x][y] = d;
}
pub fn showkeyboard() void {
    while (true) {
        for (0..80) |x| {
            for (0..25) |y| {
                vga[x][y] = 0x400 | @as(u16, in_b(0x60));
            }
        }
    }
}
