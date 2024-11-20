.ORIG x3000

; Main program
START
        JSR INIT
        JSR DRAW
LOOP    
        JSR UPDATE
        JSR DRAW
        JSR DELAY
        BR LOOP

; Initialize the grid with a simple glider pattern
INIT    
        ST R7, SAVE_R7
        LEA R0, PATTERN    ; Load pattern address
        LD R1, GRID        ; Load grid address
        AND R2, R2, #0     
        ADD R2, R2, #5     ; 5x5 pattern size
INIT_LOOP
        LDR R3, R0, #0     
        STR R3, R1, #0     
        ADD R0, R0, #1     
        ADD R1, R1, #1     
        ADD R2, R2, #-1    
        BRp INIT_LOOP
        LD R7, SAVE_R7
        RET

; Update the grid according to Game of Life rules
UPDATE  
        ST R7, SAVE_R7
        LD R0, GRID        ; Source grid
        LD R1, BUFFER      ; Temporary buffer
        AND R2, R2, #0     
        ADD R2, R2, #8     ; First load 8
        ADD R2, R2, #8     ; Then another 8 = 16
UPDATE_LOOP
        AND R3, R3, #0     ; Clear neighbor count
        JSR COUNT_NEIGHBORS
        JSR APPLY_RULES
        ADD R0, R0, #1     
        ADD R1, R1, #1     
        ADD R2, R2, #-1    
        BRp UPDATE_LOOP
        JSR SWAP_BUFFERS
        LD R7, SAVE_R7
        RET

; Count neighbors for current cell
COUNT_NEIGHBORS
        ST R7, SAVE_R7
        AND R3, R3, #0     ; Clear neighbor count
        LDR R4, R0, #-1    ; Left
        ADD R3, R3, R4
        LDR R4, R0, #1     ; Right
        ADD R3, R3, R4
        ADD R0, R0, #-8    
        ADD R0, R0, #-8    ; Up (offset -16)
        LDR R4, R0, #0     ; Up
        ADD R3, R3, R4
        ADD R0, R0, #8
        ADD R0, R0, #8     ; Back to center
        LD R7, SAVE_R7
        RET

; Apply Game of Life rules
APPLY_RULES
        ST R7, SAVE_R7
        LDR R4, R0, #0     ; Get current cell state
        ADD R5, R3, #-2    ; Check if < 2 neighbors
        BRn KILL
        ADD R5, R3, #-3    ; Check if > 3 neighbors
        BRp KILL
        ADD R5, R3, #-3    ; Check if exactly 3
        BRz BIRTH
        STR R4, R1, #0     ; Keep current state
        BR RULES_DONE
KILL    AND R4, R4, #0
        STR R4, R1, #0
        BR RULES_DONE
BIRTH   AND R4, R4, #0
        ADD R4, R4, #1
        STR R4, R1, #0
RULES_DONE
        LD R7, SAVE_R7
        RET

; Swap grid and buffer
SWAP_BUFFERS
        ST R7, SAVE_R7
        LD R0, GRID
        LD R1, BUFFER
        ST R0, TEMP
        ST R1, GRID
        LD R1, TEMP
        ST R1, BUFFER
        LD R7, SAVE_R7
        RET

; Draw the current state
DRAW    
        ST R7, SAVE_R7
        LD R0, GRID
        LD R1, DISPLAY     
        AND R2, R2, #0     
        ADD R2, R2, #8     
        ADD R2, R2, #8     ; Count to 16
DRAW_LOOP
        LDR R3, R0, #0     ; Load cell state
        STR R3, R1, #0     ; Store to display
        ADD R0, R0, #1     
        ADD R1, R1, #1     
        ADD R2, R2, #-1    
        BRp DRAW_LOOP
        LD R7, SAVE_R7
        RET

; Simple delay
DELAY   
        ST R7, SAVE_R7
        LD R0, DELAY_COUNT
DELAY_LOOP
        ADD R0, R0, #-1
        BRp DELAY_LOOP
        LD R7, SAVE_R7
        RET

; Data and constants
GRID        .FILL x4000   ; Grid memory
BUFFER      .FILL x4100   ; Temporary buffer
DISPLAY     .FILL x4200   ; Display memory
TEMP        .BLKW 1       ; Temporary storage
SAVE_R7     .BLKW 1       ; R7 storage
DELAY_COUNT .FILL #5000   ; Delay amount

; Initial pattern (glider)
PATTERN     .FILL #0
            .FILL #2  
            .FILL #4
            .FILL #7
            .FILL #0

.END
