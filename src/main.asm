; Multiplayer Pong!
;
; Authors: Alec and Dmitry
;
; Todo:
;   - Either a button press or a Random Number UART exchange to detrmine who is player 1 and player 2.
;   - Add diagonal support for ball



#import game_logic.asm
#import display_driver.asm
#import symbols.asm



; Inital Logic
main:
    ; Here we are setting page two on the LED board as the visulization
    ; Doesn't really need to be modified beyond that for now.
    ; Here we are just setting the displa to page 2 on the LED board.
    ; This needs to run before any of the visualizations show correctly.
    mov r0, 2 
    mov [0xF0], r0

    ; Clear the screen for the start of the game
    gosub clearscreen

    ; Init the timer
    ; This is used to move the ball at a useable sleep on the LED dislay.
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
    ; Ball data is located on Page 3
    ;
    ; A couple of things happen here: 
    ;   - Set the initial direction of the ball
    ;   - Set the logic to not be waiting for an input signal for UART
    ;   - Set the x and y position of the Ball
    ;   - Draw the ball
    mov r2, Page_Ball
    mov r3, Ball_Direction
    mov r0, 0                                   ; CHANGE ME
    mov [r2:r3], r0
    mov r3, Ball_Recieve_Waiting
    mov r0, 0                                   ; CHANGE ME
    mov [r2:r3], r0

    mov r3, Axis_X
    mov r0, 1
    mov [r2:r3], r0
    mov r8, r0              ; Set x starting position in R8

    mov r3, Axis_Y
    mov r0, 8
    mov [r2:r3], r0
    mov r9, r0              ; Set y starting position in R9
    
    gosub drawpixel	        ; Draw Pixel   

    ; Init the Paddle
    ; Paddle data is located on Page 4
    ; A couple of things happen here as well:
    ;   - Top and Bottom paddle pixel get drawn, those positions are not actually saved.
    ;     This is to save that memory since it can be extrapolated. 
    ;   - Save the paddle middle location to page 4
    ;   - Draw the middle paddle pixel
    mov r8, 7               ; Set x starting position in R8
    mov r9, 9               ; Set y starting position in R9
    gosub drawpixel	        ; Draw Pixel

    mov r8, 7               ; Set x starting position in R8
    mov r9, 7               ; Set y starting position in R9
    gosub drawpixel	        ; Draw Pixel

    mov r2, Page_Paddle

    mov r3, Axis_X
    mov r0, 7
    mov [r2:r3], r0
    mov r8, r0               ; Set x starting position in R8

    mov r3, Axis_Y
    mov r0, 8
    mov [r2:r3], r0
    mov r9, r0               ; Set y starting position in R9
    gosub drawpixel	        ; Draw Pixel

    ; Begin the game loop
    goto waitinput



; Primary game loop
; 
;   - Check if waiting for ball position over UART
;       - Check if recieved ball position
;       - Loop back if ball position not recieved.
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
