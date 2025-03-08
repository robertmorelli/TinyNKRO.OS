const COM1: u16 = 0x3f8;
var uart: i32 = 0;
extern "C" fn out_b(a: u16, b: u8) void;
extern "C" fn in_b(a: u16) u8;
pub fn microdelay(_: u64) void {
    // No-op delay.
}

pub fn uartinit() void {
    // Turn off the FIFO.
    out_b(COM1 + 2, 0);

    // 9600 baud, 8 data bits, 1 stop bit, parity off.
    out_b(COM1 + 3, 0x80); // Unlock divisor.
    out_b(COM1 + 0, 115200 / 115200); // Divisor = 1.
    out_b(COM1 + 1, 0);
    out_b(COM1 + 3, 0x03); // Lock divisor, 8 data bits.
    out_b(COM1 + 4, 0);
    out_b(COM1 + 1, 0x01); // Enable receive interrupts.

    // If status is 0xFF, no serial port.
    if (in_b(COM1 + 5) == 0xFF) return;

    uart = 1;

    // Acknowledge pre-existing interrupt conditions; enable interrupts.
    _ = in_b(COM1 + 2);
    _ = in_b(COM1 + 0);
}

pub fn uartputc(c: u8) void {
    if (uart == 0) return;
    var i: i32 = 0;
    while (i < 128 and (in_b(COM1 + 5) & 0x20) == 0) : (i += 1) {
        microdelay(10);
    }
    out_b(COM1 + 0, c);
}

pub fn printk(str: []const u8) void {
    for (str) |c| {
        uartputc(c);
    }
}
