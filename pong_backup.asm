init:                   ; Alec and Dmitry



; Set Display Page
;
; Here we are just setting the displa to page 2 on the LED board.
; This needs to run before any of the visualizations show correctly.
; 
    mov r0, 2               ; Displays page two on LED board
    mov [0xF0], r0



; Game Logic Loop
; 
; Actual game logic begins here.
; At this point the pixels are displaying.
; This loops endless unless prevented.
; 
main:
    gosub clearscreen	    ; Clear Screen
    ;mov r8, 0
    ;mov r9, 1


    mov r2, Page_Timer
    mov r3, 1 
    mov r0, 0
    mov [r2:r3], r0
    mov r3, 2
    mov r0, 0
    mov [r2:r3], r0
    mov r3, 3
    mov r0, 0
    mov [r2:r3], r0
    mov r3, 4
    mov r0, 0
    mov [r2:r3], r0

    
    ; Init the Ball
    ;
    ; Draw to Screen and save the posotion to page 3
    mov r2, Page_Ball
    mov r3, Ball_Direction
    mov r0, 0                                   ; CHANGE ME
    mov [r2:r3], r0
    mov r3, Ball_Recieve_Waiting
    mov r0, 0                                   ; CHANGE ME
    mov [r2:r3], r0

    mov r3, Paddle_X
    mov r0, 1
    mov [r2:r3], r0
    mov r8, r0              ; Set x starting position in R8

    mov r3, Paddle_Y
    mov r0, 8
    mov [r2:r3], r0
    mov r9, r0              ; Set y starting position in R9
    
    gosub drawpixel	        ; Draw Pixel   

    ; init the Paddle
    ;
    ; Draw the Paddle and save the position to page 4
    mov r8, 7               ; Set x starting position in R8
    mov r9, 9               ; Set y starting position in R9
    gosub drawpixel	        ; Draw Pixel
    mov r8, 7               ; Set x starting position in R8
    mov r9, 7               ; Set y starting position in R9
    gosub drawpixel	        ; Draw Pixel

    mov r2, Page_Paddle

    mov r3, Paddle_X
    mov r0, 7
    mov [r2:r3], r0
    mov r8, r0               ; Set x starting position in R8

    mov r3, Paddle_Y
    mov r0, 8
    mov [r2:r3], r0
    mov r9, r0               ; Set y starting position in R9
    gosub drawpixel	        ; Draw Pixel

    ; Begin the game loop
    goto waitinput


; FIND ME! Main game loop!
waitinput:
    mov r2, Page_Ball
    mov r3, Ball_Recieve_Waiting
    mov r0, [r2:r3]
    cp r0, 1
    skip nz, 2
        gosub checkrecieve
    
    cp r0, 0
    skip z, 2
        goto waitinput

    gosub checkballmove
    cp r0, 1
    skip nz, 2
        gosub moveball

    gosub checkballhit
    cp r0, 1
    skip nz, 2
        goto flashscreen

    gosub checkballtransmit

    mov r0, [KeyStatus]          ; get keypress status
    bit r0, JustPress                    ; tests if not pressed, in Z
    skip nz, 2
        goto waitinput
    mov r0, [KeyReg]
    cp r0, 9
    skip nz, 2
        gosub up
    cp r0, 10
    skip nz, 2
        gosub down

    goto waitinput



moveball:

    mov r2, Page_Ball
    mov r3, Paddle_X
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Paddle_Y
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
    mov r3, Paddle_X
    mov r0, r8
    mov [r2:r3], r0
    mov r3, Paddle_Y
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
    mov r3, Paddle_X
    mov r0, [r2:r3]

    cp r0, 6
    skip z,1
        ret r0, 0

    
    mov r2, Page_Paddle
    mov r3, Paddle_Y
    mov r0, [r2:r3]
    mov r4, r0

    mov r2, Page_Ball
    mov r3, Paddle_Y
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
    mov r3, Paddle_X
    mov r0, [r2:r3]

    cp r0, 0
    skip z,1
        ret r0, 0
    
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Paddle_Y
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

    mov r3, Paddle_Y
    mov r0, [0xF7]
    mov [r2:r3], r0

    mov r3, Paddle_X
    mov r0, 1
    mov [r2:r3], r0
    mov r3, Ball_Direction
    mov r0, 0
    mov [r2:r3], r0
    mov r0, [0xF6]
    ret r0, 0



up: 
    mov r2, Page_Paddle

    mov r3, Paddle_X
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Paddle_Y
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
    mov r3, Paddle_X
    mov r0, r8
    mov [r2:r3], r0
    mov r3, Paddle_Y
    mov r0, r9
    mov [r2:r3], r0
    ret r0, 0		; Return



down: 
    mov r2, Page_Paddle
    mov r3, Paddle_X
    mov r0, [r2:r3]
    mov r8, r0
    mov r3, Paddle_Y
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
    mov r3, Paddle_X
    mov r0, r8
    mov [r2:r3], r0
    mov r3, Paddle_Y
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



clearscreen:
; Zeros everything on page
mov r1, 2	; Page two for right side of display
mov r2, 3	; Page three for left side of display
mov r3, 15	; Row starting on, going up to zero
mov r0, 0b0000	; Set value for clear display
mov [r1:r3], r0 ; Clear right side display with zeros
mov [r2:r3], r0	; Clear left side display with zeros
dsz r3			; Check if at zeroth line
jr -4			; Jump up to clear left side line to loop
mov [r1:r0], r0	; Clear the zeroth line left side as not cleared in above loop
mov [r2:r0], r0	; Clear the zeroth line right side as not cleared in above loop
ret R0, 0		; Return
  
drawpixel:
; Calculate which page pixel is on
mov r1, 2	; Page two for right side of display
mov r2, 3	; Page three for left side of display
mov r0, r8	; Copy R8 into R0 for compare
cp r0, 4	; Compare x value with 4, of larger than 4, we will draw it on right side
skip c, 3	; Skip right draw if r8 value greater than 4
gosub drawright	; Draw right side of screen
jr 2			; Skip over right side draw
gosub drawleft	; Draw left side of screen
ret R0, 0		; Return
  
drawleft:
mov r4, 8		; Set 8 in r4 as value to subtract from
sub r4, r8		; Subtract r4-r8 to get how many bits to shift right
mov r0, 0b0000	; Set R0 to zero just in case
cp r0, 0		; Set the carry flag as 1 with this bogus comparison
rrc r0			; Shift cary flag over r4 times
dsz r4			; Check if carry bit is shifted over r4 times
jr -3			; Loop back to rrc r0 above
mov r4, r0		; Copy r0 to r4
mov r0, [r2:r9]	; Load current pixels
OR	r0, r4		; Add new pixel to screen
mov [r2:r9], r0	; Draw pixel to screen
ret R0, 0		; Return
  
drawright:
mov r4, 4		; Set 4 in r4 as value to subtract from
sub r4, r8		; Subtract r4-r8 to get how many bits to shift 
mov r0, 0b0000	; Set R0 to zero
cp r0, 0		; Set the carry flag as 1 with this bogus comparison
rrc r0			; Shift cary flag over r4 times
dsz r4			; Check if carry bit is shifted over r4 times
jr -3			; Loop back to rrc r0 above
mov r4, r0		; Copy r0 to r4
mov r0, [r1:r9]	; Load current pixels
OR	r0, r4		; Add new pixel to screen
mov [r1:r9], r0	; Draw pixel to screen
ret R0, 0		; Return
  
clearpixel:
; Clear a pixel at location r8 in x, r9 in y
mov r1, 2	; Page two for right side of display
mov r2, 3	; Page three for left side of display
mov r0, r8	; Copy R8 into R0 for compare
cp r0, 4	; Compare x value with 4, of larger than 4, we will clear it on right side
skip c, 3	; Skip right draw if r8 value greater than 4
gosub clearright	; Clear pixel on right side of screen
jr 2			; Skip over right side draw
gosub clearleft	; Clear pixel on left side of screen
ret R0, 0		; Return
  
clearright:
; Clear pixel on right side of screen
mov r0, 0b0010	; Set R0 to known value (1)
mov r3, 0b0111	; Set R3 to all ones
mov r4, 3		; Set 3 in r4 as value to subtract from
sub r4, r8		; Subtract r4-r8 to get how many bits to shift 

mov r0, r4
cp r0, 0
skip z, 3
    rrc r3			; Shift zero over
    dsz r4			; Check if shifted enough time
    jr -3			; Loop back to shifting
mov r0, [r1:r9] ; load pixel row on right side
AND r0, r3		; AND zero bit with pixel values to zero out value
mov [r1:r9], r0	; save pixel row with bit modification
ret R0, 0		; Return

clearleft:
; Clear pixel on left side of screen
mov r0, 0b0010	; Set R0 to known value (1)
mov r3, 0b0111	; Set R3 to all ones
mov r4, 7		; Set 7 in r4 as value to subtract from                                     WARNING: CAN NOT DELETE 4TH PIXEL
sub r4, r8		; Subtract r4-r8 to get how many bits to shift 

mov r0, r4
cp r0, 0
skip z, 3
    rrc r3			; Shift zero over
    dsz r4			; Check if shifted enough time
    jr -3			; Loop back to shifting

mov r0, [r2:r9] ; load pixel row on right side
AND r0, r3		; AND zero bit with pixel values to zero out value
mov [r2:r9], r0	; save pixel row with bit modification
ret r0, 0		; Return


fillscreen:
; Ones everything on page
mov r1, 2	; Page two for right side of display
mov r2, 3	; Page three for left side of display
mov r3, 15	; Row starting on, going up to zero
mov r0, 0b1111	; Set value for clear display
mov [r1:r3], r0 ; Clear right side display with zeros
mov [r2:r3], r0	; Clear left side display with zeros
dsz r3			; Check if at zeroth line
jr -4			; Jump up to clear left side line to loop
mov r3, 0		; Set r3 to zero for placement
mov [r1:r3], r0	; Clear the zeroth line left side as not cleared in above loop
mov [r2:r3], r0	; Clear the zeroth line right side as not cleared in above loop
ret R0, 0		; Return
  
flashscreen:
mov r7, Flash_Count		; Set number of times to flash
mov r0, 3
mov [0xF1], r0
  
gosub clearscreen	; Clear the screen

mov r2, 15		; Count wait
  mov r3, 15		; Count wait
  dsz r3			; Check if zero
  jr -2			; Inner Loop again
dsz r2			; Decrement r5
jr -5			; Out Loop again
  
gosub fillscreen	; Fill the screen
  
mov r1, 15		; Count wait
  mov r2, 15		; Count wait
  dsz r2			; Check if zero
  jr -2			; Inner Loop again
dsz r1			; Decrement r5
jr -5			; Out Loop again
  
dsz r7			; Check if weve flashed enough times
jr -18			; Reflash

mov r0, 0
mov [0xF1], r0  
goto flashscreen
ret R0, 0		; return




; symbols for special registers
Page        EQU 0xf0
Clock       EQU 0xf1
  F_250_kHz EQU 0
  F_100_kHz EQU 1
  F_30_kHz  EQU 2
  F_10_kHz  EQU 3
  F_3_kHz   EQU 4
  F_1_kHz   EQU 5
  F_500_Hz  EQU 6
  F_200_Hz  EQU 7
  F_100_Hz  EQU 8
  F_50_Hz   EQU 9
  F_20_Hz   EQU 10
  F_10_Hz   EQU 11
  F_5_Hz    EQU 12
  F_2_Hz    EQU 13
  F_1_Hz    EQU 14
  F_1_2_Hz  EQU 15
Sync        EQU 0xf2
WrFlags     EQU 0xf3
  LedsOff   EQU 3
  MatrixOff EQU 2
  InOutPos  EQU 1
  RxTxPos   EQU 0
RdFlags     EQU 0xf4
  Vflag     EQU 1
  UserSync  EQU 0       ; cleared after read
SerCtl      EQU 0xf5
  RxError   EQU 3       ; cleared after read
SerLow      EQU 0xf6
SerHigh     EQU 0xf7
Received    EQU 0xf8
AutoOff     EQU 0xf9
OutB        EQU 0xfa
InB         EQU 0xfb
KeyStatus   EQU 0xfc
  AltPress  EQU 3
  AnyPress  EQU 2
  LastPress EQU 1
  JustPress EQU 0       ; cleared after read
KeyReg      EQU 0xfd
Dimmer      EQU 0xfe
Random      EQU 0xff



Page_Ball       EQU 4
Page_Paddle     EQU 5
Page_Timer      EQU 6 
Paddle_X EQU 8
Paddle_Y EQU 9
Ball_Direction EQU 5
Ball_Recieve_Waiting EQU 6
Flash_Count EQU 15