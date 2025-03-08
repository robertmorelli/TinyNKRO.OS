    .globl out_b
out_b:
    movl 4(%esp), %edx   # Move first argument (port 'a') into EDX.
    movl 8(%esp), %eax   # Move second argument (data 'b') into EAX.
    outb %al, %dx        # Output the low 8 bits (AL) to port in DX.
    ret

    .globl in_b
in_b:
    movl 4(%esp), %edx    # Load the first parameter (port) from the stack into EDX.
    inb %dx, %al         # Read a byte from the port in DX into AL.
    movzbl %al, %eax     # Zero-extend AL into EAX.
    ret                  # Return; the value is in EAX.