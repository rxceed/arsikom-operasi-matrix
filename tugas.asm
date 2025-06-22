section .data
    ;constant untuk syscall
    sys_write equ 4
    sys_out equ 1

    ;variable
    bufferLen equ 32
    newLine db 0xa
    space db 0x9

    rows equ 2
    cols equ 2
    matrix_1 dd 4, 7, 6, 10
    matrix_2 dd 3, 5, 2, 9
    matrix_3 dd 13, 5, 8, 21

    msg1 db 'Isi matrix_1:'
    msg2 db 'Isi matrix_2:'
    msg3 db 'Isi matrix_3:'
    msgSum db 'Hasil penjumlahan matrix_1 + matrix_2:'
    msgSub db 'Hasil pengurangan matrix_3 - matrix_2:'
    msg1Len equ 13
    msg2Len equ 13
    msg3Len equ 13
    msgSumLen equ 38
    msgSubLen equ 38

section .bss
    ;variable
    numToConvert resd 1
    buffer resb 32
    matrixToDisplay resd rows*cols

section .text
    global _start

    _start:
        MOV ECX, msg1
        MOV EDX, msg1Len
        CALL print

        MOV ESI, matrixToDisplay
        MOV EAX, matrix_1
        CALL copyMatrix
        CALL displayMatrix

        CALL printNewLine

        MOV ECX, msg2
        MOV EDX, msg2Len
        CALL print

        MOV ESI, matrixToDisplay
        MOV EAX, matrix_2
        CALL copyMatrix
        CALL displayMatrix

        CALL printNewLine

        MOV ECX, msg3
        MOV EDX, msg3Len
        CALL print

        MOV ESI, matrixToDisplay
        MOV EAX, matrix_3
        CALL copyMatrix
        CALL displayMatrix

        CALL printNewLine

        MOV ECX, msgSum
        MOV EDX, msgSumLen
        CALL print

        MOV ESI, matrix_1
        MOV EAX, matrix_2
        CALL sumMatrix

        MOV ESI, matrixToDisplay
        MOV EAX, matrix_1
        CALL copyMatrix
        CALL displayMatrix

        CALL printNewLine

        MOV ECX, msgSub
        MOV EDX, msgSubLen
        CALL print

        MOV ESI, matrix_3
        MOV EAX, matrix_2
        CALL subMatrix

        MOV ESI, matrixToDisplay
        MOV EAX, matrix_3
        CALL copyMatrix
        CALL displayMatrix

        MOV EAX, sys_out    ; exit program
        MOV EBX, 0
        int 0x80

    ; subroutine untuk print
    ; yang harus disiapkan sebelum call subroutine:
    ; mengisi register ECX dengan string yang ingin di-print
    ; mengisi register EDX dengan panjang string
    print:
        MOV EAX, sys_write
        MOV EBX, 1
        int 0x80

        MOV EAX, sys_write
        MOV EBX, 1
        MOV ECX, newLine
        MOV EDX, 1
        int 0x80
        RET

    ; subroutine untuk print isi buffer
    printBuffer:
        MOV EAX, sys_write
        MOV EBX, 1
        MOV ECX, buffer
        MOV EDX, bufferLen
        int 0x80

        MOV EAX, sys_write
        MOV EBX, 1
        MOV ECX, newLine
        MOV EDX, 1
        int 0x80
        RET

    ; subroutine untuk print new line
    printNewLine:
        MOV EAX, sys_write
        MOV EBX, 1
        MOV ECX, newLine
        MOV EDX, 1
        int 0x80
        RET
    
    ; subroutine untuk print matrix
    ; matrix yang diprint adalah matrix
    ; pada variable matrixToDisplay
    ; yang harus disiapkan sebelum call subroutine:
    ; mengisi variable matrixToDisplay dengan matrix yang
    ; ingin di-print
    displayMatrix:
        MOV ECX, rows
        MOV EBX, 0
        displayMatrix_loop:
        PUSH ECX
            printCols:
                MOV ECX, cols
                printCols_loop:
                PUSH ECX
                MOV EDX, [matrixToDisplay+EBX*4]
                PUSH EBX
                MOV [numToConvert], EDX
                CALL numberToString
                MOV EAX, sys_write
                MOV EBX, 1
                MOV ECX, buffer
                MOV EDX, bufferLen
                int 0x80

                MOV EAX, sys_write
                MOV EBX, 1
                MOV ECX, space
                MOV EDX, 1
                int 0x80

                POP EBX
                ADD EBX, 1
                POP ECX
                LOOP printCols_loop
        PUSH EBX
        CALL printNewLine
        POP EBX
        POP ECX
        LOOP displayMatrix_loop
        RET
    
    ; subroutine untuk copy isi matrix ke matrix lain
    ; yang harus disiapkan sebelum call subroutine:
    ; mengisi register ESI dengan matrix tujuan copy
    ; mengisi register EAX dengan matrix yang ingin di-copy
    copyMatrix:
        MOV ECX, rows*cols
        MOV EBX, 0
        copyMatrix_loop:
        MOV EDX, [EAX+EBX*4]
        MOV [ESI], EDX
        ADD ESI, 4
        ADD EBX, 1
        LOOP copyMatrix_loop
        RET

    ; subroutine untuk menjumlahkan matrix dengan matrix lain
    ; yang harus disiapkan sebelum call subroutine:
    ; mengisi register ESI dengan matrix destination
    ; mengisi register EAX dengan matrix source
    ; hasil penjumlahan disimpan di matrix destination
    ; rumus: destination = destination + source
    sumMatrix:
        MOV EBX, 0
        MOV ECX, rows*cols
        sumMatrix_loop:
            MOV EDX, [EAX+EBX*4]
            ADD [ESI], EDX
            ADD ESI, 4
            ADD EBX, 1
            LOOP sumMatrix_loop
        RET

    ; subroutine untuk mengurangi matrix dengan matrix lain
    ; yang harus disiapkan sebelum call subroutine:
    ; mengisi register ESI dengan matrix destination
    ; mengisi register EAX dengan matrix source
    ; hasil penjumlahan disimpan di matrix destination
    ; rumus: destination = destination - source
    subMatrix:
        MOV EBX, 0
        MOV ECX, rows*cols
        subMatrix_loop:
            MOV EDX, [EAX+EBX*4]
            SUB [ESI], EDX
            ADD ESI, 4
            ADD EBX, 1
            LOOP subMatrix_loop
        RET

    ; subroutine konversi dari nilai number ke ASCII char agar bisa diprint
    ; dengan syscall sys_write, hasil konversi disimpan di buffer dan dapat
    ; langsung di-print dengan memanggil subroutine printBuffer
    ; yang harus disiapkan sebelum call subroutine:
    ; mengisi variable numToConvert dengan angka yang ingin dikonversi
    numberToString:
    numberToString_phase1:
        MOV EAX, [numToConvert]
        MOV ECX, 0
        numberToString_phase1_loop:
            XOR EDX, EDX
            MOV EBX, 10
            DIV EBX
            ADD EDX, '0'
            PUSH EDX 
            ADD ECX, 1
            TEST EAX, EAX
            JNZ numberToString_phase1_loop  
    numberToString_phase2:
        MOV EBX, ECX
        MOV ECX, bufferLen
        MOV ESI, buffer
        numberToString_phase2_loop:
            TEST EBX, EBX
            JZ return_numberToString
            POP EDX
            MOV [ESI], EDX
            ADD ESI, 1
            SUB EBX, 1
            LOOP numberToString_phase2_loop
    return_numberToString:
        RET