TITLE String Primitives and Macros     (Proj6_solimanj.asm)

; Author: Joey Soliman
; Last Modified: 12/4/2021
; OSU email address: solimanj@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/5/2021
; Description: This program reads the user's numeric input in as a string, converts the string to a numeric SDWORD value
;	to validate it is a number, and converts then numeric value back to a string. Program then prints out the list of
;	integers, their sum, and their truncated average.

INCLUDE Irvine32.inc

;Macros

;-------------------------------------------------------------------
;Name: mGetString

;Display a prompt (input parameter, by reference), then get the user's keyboard input into a memory location (output parameter,
;	by reference). Provide a count (input paramater, by value) for the length of input string that can be accommodated and
;	provide a number of bytes read (output parameter, by reference) by the macro.

;Receives: 
;	OFFSET prompt
;	OFFSET input
;	bufferSize

;Returns: none

;Postconditions: user input stored as string in OFFSET input, input length stored in EAX

;-------------------------------------------------------------------
mGetString	MACRO prompt, input, bufferSize
	
	push	ECX
	push	EDX
	mov		EDX, prompt
	call	WriteString
	mov		EDX, input
	mov		ECX, bufferSize - 1
	call	ReadString
	pop		EDX
	pop		ECX

ENDM

;-------------------------------------------------------------------
;Name: mDisplayString

;Print the string which is stored in a specified memory location (input parameter, by reference).

;Receives:
;	OFFSET display

;Returns: none
;-------------------------------------------------------------------
mDisplayString MACRO display

	push	EDX
	mov		EDX, display
	call	WriteString
	pop		EDX

ENDM

;Constants

ARRAYSIZE	= 10

.data

intro_1			BYTE	"Joey Soliman: Project 6 - String Primitives and Macros",13,10,0
intro_2			BYTE	"Please provide 10 signed decimal integers.",13,10,0
intro_3			BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers,",13,10,0
intro_4			BYTE	"I will display a list of the integers, their sum, and their truncated average value.",13,10,0
prompt_1		BYTE	"Please enter a signed integer: ",0
prompt_2		BYTE	"ERROR: You did not enter a signed integer, or your number was too big.",13,10,0
prompt_3		BYTE	"Please try again: ",0
display_num		BYTE	"You entered the following numbers:",13,10,0
display_sum		BYTE	"The sum of these numbers is: ",0
display_avg		BYTE	"The truncated average is: ",0
outro_1			BYTE	"Goodbye!",13,10,0
comma			BYTE	", ",0

userInput		BYTE	20 DUP(?)
bufferSize		SDWORD	SIZEOF userInput
inputLength		SDWORD	?
userNum			SDWORD	0
count			SDWORD	0
numArray		SDWORD	ARRAYSIZE DUP(?)
sum				SDWORD	0
avg				SDWORD	?
number			SDWORD	?
asciiArray		BYTE	20 DUP(?)

.code
main PROC

;-----------------------------
;Introduce the program and provide instructions
;-----------------------------
	mDisplayString	OFFSET intro_1									;display intro statements
	call	CrLf
	mDisplayString	OFFSET intro_2
	mDisplayString	OFFSET intro_3
	mDisplayString	OFFSET intro_4
	call	CrLf

;-----------------------------
;Gather input using readVal procedure.
;Uses a loop to get 10 valid integers from the user.
;readVal will be called within the loop.
;Stores these numeric values in an array.
;-----------------------------
	mov		ECX, 10													;initialize ECX for 10 loops
	mov		EDI, OFFSET numArray									;EDI points to address of numArray
_getVals:
	push	OFFSET prompt_1											;setup for readVal
	push	OFFSET prompt_2
	push	OFFSET prompt_3
	push	OFFSET userInput
	push	OFFSET bufferSize
	push	OFFSET userNum
	call	readVal
	mov		EAX, userNum											
	add		sum, EAX												;add to the sum
	mov		[EDI], EAX												;put userNum into numArray
	add		EDI, 4													;make EDI point to next slot in numArray
	mov		userNum, 0												;reset userNum to 0
	loop	_getVals
	

;-----------------------------
;Display the integers, their sum, and their truncated average.
;-----------------------------
	call	CrLf
	mDisplayString	OFFSET display_num								;display prompt for numbers
	mov		ECX, 10													;initialize ECX for 10 loops
	mov		EDI, OFFSET numArray									;EDI points to address of numArray
_printNums:
	mov		EAX, [EDI]
	mov		number, EAX
	push	OFFSET userNum											;setup for writeVal
	push	OFFSET asciiArray
	push	number
	call	writeVal
	cmp		ECX, 1													;avoid the extra comma 
	je		_sum
	mDisplayString	OFFSET comma
	add		EDI, 4
	loop	_printNums

_sum:
	call	CrLf
	mDisplayString OFFSET display_sum								;display prompt for sum
	push	OFFSET userNum											;setup for writeVal
	push	OFFSET asciiArray
	push	sum
	call	writeVal

	call	CrLf
	mDisplayString OFFSET display_avg								;display prompt for average
	mov		EAX, sum												;calculate avg by dividing by 10
	mov		EDX, 0
	mov		EBX, 10
	cdq
	idiv	EBX
	mov		avg, EAX												;average with no remainder into avg
	push	OFFSET userNum											;setup for writeVal
	push	OFFSET asciiArray
	push	avg
	call	writeVal


;-----------------------------
;Farewell
;-----------------------------
	call	CrLf
	call	CrLf
	mDisplayString  OFFSET outro_1

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-------------------------------------------------------------------
;Name: readVal

;Invoke the mGetString macro to get user input in form of a string of digits.
;Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD),
;	validating the user's input is a valid number (no letters, symbols, etc).
;Store this one value in a memory variable (output paramter, by reference).

;Receives:
;	[EBP+40]	= OFFSET prompt_1
;	[EBP+36]	= OFFSET prompt_2
;	[EBP+32]	= OFFSET prompt_3
;	[EBP+28]	= OFFSET userInput
;	[EBP+24]	= OFFSET bufferSize
;	[EBP+20]	= OFFSET userNum

;Returns:
;	value of userNum is changed
;-------------------------------------------------------------------
readVal		PROC	
	push	EAX
	push	EDI
	push	ECX
	push	EBP
	mov		EBP, ESP

	mov		EAX, [EBP+24]
	mGetString	[EBP+40], [EBP+28], [EAX]		;get user input, input length in EAX
	cmp		EAX, 0								;if string is empty, jump to _notValid
	je		_notValid
_getInput:
	mov		ECX, EAX							;input length into ECX
	mov		EBX, EAX							;input length also into EBX
	mov		ESI, [EBP+28]						;ESI holds address of userInput
	lodsb
	cmp		AL, 43								;jump to _plus if = 43 (ascii code for +)
	je		_plus
	cmp		AL, 45								;jump to _minus if = 45 (ascii code for -)
	je		_minus
_validate:
	cmp		AL, 48								;jump to notValid if less than 48
	jl		_notValid
	cmp		AL, 57								;jump to notValid if greater than 57
	jg		_notValid
	lodsb
	loop	_validate
	mov		EDX, [EBP+28]

	mov		ECX, EBX
	mov		ESI, [EBP+28]						;ESI holds address of userInput
	lodsb
_convert:										;build up numeric value from string								
	cmp		AL, 43								;jump to _plus2 if = 43 (ascii code for +)
	je		_plus2
	cmp		AL, 45								;jump to _minus2 if = 45 (ascii code for -)
	je		_minus2
	mov		EDI, [EBP+20]						;EDI holds address of userNum
	mov		BL, AL								;BL placeholder for digit
	sub		EBX, 48								;subtract 48 to get digit value
	mov		EAX, [EDI]
	mov		EDX, 10
	mul		EDX
	add		EAX, EBX
	mov		[EDI], EAX
	lodsb										;load next byte into AL
	loop	_convert
	cmp		EAX, 0
	jl		_notValid
	jmp		_valid

_plus:
	dec		ECX
	dec		EBX
	lodsb
	jmp		_validate

_minus:
	dec		ECX
	dec		EBX
	lodsb
	jmp		_validate

_plus2:
	lodsb
	jmp		_convert

_minus2:
	lodsb
	jmp		_convert

_valid:
	mov		ESI, [EBP+28]						;ESI holds address of userInput
	lodsb
	cmp		AL, 45
	je		_negative
	jmp _done

_negative:
	mov		EDI, [EBP+20]						;EDI holds address of userNum
	mov		EAX, [EDI]
	mov		EBX, -1
	mul		EBX
	mov		[EDI], EAX
	jmp _done

_notValid:
	mDisplayString	[EBP+36]
	mov		EAX, [EBP+24]
	mGetString		[EBP+32], [EBP+28], [EAX]
	jmp		_getInput

_done:

	pop		EBP
	pop		ECX
	pop		EDI
	pop		EAX
	RET		24
readVal		ENDP

;-------------------------------------------------------------------
;Name: writeVal

;Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits.
;Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.

;Receives:
;	[EBP+40]	= OFFSET userNum
;	[EBP+36]	= OFFSET asciiArray
;	[EBP+32]	= number

;Returns: none
;-------------------------------------------------------------------
writeVal	PROC
	push	EAX
	push	EBX
	push	ECX
	push	EDX
	push	ESI
	push	EDI
	push	EBP
	mov		EBP, ESP

	mov		ECX, 0
	mov		EDI, [EBP+36]							;address of array to store string into EDI
	mov		EAX, [EBP+32]							;number to print into EAX
	cmp		EAX, 0
	jl		_neg
_toString:
	mov		EDX, 0
	mov		EBX, 10
	div		EBX
	add		EDX, 48
	mov		EBX, EAX
	mov		EAX, EDX
	stosb											;store byte into asciiArray
	cmp		EBX, 0
	je		_print
	inc		ECX
	mov		EAX, EBX
	jmp		_toString


_neg:												;remove negative for now
	mov		EBX, -1
	mul		EBX
	jmp		_toString

_neg2:												;print "-"
	mov		EAX, 45	
	mov		EDI, [EBP+40]
	mov		[EDI], EAX
	mDisplayString	EDI
	jmp		_print2

_print:
	mov		EDI, [EBP+36]							;address of array to store string into EDI
	mov		EAX, [EBP+32]							;number to print into EAX
	cmp		EAX, 0
	jl		_neg2
_print2:
	mov		ESI, [EBP+36]							;address of ascii array into ESI
	add		ESI, ECX								;get to the end of array
	inc		ECX
_print3:
	std												;set direction flag to read backwards through ascii array
	lodsb											;load byte to print
	mov		EDI, [EBP+40]
	mov		[EDI], AL
	mDisplayString	EDI
	loop	_print3
	


	pop		EBP
	pop		EDI
	pop		ESI
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	RET		12
writeVal	ENDP



END main
