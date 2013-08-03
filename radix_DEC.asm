 .MODEL SMALL
 .STACK 100H

 .DATA
    PROMPT_1  DB  'The contents of the array before sorting : $'
    PROMPT_2  DB  0DH,0AH,'The contents of the array after sorting : $'

    ARRAY   DB  51,41,19,6,48,25,23,7,8,4   
	SARRAY DB 10 DUP(0)
	ARRAY_STACK DW ?
	SARRAY_STACK DW ?   
	C_ARRAY_STACK DW ?
	C_SARRAY_STACK DW ?
	COL DW ?
	COUNT DW ?
 
 .CODE
   MAIN PROC
     MOV AX, @DATA                ; initialize DS
     MOV DS, AX

     MOV BX, 10                   ; set BX=10

     LEA DX, PROMPT_1             ; load and display the string PROMPT_1
     MOV AH, 9
     INT 21H

     LEA SI, ARRAY                ; set SI=offset address of ARRAY

     CALL PRINT_ARRAY             ; call the procedure PRINT_ARRAY

     LEA SI, ARRAY                ; set SI=offset address of the ARRAY

     CALL RADIX_SORT             ; call the procedure RADIX_SORT

     LEA DX, PROMPT_2             ; load and display the string PROMPT_2
     MOV AH, 9
     INT 21H

     LEA SI, ARRAY                ; set SI=offset address of ARRAY

     CALL PRINT_ARRAY             ; call the procedure PRINT_ARRAY

     MOV AH, 4CH                  ; return control to DOS
     INT 21H
   MAIN ENDP

 ;**************************************************************************;
 ;**************************************************************************;
 ;-------------------------  Procedure Definitions  ------------------------;
 ;**************************************************************************;
 ;**************************************************************************;

 ;**************************************************************************;
 ;-----------------------------  PRINT_ARRAY  ------------------------------;
 ;**************************************************************************;

 PRINT_ARRAY PROC
   ; this procedure will print the elements of a given array
   ; input : SI=offset address of the array
   ;       : BX=size of the array
   ; output : none

   PUSH AX                        ; push AX onto the STACK   
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK

   MOV CX, BX                     ; set CX=BX

   @PRINT_ARRAY:                  ; loop label
     XOR AH, AH                   ; clear AH
     MOV AL, [SI]                 ; set AL=[SI]

     CALL OUTDEC                  ; call the procedure OUTDEC

     MOV AH, 2                    ; set output function
     MOV DL, 20H                  ; set DL=20H
     INT 21H                      ; print a character

     INC SI                       ; set SI=SI+1
   LOOP @PRINT_ARRAY              ; jump to label @PRINT_ARRAY while CX!=0

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP AX                         ; pop a value from STACK into AX

   RET                            ; return control to the calling procedure
 PRINT_ARRAY ENDP

 ;**************************************************************************;
 ;----------------------------  RADIX_SORT  -------------------------------;
 ;**************************************************************************;

 RADIX_SORT PROC
   ; this procedure will sort the array in ascending order
   ; input : SI=offset address of the array
   ;       : BX=array size
   ; output :none

   PUSH AX                        ; push AX onto the STACK  
   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK
   PUSH DI                        ; push DI onto the STACK
  
	CMP BX, 1
	JLE @END_RADIX_SORT
	
	MOV ARRAY_STACK, SI
	LEA SI, SARRAY
	MOV SARRAY_STACK, SI
	MOV COL,1

	
	@OUTER_LOOP:
	 MOV CX, BX
	 
	 
	 MOV AX,SARRAY_STACK
	 MOV C_SARRAY_STACK, AX
	
	MOV AX,ARRAY_STACK
	 MOV C_ARRAY_STACK, AX
	
	 @INNER_LOOP_0:
		MOV SI,C_ARRAY_STACK
		MOV AL, [SI]
		MOV AH, [SI]
		INC SI
		MOV C_ARRAY_STACK, SI
		
		PUSH CX
		
		MOV CX, COL
		RCR_LOOP:
			RCR AL,1
		   
		LOOP RCR_LOOP
		
		POP CX
		
		JNC @SKIP_0
		
		MOV SI,C_SARRAY_STACK 
		MOV [SI], AH
		INC SI
		MOV C_SARRAY_STACK, SI
	@SKIP_0:
		
	    LOOP @INNER_LOOP_0   
	    
	 MOV CX, BX
	MOV AX,ARRAY_STACK
	 MOV C_ARRAY_STACK, AX
	
	 @INNER_LOOP_1:
		MOV SI,C_ARRAY_STACK
		MOV AL, [SI]
		MOV AH, [SI]
		INC SI
		MOV C_ARRAY_STACK, SI
		
		PUSH CX
		
		MOV CX, COL
		
		RCR_LOOP_1:
			RCR AL,1
		LOOP RCR_LOOP_1
		
		POP CX
		
		JC @SKIP_1
		
	
		MOV SI,C_SARRAY_STACK 
		MOV [SI], AH
		INC SI
		MOV C_SARRAY_STACK, SI
	@SKIP_1:
		
	LOOP @INNER_LOOP_1
	
	INC COL
	CALL COPY_ARRAY
	
  
	
	CMP COL, 8
	JLE @OUTER_LOOP
	@END_RADIX_SORT:

	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
   RET                            ; return control to the calling procedure
 RADIX_SORT ENDP

 ;**************************************************************************;
 ;----------------------------  COPY_ARRAY  -------------------------------;
 ;**************************************************************************;
COPY_ARRAY PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH SI

	
	MOV CX, BX
	PUSH ARRAY_STACK
	PUSH SARRAY_STACK
	COPY_LOOP:
		POP SI
		MOV AL, [SI]
		INC SI
		MOV BX, SI
		POP SI
		XCHG [SI], AL
		INC SI
		PUSH SI
		PUSH BX
		DEC BX
		MOV SI, DX
		MOV [SI], AL
	LOOP COPY_LOOP
	
    POP AX
    POP AX
    
	POP SI
	POP CX
	POP BX
	POP AX
	RET
 COPY_ARRAY ENDP
 ;**************************************************************************;
 ;--------------------------------  OUTDEC  --------------------------------;
 ;**************************************************************************;

 OUTDEC PROC
   ; this procedure will display a decimal number
   ; input : AX
   ; output : none

   PUSH BX                        ; push BX onto the STACK
   PUSH CX                        ; push CX onto the STACK
   PUSH DX                        ; push DX onto the STACK

   XOR CX, CX                     ; clear CX
   MOV BX, 10                     ; set BX=10

   @OUTPUT:                       ; loop label
     XOR DX, DX                   ; clear DX
     DIV BX                       ; divide AX by BX
     PUSH DX                      ; push DX onto the STACK
     INC CX                       ; increment CX
     OR AX, AX                    ; take OR of Ax with AX
   JNE @OUTPUT                    ; jump to label @OUTPUT if ZF=0

   MOV AH, 2                      ; set output function

   @DISPLAY:                      ; loop label
     POP DX                       ; pop a value from STACK to DX
     OR DL, 30H                   ; convert decimal to ascii code
     INT 21H                      ; print a character
   LOOP @DISPLAY                  ; jump to label @DISPLAY if CX!=0

   POP DX                         ; pop a value from STACK into DX
   POP CX                         ; pop a value from STACK into CX
   POP BX                         ; pop a value from STACK into BX

   RET                            ; return control to the calling procedure
 OUTDEC ENDP

 ;**************************************************************************;
 ;--------------------------------------------------------------------------;
 ;**************************************************************************;

 END MAIN

 ;**************************************************************************;
 ;**************************************************************************;
 ;------------------------------  THE END  ---------------------------------;
 ;**************************************************************************;
 ;**************************************************************************;