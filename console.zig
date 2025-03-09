const COM1: u16 = 0x3f8;
var uart: i32 = 0;
extern "C" fn out_b(a: u16, b: u8) void;
extern "C" fn in_b(a: u16) u8;
extern "C" fn micro_delay() void;

pub fn uartinit() void {
    out_b(COM1 + 2, 0);
    out_b(COM1 + 3, 0x80);
    out_b(COM1 + 0, 115200 / 115200);
    out_b(COM1 + 1, 0);
    out_b(COM1 + 3, 0x03);
    out_b(COM1 + 4, 0);
    out_b(COM1 + 1, 0x01);
    if (in_b(COM1 + 5) == 0xFF) return;
    uart = 1;
    _ = in_b(COM1 + 2);
    _ = in_b(COM1 + 0);
}

pub fn uartputc(c: u8) void {
    if (uart == 0) return;
    var i: i32 = 0;
    while (i < 128 and (in_b(COM1 + 5) & 0x20) == 0) : (i += 1) {
        micro_delay();
    }
    out_b(COM1 + 0, c);
}

pub fn printk(str: []const u8) void {
    for (str) |c| {
        uartputc(c);
    }
}
