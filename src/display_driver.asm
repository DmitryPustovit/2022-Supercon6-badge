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
