export fn memset(s: [*]u8, c: u8, n: usize) [*]u8 {
    for (0..n) |i| {
        s[i] = c;
    }
    return s;
}

export fn memcpy(dest: [*]u8, src: [*]const u8, n: usize) [*]u8 {
    for (0..n) |i| {
        dest[i] = src[i];
    }
    return dest;
}
