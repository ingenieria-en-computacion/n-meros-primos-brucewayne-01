; io.asm - Biblioteca de funciones auxiliares para programas en ensamblador x86
; Convención: Preserva los registros EBX, ESI, EDI, EBP (los demás pueden modificarse)
section .data
    newline     db  10, 0

section .bss
    number_input   resb 12    
    number_output  resb 12
    output_buffer resb 12   ; Buffer para almacenar el número convertido

section .text
    global scan_num
    global print_str
    global print_newline
; ----------------------------------------------------------
; scan_num - Lee un número desde la entrada estándar
; Salida: EAX = número leído (entero)
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
scan_num:    
    mov eax, 3                          ; Código de syscall para sys_read
    mov ebx, 0                          ; Descriptor de archivo 0 (stdin)
    mov ecx, number_input               ; Dirección del buffer donde se almacena la entrada
    mov edx, 12                         ; Número máximo de bytes a leer
    int 0x80                            ; Llamada al sistema para leer entrada estándar

    mov esi, number_input               ; ESI apunta al buffer de entrada
    call stoi                           ; Convierte la cadena en número entero (Strin to In)
    ret

; ----------------------------------------------------------
; print_str - Imprime una cadena terminada en NULL
; Entrada: ESI = dirección de la cadena a imprimir
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
print_str:
    mov edx, 0                  ; Inicia el contador de longitud en 0
.calc_len:
    cmp byte [esi+ edx], 0      ; Comprueba si el carácter actual es NULL (fin de cadena)
    je .print                   ; Si es NULL, procede a la impresión
    inc edx                     ; Incrementa el contador de longitud
    jmp .calc_len               
.print:
    mov eax, 4                  ; Código de syscall para sys_write
    mov ebx, 1                  ; Descriptor de archivo 1 (stdout)
    mov ecx, esi                ; Dirección de la cadena a imprimir
    int 0x80                    ; Llamada al sistema para imprimir la cadena
    ret                         ; Retornamos


;----------------------------------------------------------
; print_num - Imprime un número almacenado en un buffer, 
;             primero lo convierte en cadena
; Entrada: EAX = número a imprimir
; Modifica: EAX, EBX, ECX, EDX, EDI
; ----------------------------------------------------------
print_num:
    push edi                    ; Guarda el valor actual de EDI en la pila
    mov edi, number_output      ; Usa number_output como buffer para la conversión

    call itos                   ; Convierte el número en cadena
    mov esi, output_buffer      ; ESI apunta al buffer de salida
    call print_str              ; Imprime la cadena resultante
    pop edi                     ; Restaura el valor original de EDI
    ret


; ----------------------------------------------------------
; print_newline - Imprime un carácter de nueva línea
; Modifica: EAX, EBX, ECX, EDX
; ----------------------------------------------------------
print_newline:
    mov eax, 4                  ; Código de syscall para sys_write
    mov ebx, 1                  ; Descriptor de archivo 1 (stdout)
    mov ecx, newline            ; Dirección del carácter de nueva línea
    mov edx, 1                  ; Longitud de la cadena a imprimir (1 byte)
    int 0x80                    ; Llamada al sistema para imprimir
    ret


; ----------------------------------------------------------
; stoi - Convierte una cadena ASCII a entero
; Entrada: ESI = dirección de la cadena
; Salida: EAX = número convertido
; Modifica: EAX, ECX, EDX
; ----------------------------------------------------------
stoi:
    xor eax, eax                        ; Limpia EAX (acumulador)
    xor ecx, ecx                        ; Limpia ECX (contador)
.convert:
    movzx edx, byte [esi+ecx]           ; Obtiene el siguiente carácter de la cadena
    cmp dl, 0x0A                        ; Compara con el carácter de nueva línea
    je .convert_done                   ; Si es un salto de línea, termina la conversión
    cmp dl, '0'                         ; Comprueba si es menor que '0'
    jb .convert_done                    ; Si es menor, termina la conversión
    cmp dl, '9'                         ; Comprueba si es mayor que '9'
    ja .convert_done                    ; Si es mayor, termina la conversión
    sub dl, '0'                         ; Convierte el carácter en un número
    imul eax, 10                        ; Multiplica el acumulador por 10
    add eax, edx                        ; Suma el dígito actual
    inc ecx                             ; Avanza al siguiente carácter
    jmp .convert                        ; Repite el proceso
.convert_done:
    ret


; ----------------------------------------------------------
; itos - Convierte un entero a cadena ASCII
; Entrada: EAX = número a convertir
;          EDI = dirección del buffer de salida
; Modifica: EAX, EBX, ECX, EDX, EDI
; ----------------------------------------------------------
itos:
    mov ebx, 10                 ; Base 10 para la conversión de número a cadena
    xor ecx, ecx                ; Limpia el contador de dígitos

    test eax, eax               ; Comprueba si el número es 0
    jnz .convert              ; Si no es 0, continúa con la conversión

    ; Caso especial para cero
    mov byte [edi], '0'         ; Almacena '0' en el buffer
    inc edi                     ; Avanza el apuntador
    mov byte [edi], 0           ; Agrega fin de cadena
    ret                         

.convert:
    xor edx, edx                ; Limpia EDX para la división
    div ebx                     ; Divide EAX entre 10, cociente en EAX, residuo en EDX
    add dl, '0'                 ; Convierte el residuo en un carácter ASCII
    push dx                     ; Almacena el dígito en la pila
    inc ecx                     ; Incrementa el contador de dígitos
    test eax, eax               ; Comprueba si el cociente es 0
    jnz .convert                ; Si no es 0, sigue dividiendo

.reverse:               
    pop dx                      ; Recupera el último dígito de la pila
    mov [edi], dl               ; Almacena el carácter en el buffer
    inc edi                     ; Avanza el apuntador del buffer
    loop .reverse               ; Repite para todos los dígitos, decrementa automáticamente ecx

    mov byte [edi], 0           ; Agrega fin de cadena
    ret