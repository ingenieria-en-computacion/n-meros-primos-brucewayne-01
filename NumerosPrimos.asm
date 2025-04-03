extern scan_num, print_str, print_newline
section .data
    msg_prime db "El numero es primo", 10, 0
    msg_not_prime db "El numero NO es primo", 10, 0
    newline db 10, 0

section .bss
    number_input resb 12    
    number_output resb 12

section .text
    global _start

_start:
    ; Leer número desde la entrada estándar
    call scan_num  ; EAX contendrá el número leído

    ; Guardamos el número en EBX para el chequeo
    mov ebx, eax
    
    ; Si el número es menor o igual a 1, no es primo
    cmp ebx, 1
    jle not_prime

    ; Llamar a la función para verificar si es primo
    call is_prime
    
    ; Si es primo, imprimir mensaje
    cmp eax, 1
    je prime

not_prime:
    mov esi, msg_not_prime
    call print_str
    jmp end_program

prime:
    mov esi, msg_prime
    call print_str

end_program:
    call print_newline
    mov eax, 1      ; Código de syscall para exit
    xor ebx, ebx    ; Código de salida 0
    int 0x80

; ----------------------------------------------------------
; is_prime - Verifica si un número en EBX es primo
; Salida: EAX = 1 si es primo, 0 si no lo es
; Modifica: ECX, EDX
; ----------------------------------------------------------
is_prime:
    mov ecx, 2      ; Divisor comienza en 2

check_loop:
    cmp ecx, ebx    ; Si ECX >= EBX, terminamos el chequeo
    jge is_prime_end

    mov eax, ebx    ; Copiamos EBX a EAX para dividir
    xor edx, edx    ; Limpiar EDX para la división
    div ecx         ; EAX / ECX, residuo en EDX
    cmp edx, 0      ; Si residuo es 0, no es primo
    je not_prime_return

    inc ecx         ; Incrementar divisor
    jmp check_loop

is_prime_end:
    mov eax, 1      ; Es primo
    ret

not_prime_return:
    xor eax, eax    ; No es primo (EAX = 0)
    ret
