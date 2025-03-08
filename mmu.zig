// mmu.zig
pub const uint = u32;
pub const ushort = u16;
pub const uchar = u8;

// Eflags register
pub const FL_IF: uint = 0x00000200;

// Control Register flags
pub const CR0_PE: uint = 0x00000001;
pub const CR0_WP: uint = 0x00010000;
pub const CR0_PG: uint = 0x80000000;

pub const CR4_PSE: uint = 0x00000010;

// Segment selectors.
pub const SEG_KCODE: uint = 1; // kernel code
pub const SEG_KDATA: uint = 2; // kernel data+stack

pub const NSEGS: uint = 3;

// GDT descriptor (packed)
pub const gdtdesc = packed struct {
    limit: ushort,
    base: uint,
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
pub const segdesc = struct {
    raw: u32,

    /// Create a segment descriptor (like the SEG macro in C).
    pub fn init(_type: uint, _base: uint, _lim: uint, _dpl: uint) segdesc {
        const lim_15_0: u32 = (_lim >> 12) & 0xffff;
        const base_15_0: u32 = _base & 0xffff;
        const base_23_16: u32 = (_base >> 16) & 0xff;
        const type_field: u32 = _type & 0xf; // 4 bits
        const s_field: u32 = 1;
        const dpl_field: u32 = _dpl & 0x3;
        const p_field: u32 = 1;
        const lim_19_16: u32 = (_lim >> 28) & 0xf;
        const avl_field: u32 = 0;
        const rsv1_field: u32 = 0;
        const db_field: u32 = 1;
        const g_field: u32 = 1;
        const base_31_24: u32 = (_base >> 24) & 0xff;

        const raw: u32 = @as(u32, lim_15_0) | (@as(u32, base_15_0) << 16) | (@as(u32, base_23_16) << 32) | (@as(u32, type_field) << 40) | (@as(u32, s_field) << 44) | (@as(u32, dpl_field) << 45) | (@as(u32, p_field) << 47) | (@as(u32, lim_19_16) << 48) | (@as(u32, avl_field) << 52) | (@as(u32, rsv1_field) << 53) | (@as(u32, db_field) << 54) | (@as(u32, g_field) << 55) | (@as(u32, base_31_24) << 56);
        return segdesc{ .raw = raw };
    }
};

// DPL and segment type bits.
pub const DPL_USER: uint = 0x3;

pub const STA_X: uint = 0x8; // Executable segment
pub const STA_W: uint = 0x2; // Writable (non-executable segments)
pub const STA_R: uint = 0x2; // Readable (executable segments)

pub const STS_T32A: uint = 0x9; // Available 32-bit TSS
pub const STS_IG32: uint = 0xE; // 32-bit Interrupt Gate
pub const STS_TG32: uint = 0xF; // 32-bit Trap Gate

// Virtual address manipulation.
// A virtual address 'va' is split into:
//    Page Directory Index | Page Table Index | Offset
pub const PTXSHIFT: uint = 12;
pub const PDXSHIFT: uint = 22;

pub fn PDX(va: uint) uint {
    return (va >> PDXSHIFT) & 0x3FF;
}

pub fn PTX(va: uint) uint {
    return (va >> PTXSHIFT) & 0x3FF;
}

pub fn PGADDR(d: uint, t: uint, o: uint) uint {
    return (d << PDXSHIFT) | (t << PTXSHIFT) | o;
}

// Page directory/table constants.
pub const NPDENTRIES: uint = 1024;
pub const NPTENTRIES: uint = 1024;
pub const PGSIZE: uint = 4096;

pub fn PGROUNDUP(sz: uint) uint {
    return (sz + PGSIZE - 1) & ~(PGSIZE - 1);
}

pub fn PGROUNDDOWN(a: uint) uint {
    return a & ~(PGSIZE - 1);
}

// Page table/directory entry flags.
pub const PTE_P: uint = 0x001;
pub const PTE_W: uint = 0x002;
pub const PTE_U: uint = 0x004;
pub const PTE_PS: uint = 0x080;

pub fn PTE_ADDR(pte: uint) uint {
    return pte & ~0xFFF;
}

pub fn PTE_FLAGS(pte: uint) uint {
    return pte & 0xFFF;
}

// Typedefs for page table/directory entries.
pub const pte_t = u32;
pub const pde_t = u32;
