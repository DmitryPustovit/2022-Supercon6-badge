moveball:

    mov r2, Page_Ball
    mov r3, Axis_X
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Axis_Y
    mov r0, [r2:r3]
    mov r9, r0

    gosub clearpixel


    mov r2, Page_Ball
    mov r3, Ball_Direction
    mov r0, [r2:r3]
    cp r0, 0
    skip nz, 1
       inc r8 
    cp r0, 1
    skip nz, 1
       dec r8 

    
    gosub drawpixel
    

    mov r2, Page_Ball
    mov r3, Axis_X
    mov r0, r8
    mov [r2:r3], r0
    mov r3, Axis_Y
    mov r0, r9
    mov [r2:r3], r0


    ret r0, 0		; Return



checkballmove:  
    mov r2, Page_Timer

    mov r3, 1
    mov r0, [r2:r3]
    inc r0  
    mov [r2:r3], r0
    cp r0,0
    skip z,1
        ret r0, 0

    mov r3, 2
    mov r0, [r2:r3]
    inc r0
    mov [r2:r3], r0
    cp r0,0
    skip z,1
        ret r0, 0
    
    mov r3, 3
    mov r0, [r2:r3]
    inc r0
    mov [r2:r3], r0
    cp r0,0
    skip z,1
        ret r0, 0

    ret r0, 1



checkballhit: 
    mov r2, Page_Ball
    mov r3, Axis_X
    mov r0, [r2:r3]

    cp r0, 6
    skip z,1
        ret r0, 0

    
    mov r2, Page_Paddle
    mov r3, Axis_Y
    mov r0, [r2:r3]
    mov r4, r0

    mov r2, Page_Ball
    mov r3, Axis_Y
    mov r0, [r2:r3]

    sub r0, r4
    cp r0, 0
    mov r3, Ball_Direction
    skip nz,3
        mov r0, 1
        mov [r2:r3], r0
        ret r0, 0
    ret r0, 1	



checkballtransmit:
    mov r2, Page_Ball
    mov r3, Axis_X
    mov r0, [r2:r3]

    cp r0, 0
    skip z,1
        ret r0, 0
    
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Axis_Y
    mov r0, [r2:r3]
    mov r9, r0
    gosub clearpixel


    mov r2, r9    
    mov r3, r9 

    mov r0, r2        ; Write high nibble to UART
    mov [0xF7], r0    ;
    mov r0, 4        ; Write low nibble to UART
    mov [0xF6], r0    ; Transmit
    mov r0, 1

    mov r2, Page_Ball
    mov r3, Ball_Recieve_Waiting
    mov r0, 1
    mov [r2:r3], r0
    ret r0, 0	



checkrecieve: 
    mov r0, [Received]          ; get keypress status
    cp r0, 0
    skip nz, 1
        ret r0, 1	

    mov r2, Page_Ball
    mov r3, Ball_Recieve_Waiting
    mov r0, 0
    mov [r2:r3], r0

    mov r3, Axis_Y
    mov r0, [0xF7]
    mov [r2:r3], r0

    mov r3, Axis_X
    mov r0, 1
    mov [r2:r3], r0
    mov r3, Ball_Direction
    mov r0, 0
    mov [r2:r3], r0
    mov r0, [0xF6]
    ret r0, 0



up: 
    mov r2, Page_Paddle

    mov r3, Axis_X
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Axis_Y
    mov r0, [r2:r3]
    mov r9, r0
    
    gosub paddleclear
    gosub drawpixel
    dec r9
    gosub drawpixel
    dec r9
    gosub drawpixel
    inc r9

    mov r2, Page_Paddle
    mov r3, Axis_X
    mov r0, r8
    mov [r2:r3], r0
    mov r3, Axis_Y
    mov r0, r9
    mov [r2:r3], r0
    ret r0, 0		; Return



down: 
    mov r2, Page_Paddle
    mov r3, Axis_X
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Axis_Y
    mov r0, [r2:r3]
    mov r9, r0

    gosub paddleclear
    gosub drawpixel
    inc r9
    gosub drawpixel
    inc r9
    gosub drawpixel
    dec r9

    mov r2, Page_Paddle
    mov r3, Axis_X
    mov r0, r8
    mov [r2:r3], r0
    mov r3, Axis_Y
    mov r0, r9
    mov [r2:r3], r0

    ret r0, 0		; Return



paddleclear:
    gosub clearpixel
    inc r9
    gosub clearpixel
    dec r9 
    dec r9 
    gosub clearpixel
    inc r9
    ret R0, 0		; Return



