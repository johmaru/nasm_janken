BITS 64

section .bss
    buffer resb 64
    stack_start resq 1
    random_value resd 1

section .data
    title db 'JanKen Game', 0xA,0
    title_len equ $ - title - 1
    cursor_up db 27, '[1A', 27, '[K'  ; ESC[1A（1行上）+ ESC[K（行クリア）
    cursor_up_len equ $ - cursor_up
    gameinfo db '好きな手を選んでください', 0xA,0
    gameinfo_len equ $ - gameinfo - 1
    gameinfo2 db 'グー:1, チョキ:2, パー:3', 0xA,0
    gameinfo2_len equ $ - gameinfo2 - 1
    rock_msg db 'あなたの手: グー', 0xA,0
    rock_msg_len equ $ - rock_msg - 1
    scissors_msg db 'あなたの手: チョキ', 0xA,0
    scissors_msg_len equ $ - scissors_msg - 1
    paper_msg db 'あなたの手: パー', 0xA,0
    enemy_rock_msg db '相手の手: グー', 0xA,0
    enemy_rock_msg_len equ $ - enemy_rock_msg - 1
    enemy_scissors_msg db '相手の手: チョキ', 0xA,0
    enemy_scissors_msg_len equ $ - enemy_scissors_msg - 1
    enemy_paper_msg db '相手の手: パー', 0xA,0
    enemy_paper_msg_len equ $ - enemy_paper_msg - 1
    paper_msg_len equ $ - paper_msg - 1
    draw_msg db 'あいこ', 0xA,0
    draw_msg_len equ $ - draw_msg - 1
    win_msg db 'あなたの勝ち', 0xA,0
    win_msg_len equ $ - win_msg - 1
    lose_msg db 'あなたの負け', 0xA,0
    lose_msg_len equ $ - lose_msg - 1
    invalid_input_msg db '無効な入力です', 0xA,0
    invalid_input_msg_len equ $ - invalid_input_msg - 1
    timespec:
        timespec_sec dq 2
        timespec_nsec dq 0
    fivesec:
        fivesec_sec dq 5
        fivesec_nsec dq 0    

section .text
    global _start

_start:

    mov [stack_start], rsp


    lea rsi, [title]
    mov rdx, title_len
    call print_string

    mov rax, 35
    lea rdi, [timespec]
    xor rsi, rsi
    syscall

    lea rsi, [cursor_up]
    mov rdx, cursor_up_len
    call print_string

    lea rsi, [gameinfo]
    mov rdx, gameinfo_len
    call print_string

    mov rax, 35
    lea rdi, [timespec]
    xor rsi, rsi
    syscall

    lea rsi, [cursor_up]
    mov rdx, cursor_up_len
    call print_string


    lea rsi, [gameinfo2]
    mov rdx, gameinfo2_len
    call print_string

    mov rax, 35
    lea rdi, [timespec]
    xor rsi, rsi
    syscall

    lea rsi, [cursor_up]
    mov rdx, cursor_up_len
    call print_string

    ; Get user input
    lea rsi, [buffer]
    mov rdx, 64
    mov rax, 0
    mov rdi, 0
    syscall

    mov r10, rax

    movzx rax, byte [buffer] ; 1バイトの入力を取得
    cmp rax, '1'
    jl invalid_input
    cmp rax, '3'
    jg invalid_input

    lea rsi, [buffer]
    mov rdx, r10
    call print_buffer_hand

    rdtsc
    mov [random_value], eax
    mov eax, [random_value]
    mov ecx, 3
    xor edx, edx
    div ecx

    add edx, 1

    call print_enemy_hand

    lea rsi, [buffer]
    call calculate_result

    mov rax, 60
    xor rdi, rdi
    syscall

; 引数: rsi: 文字列のポインタ, rdx: 文字列の長さ
print_string:
    push rax
    push rdi
    push rsi
    push rdx
    push rcx

    lea rdi, [buffer]
    mov rcx, 64
    xor al, al
    rep stosb
    
    lea rdi, [buffer]
    mov rcx, rdx
    push rcx

    .copy_loop:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi
        dec rcx
        jnz .copy_loop

    mov rax, 1
    mov rdi, 1
    lea rsi, [buffer]
    pop rdx
    syscall

    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret    

; 引数: rsi: 文字列のポインタ, rdx: 文字列の長さ
print_buffer:
    push rax
    push rdi
    push rsi
    push rdx

    mov rax, 1
    mov rdi, 1

    syscall

    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret    

print_buffer_hand:
    push rax
    push rdi
    push rsi
    push rdx

    
    cmp byte [rsi], '1'
    je .rock
    cmp byte [rsi], '2'
    je .scissors
    cmp byte [rsi], '3'
    je .paper
    jmp .invalid_input

    .rock:
        lea rsi, [rock_msg]
        mov rdx, rock_msg_len
        jmp .print
    .scissors:
        lea rsi, [scissors_msg]
        mov rdx, scissors_msg_len
        jmp .print
    .paper:
        lea rsi, [paper_msg]
        mov rdx, paper_msg_len
        jmp .print
    .invalid_input:
        lea rsi, [invalid_input_msg]
        mov rdx, invalid_input_msg_len
        jmp .print
    .print:
        mov rax, 1
        mov rdi, 1
        syscall
        pop rdx
        pop rsi
        pop rdi
        pop rax
        ret

print_enemy_hand:
    push rax
    push rdi
    push rsi
    push rdx

    cmp edx, 1
    je .rock
    cmp edx, 2
    je .scissors
    cmp edx, 3
    je .paper
    jmp .invalid_input
    .rock:
        lea rsi, [enemy_rock_msg]
        mov rdx, enemy_rock_msg_len
        jmp .print
    .scissors:
        lea rsi, [enemy_scissors_msg]
        mov rdx, enemy_scissors_msg_len
        jmp .print
    .paper:
        lea rsi, [enemy_paper_msg]
        mov rdx, enemy_paper_msg_len
        jmp .print
    .invalid_input:
        lea rsi, [invalid_input_msg]
        mov rdx, invalid_input_msg_len
        jmp .print
    .print:
        mov rax, 1
        mov rdi, 1
        syscall
        pop rdx
        pop rsi
        pop rdi
        pop rax
        ret

; 引数: rsi: 文字列のポインタ, rdx: 1-3のランダムな値
calculate_result:
    push rax
    push rdi
    push rsi
    push rdx

    cmp byte [rsi], '1'
    je .rock
    cmp byte [rsi], '2'
    je .scissors
    cmp byte [rsi], '3'
    je .paper
    jmp invalid_input
    .rock:
        cmp edx, 1
        je .draw
        cmp edx, 2
        je .lose
        jmp .win
    .scissors:
        cmp edx, 1
        je .lose
        cmp edx, 2
        je .draw
        jmp .win
    .paper:
        cmp edx, 1
        je .win
        cmp edx, 2
        je .lose
        jmp .draw
    .draw:
        lea rsi, [draw_msg]
        mov rdx, draw_msg_len
        call print_string
        jmp .end
    .win:
        lea rsi, [win_msg]
        mov rdx, win_msg_len
        call print_string
        jmp .end    
    .lose:
        lea rsi, [lose_msg]
        mov rdx, lose_msg_len
        call print_string
        jmp .end
    .end:
        mov rax, 35
        lea rdi, [fivesec]
        xor rsi, rsi
        syscall

        pop rdx
        pop rsi
        pop rdi
        pop rax
        ret

invalid_input:
    lea rsi, [cursor_up]
    mov rdx, cursor_up_len
    call print_string
    lea rsi, [invalid_input_msg]
    mov rdx, invalid_input_msg_len
    call print_string

    mov rsp, [stack_start]

    lea rdi, [buffer]
    mov rcx, 64
    xor al, al
    rep stosb

    jmp _start