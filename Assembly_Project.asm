.model small
.stack 200h       ; Increased stack size for dynamic input

.data
    yaz1 db "Enter text (press Enter to finish): $"
    yaz2 db 10,13,"Encrypted text: $"
    max_length equ 100     ; Maximum input length
    
    input_buffer db max_length dup(?)   ; Dynamic input buffer
    output_buffer db max_length dup(?)  ; Dynamic output buffer
    buffer_end db '$'      ; String terminator

.code
main proc
    ; Initialize data segment
        ;mov ax, @data
        ;mov ds, ax
    .startup
    ; Display input prompt
    lea dx, yaz1
    mov ah, 09h
    int 21h

    ; Prepare for input
    lea si, input_buffer   ; SI points to input buffer
    mov cx, 0              ; Character count

; Dynamic input loop
input_loop:
    ; Read single character
    mov ah, 01h
    int 21h

    ; Check for Enter key (13 decimal)
    cmp al, 13
    je input_done

    ; Store character
    mov [si], al
    inc si
    inc cx

    ; Check if buffer is full
    cmp cx, max_length
    jl input_loop

input_done:
    ; Null-terminate the input
    mov byte ptr [si], '$'

    ; Caesar cipher encryption macro
    macro_sezar macro reg
        local check_letter, apply_shift, wrap_around, exit_macro
        
        ; Check if character is a letter
        check_letter:
        cmp reg, 'A'
        jb exit_macro
        cmp reg, 'z'
        ja exit_macro
        
        ; Check uppercase range
        cmp reg, 'Z'
        jle apply_shift
        
        ; Check lowercase range
        cmp reg, 'a'
        jge apply_shift
        
        ; Not a letter, exit
        jmp exit_macro
        
        ; Apply shift
        apply_shift:
        add reg, 3
        
        ; Wrap around for uppercase
        cmp reg, 'Z'
        jle exit_macro
        
        ; Wrap around uppercase
        cmp reg, 'a'
        jl wrap_around_upper
        
        ; Wrap around for lowercase
        cmp reg, 'z'
        jg wrap_around_lower
        
        jmp exit_macro
        
        ; Wrap uppercase letters
        wrap_around_upper:
        sub reg, 26
        jmp exit_macro
        
        ; Wrap lowercase letters
        wrap_around_lower:
        sub reg, 26
        
        exit_macro:
    endm

    ; Prepare for encryption
    lea si, input_buffer   ; Source input buffer
    lea di, output_buffer  ; Destination output buffer
    mov bx, cx             ; Store character count

; Encryption loop
encrypt_loop:
    ; Check if we've processed all characters
    cmp bx, 0
    je encryption_done

    ; Get current character
    mov al, [si]
    
    ; Apply Caesar cipher
    macro_sezar al
    
    ; Store encrypted character
    mov [di], al
    
    ; Move to next characters
    inc si
    inc di
    dec bx
    
    jmp encrypt_loop

encryption_done:
    ; Null-terminate output
    mov byte ptr [di], '$'

    ; Display encrypted text prompt
    mov ah, 09h
    lea dx, yaz2
    int 21h

    ; Display encrypted text
    mov ah, 09h
    lea dx, output_buffer
    int 21h

    ; Exit program
    ;mov ah, 4Ch
    ;int 21h
    .exit
    
main endp


end main
