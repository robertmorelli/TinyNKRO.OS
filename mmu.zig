// Eflags register
pub const FL_IF: u32 = 0x00000200;

// Control Register flags
pub const CR0_PE: u32 = 0x00000001;
pub const CR0_WP: u32 = 0x00010000;
pub const CR0_PG: u32 = 0x80000000;

pub const CR4_PSE: u32 = 0x00000010;

// Segment selectors.
pub const SEG_KCODE: u32 = 1; // kernel code
pub const SEG_KDATA: u32 = 2; // kernel data+stack

pub const NSEGS: u32 = 3;

// GDT descriptor (packed)
pub const gdtdesc = packed struct {
    limit: u16,
    base: u32,
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
    pub fn init(_type: u32, _base: u32, _lim: u32, _dpl: u32) segdesc {
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

        const raw: u32 = lim_15_0 | (base_15_0 << 16) | (base_23_16 << 32) | (type_field << 40) | (s_field << 44) | (dpl_field << 45) | (p_field << 47) | (lim_19_16 << 48) | (avl_field << 52) | (rsv1_field << 53) | (db_field << 54) | (g_field << 55) | (base_31_24 << 56);
        return segdesc{ .raw = raw };
    }
};

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

// Page directory/table constants.
pub const NPDENTRIES: u32 = 1024;
pub const NPTENTRIES: u32 = 1024;
pub const PGSIZE: u32 = 4096;

pub fn PGROUNDUP(sz: u32) u32 {
    return (sz + PGSIZE - 1) & ~(PGSIZE - 1);
}

pub fn PGROUNDDOWN(a: u32) u32 {
    return a & ~(PGSIZE - 1);
}

// Page table/directory entry flags.
pub const PTE_P: u32 = 0x001;
pub const PTE_W: u32 = 0x002;
pub const PTE_U: u32 = 0x004;
pub const PTE_PS: u32 = 0x080;

pub fn PTE_ADDR(pte: u32) u32 {
    return pte & ~0xFFF;
}

pub fn PTE_FLAGS(pte: u32) u32 {
    return pte & 0xFFF;
}

// Typedefs for page table/directory entries.
pub const pte_t = u32;
pub const pde_t = u32;
