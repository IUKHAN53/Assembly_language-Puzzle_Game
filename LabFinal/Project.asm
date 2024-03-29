.386
.model flat,stdcall
.stack 4096
 SetConsoleCursorPosition PROTO,
	handle:DWORD,
	pos:DWORD
 ReadConsoleA PROTO,
    handle:DWORD,                     ; input handle
    lpBuffer:PTR BYTE,                ; pointer to buffer
    nNumberOfCharsToRead:DWORD,       ; number of chars to read
    lpNumberOfCharsRead:PTR DWORD,    ; number of chars read
    lpReserved:PTR DWORD      
	GetStdHandle Proto,
	nStdHandle: DWORD
WriteConsoleA PROTO,                   ; write a buffer to the console
    handle:DWORD,                     ; output handle
    lpBuffer:PTR BYTE,                ; pointer to buffer
    nNumberOfCharsToWrite:DWORD,      ; size of buffer
    lpNumberOfCharsWritten:PTR DWORD, ; number of chars written
    lpReserved:PTR DWORD              ; 0 (not used)
GetTickCount PROTO
ExitProcess PROTO, ; exit program
	dwExitCode:DWORD ; return code
CloseHandle PROTO, ; close file handle
	handle:DWORD
CreateFileA PROTO, ; create new file
	pFilename:PTR BYTE, ; ptr to filename
	accessMode:DWORD, ; access mode
	shareMode:DWORD, ; share mode
	lpSecurity:DWORD, ; can be NULL
	howToCreate:DWORD, ; how to create the file
	attributes:DWORD, ; file attributes
	htemplate:DWORD ; handle to template file
ReadFile PROTO, ; read buffer from input file
	fileHandle:DWORD, ; handle to file
	pBuffer:PTR BYTE, ; ptr to buffer
	nBufsize:DWORD, ; number bytes to read
	pBytesRead:PTR DWORD, ; bytes actually read
	pOverlapped:PTR DWORD ; ptr to asynchronous info
GetTimeFormatA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetConsoleTextAttribute PROTO,
	nStdHandle:DWORD, ; console output handle
	nColor:DWORD ; color attribute

.DATA
HIGHLIGHT BYTE 0
SUCCESS BYTE 0
SUCC BYTE 0
SCORE BYTE 42,48,48
DONE DWORD 0
WSIZE DWORD 0
SYSTEMTIME BYTE 12 DUP(0)
TIMEFORMAT BYTE "hh:mm:ss tt",0
UINPUT BYTE 18 DUP(0)
UWORD byte 10 dup(0)
POS WORD 0
COL WORD 0
ROW WORD 0
DIRECTION BYTE 0
ADDRES DWORD 0	;FOR ADDRESS OF RANDOM IN CONDITIONS
DEALT BYTE 0	;FOR WORDS HIDDEN
SIZES BYTE 8 DUP(0)	;WORD SIZES
WORDNO BYTE 0
SPACES BYTE "  "
COUNTER BYTE 0
COMBINATION BYTE 40 DUP(0)
GRID byte 225 dup (0)
RES byte 225 dup (0)
BUFFER BYTE 3500 DUP (0)
WORDS BYTE 96 DUP (0)
seed dword 233
X BYTE 0
LINE1 BYTE 9,9,9,"<=====WELLCOME TO IRFANS FIRST EVER PUZZZLE=====>",10,10
LINE2 BYTE "YOU HAVE 10 MINUTES TO COMPLETE THE PUZZLE YOUR TIME STARTS AT: "
LINE3 BYTE 10,"ENTER WORD,ROW NO,COLUM NO AND DIRECTION NO SEPERATED WITH SPACES:(eg WORD 1 5 4)  : "
LINE4 BYTE "SCORE : "
STIME DWORD 0		;START TIME
ETIME DWORD 0		;ELAPSED
PATTERN BYTE 10,10,9,9,9,9,"0",10,9,9,9,9,"|",10,9,9,9,9,"|",10,9,9,9,"  1-----|-----2",10,9,9,9,"       /|\",10,9,9,9,"      / | \",10,9,9,9,"    3/  |  \4",10,9,9,9,"        5"
NEXTLINE WORD 10
PATH BYTE "C:\Users\IU KHAN\Desktop\words.txt"
.code

generaterandom proc uses ebx edx
mov ebx, eax ; maximum value
mov eax, 343FDh
imul seed
add eax, 269EC3h
mov seed, eax ; save the seed for the next call
ror eax,8 ; rotate out the lowest digit
mov edx,0
div ebx ; divide by max value
mov eax, edx ; return the remainder
ret
generaterandom endp

MAINSCREEN PROC USES EAX
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET LINE1, LENGTHOF LINE1, offset x, 0
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET LINE2, LENGTHOF LINE2, offset x, 0
INVOKE GETTIMEFORMATA,0800H,0,0,OFFSET TIMEFORMAT,OFFSET SYSTEMTIME,LENGTHOF SYSTEMTIME
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET SYSTEMTIME, LENGTHOF SYSTEMTIME, offset x, 0
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET PATTERN, LENGTHOF PATTERN, offset x, 0
RET
MAINSCREEN ENDP


GETINPUT PROC USES ECX
MOV AL,1
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET LINE3, LENGTHOF LINE3, offset x, 0
invoke GetStdHandle, -10
invoke READConsoleA, eax, OFFSET UINPUT, LENGTHOF UINPUT, offset x, 0
CALL VALIDATEINP
CMP SUCC,AL
JE HAHA
CALL CLSSIFYINP
CALL CHECKWORD
JMP LOLS
HAHA:
	CALL SUBSCORE
	MOV EBX,001C0000H
	CALL CURSORMOVEMENT
LOLS:
RET
GETINPUT ENDP


CLSSIFYINP PROC	USES ECX EBX	; DIVIDE INPUT to 3 parts
MOV ESI,OFFSET UINPUT
MOV EDI,OFFSET UWORD
MOV EBX,0
L0:
	MOV AL,[ESI]
	CMP AL," "
	JE ENDLOOP0
	MOV [EDI],AL
	INC ESI
	INC EDI
	INC EBX
	JMP L0

ENDLOOP0:
	;FILL WITH ZEROES
	MOV ECX,10
	SUB ECX,EBX
	L00:
	MOV AL,0
	MOV [EDI],AL
	INC EDI
	LOOP L00
	
	;NEXT COL
	INC ESI
	MOV AL,[ESI]
	CMP AL," "
	JE ENDLOOP1
	SUB AL,48
	MOV AH,AL
	INC ESI
	
	MOV AL,[ESI]
	CMP AL," "
	JE ENDLOOP1
	SUB AL,48
	MOV	AH,10
	ADD AH,AL
	INC ESI
		
ENDLOOP1:
	MOV BYTE PTR ROW,AH
	INC ESI	
	MOV AL,[ESI]
	CMP AL," "
	JE ENDLOOP2
	SUB AL,48
	MOV AH,AL
	INC ESI
	
	MOV AL,[ESI]
	CMP AL," "
	JE ENDLOOP2
	SUB AL,48
	MOV	AH,10
	ADD AH,AL
	INC ESI
ENDLOOP2:
	MOV BYTE PTR COL,AH
	INC ESI
	MOV AL,[ESI]
	SUB AL,48
	MOV direction,AL
RET
CLSSIFYINP ENDP

VALIDATEINP PROC USES ESI EAX EBX
MOV ESI,OFFSET UINPUT
MOV ECX,10
L1:
	MOV AL,48
	CMP [ESI],AL
	JL SEC
	JMP OK
	SEC:
	MOV AL,00
	CMP [ESI],AL
	JNE SECO
	CMP ECX,10
	JGE WRONG
	SECO:
	MOV AL,32
	CMP [ESI],AL
	JNE WRONG
	OK:
	INC ESI
LOOP L1
MOV SUCC,0
JMP ENDPR
WRONG:
	MOV AL,1
	MOV SUCC,AL
ENDPR:
RET
VALIDATEINP ENDP

SHOWSCORE PROC
MOV EBX,00030040H
CALL CURSORMOVEMENT
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET LINE4, LENGTHOF LINE4, offset x, 0
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET SCORE, LENGTHOF SCORE, offset x, 0
MOV EBX,001C0000H
CALL CURSORMOVEMENT
XOR ECX,ECX
RET
SHOWSCORE ENDP

ADDSCORE PROC USES EAX ESI
MOV EBX,00030048H
CALL CURSORMOVEMENT
MOV ESI,OFFSET SCORE
MOV AH,1
MOV AL,[ESI]
CMP AL,45
JE OW
JMP BOW
JMP FURR
OW:
	INC ESI
	SUB [ESI],AH
	JMP FURR
BOW:
	INC ESI
	ADD [ESI],AH
	DEC ESI
	MOV AL,43
	MOV [ESI],AL
FURR:
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET SCORE, LENGTHOF SCORE, offset x, 0
MOV EBX,001C0000H
CALL CURSORMOVEMENT
RET
ADDSCORE ENDP

SUBSCORE PROC USES EAX ESI
MOV EBX,00030048H
CALL CURSORMOVEMENT
MOV ESI,OFFSET SCORE
MOV AH,1
MOV AL,[ESI]
CMP AL,45
JE SEC
INC ESI
MOV AL,[ESI]
CMP AL,48
JE PURR
JMP IFELSE
SEC:
	INC ESI
	ADD [ESI],AH
	JMP FURR
PURR:
	ADD [ESI],AH
	DEC ESI
	MOV AL,45
	MOV [ESI],AL
	JMP FURR
IFELSE:
	SUB [ESI],AH
FURR:
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET SCORE, LENGTHOF SCORE, offset x, 0
MOV EBX,001C0000H
CALL CURSORMOVEMENT
RET
SUBSCORE ENDP

CHECKWORD PROC
MOV AL,0
MOV SUCCESS,AL
MOV EAX,21
MOV DONE,EAX
MOV AX,ROW
MOV BX,COL
DEC AX
IMUL AX,15
ADD AX,BX
MOV POS,AX
MOV AL,DIRECTION
CMP AL,0
	JNE CON1
	CALL CHECK0
	JMP L1
	CON1:
		CMP AL,1
		JNE CON2
		CALL CHECK1
		JMP L1
		CON2:
			CMP AL,2
			JNE CON3
			CALL CHECK2
			JMP L1
			CON3:
				CMP AL,3
				JNE CON4
				CALL CHECK3
				JMP L1
				CON4:
					CMP AL,4
					JNE CON5
					CALL CHECK4
					JMP L1
					CON5:
						CALL CHECK5
L1:
	MOV BL,7
	MOV BH,0
	INVOKE GETSTDHANDLE,-11
	INVOKE SETCONSOLETEXTATTRIBUTE,EAX,EBX
	MOV EBX,001C0000H
	CALL CURSORMOVEMENT
	MOV EAX,21
	CMP DONE,EAX
	JE OWCH
	MOV ESI,DONE
	DEC ESI
	MOV ECX,WSIZE
	LOOP1:
		MOV AL,0
		MOV [ESI],AL
		DEC ESI
	LOOP LOOP1
OWCH:
	MOV AL,0
	CMP SUCCESS,AL
	JNE ADDITION
	JMP SUBTRACTION
ADDITION:
	CALL ADDSCORE
	JMP ENDPROCED
SUBTRACTION:
	CALL SUBSCORE
ENDPROCED:
RET
CHECKWORD ENDP


CHECK0 PROC
MOV EDI,OFFSET UWORD
XOR ECX,ECX
L00:
MOV AL,[EDI]
CMP AL,'a'
JL ENDN
INC ECX
INC EDI
JMP L00
ENDN:
MOV WSIZE,ECX
MOV EDI,OFFSET UWORD
MOV ESI,0
MOVZX EAX,POS
DEC EAX
ADD ESI,EAX
MOV EDX,ESI
L1:
	MOV AL,[EDI]
	MOV AH,GRID[ESI]
	CMP AL,AH
	JNE ENDLOOP
	MOV AL,RES[ESI]
	CMP AL,42
	JNE ENDLOOP
	SUB ESI,15
	INC EDI
LOOP L1
CMP ECX,0
JNE ENDLOOP
;SEARCH AND REMOVE WORD FROM WORDLIST
;CHECKING WORD IN WORDLIST
;
MOV ESI,OFFSET WORDS
MOV ECX,LENGTHOF WORDS
SUB ECX,WSIZE
LOOP1:
	MOV EBX,ESI
	MOV EDI,OFFSET UWORD
	PUSH ECX
	XOR ECX,ECX
	LOOP2:
		MOV AH,[EBX]
		MOV AL,[EDI]
		CMP AL,AH
		JNE OHHH
		INC EBX
		INC EDI
		INC ECX
		JMP LOOP2
	OHHH:
		CMP ECX,WSIZE
		JE FOUND
	INC ESI
	POP ECX
LOOP LOOP1
JMP ENDLOOP
FOUND:
MOV DONE,EBX
POP ECX
MOV EDI,EDX
MOV ESI,WSIZE
L3:
MOV AL,1
MOV SUCCESS,AL
CMP ESI,0
JE ENDLOOP	
MOV EBX,000C0000H
MOV AX,ROW
SHL EAX,16
MOV AX,COL
DEC AX
IMUL AX,3
ADD EBX,EAX
CALL CURSORMOVEMENT
XOR EBX,EBX
MOV BL,7
SHL BL,4
XOR BH,BH
INVOKE GETSTDHANDLE,-11
INVOKE SETCONSOLETEXTATTRIBUTE,EAX,EBX
MOV BL,GRID[EDI]
MOV HIGHLIGHT,BL
invoke GetStdHandle, -11
invoke WriteConsoleA, EAX,OFFSET HIGHLIGHT, 1, offset x, 0
DEC ROW
MOV RES[EDI],126
SUB EDI,15
DEC ESI
JMP L3
ENDLOOP:
	MOV EBX,000C0000H
	CALL CURSORMOVEMENT
RET
CHECK0 ENDP


CHECK1 PROC
MOV EDI,OFFSET UWORD
XOR ECX,ECX
L00:
MOV AL,[EDI]
CMP AL,'a'
JL ENDN
INC ECX
INC EDI
JMP L00
ENDN:
MOV WSIZE,ECX
MOV EDI,OFFSET UWORD
MOV ESI,OFFSET GRID
MOVZX EAX,POS
DEC EAX
ADD ESI,EAX
MOV EDX,ESI
L1:
	MOV AL,[EDI]
	MOV AH,[ESI]
	CMP AL,AH
	JNE ENDLOOP
	DEC ESI
	INC EDI
LOOP L1
CMP ECX,0
JNE ENDLOOP
;
MOV ESI,OFFSET WORDS
MOV ECX,LENGTHOF WORDS
SUB ECX,WSIZE
LOOP1:
	MOV EBX,ESI
	MOV EDI,OFFSET UWORD
	PUSH ECX
	XOR ECX,ECX
	LOOP2:
		MOV AH,[EBX]
		MOV AL,[EDI]
		CMP AL,AH
		JNE OHHH
		INC EBX
		INC EDI
		INC ECX
		JMP LOOP2
	OHHH:
		CMP ECX,WSIZE
		JE FOUND
	INC ESI
	POP ECX
LOOP LOOP1
JMP ENDLOOP
FOUND:
MOV DONE,EBX
POP ECX
MOV EDI,EDX
MOV ESI,WSIZE
L3:
MOV AL,1
MOV SUCCESS,AL
CMP ESI,0
JE ENDLOOP	
MOV EBX,000C0000H
MOV AX,ROW
SHL EAX,16
MOV AX,COL
DEC AX
IMUL AX,3
ADD EBX,EAX
CALL CURSORMOVEMENT
XOR EBX,EBX
MOV BX,0070H
INVOKE GETSTDHANDLE,-11
INVOKE SETCONSOLETEXTATTRIBUTE,EAX,EBX
invoke GetStdHandle, -11
invoke WriteConsoleA, EAX, EDI, 1, offset x, 0
DEC COL
DEC EDI
DEC ESI
JMP L3
ENDLOOP:
	MOV EBX,000C0000H
	CALL CURSORMOVEMENT
RET
CHECK1 ENDP

CHECK2 PROC
MOV EDI,OFFSET UWORD
XOR ECX,ECX
L00:
MOV AL,[EDI]
CMP AL,'a'
JL ENDN
INC ECX
INC EDI
JMP L00
ENDN:
MOV WSIZE,ECX
MOV EDI,OFFSET UWORD
MOV ESI,OFFSET GRID
MOVZX EAX,POS
DEC EAX
ADD ESI,EAX
MOV EDX,ESI
L1:
	MOV AL,[EDI]
	MOV AH,[ESI]
	CMP AL,AH
	JNE ENDLOOP
	INC ESI
	INC EDI
LOOP L1
CMP ECX,0
JNE ENDLOOP

;
MOV ESI,OFFSET WORDS
MOV ECX,LENGTHOF WORDS
SUB ECX,WSIZE
LOOP1:
	MOV EBX,ESI
	MOV EDI,OFFSET UWORD
	PUSH ECX
	XOR ECX,ECX
	LOOP2:
		MOV AH,[EBX]
		MOV AL,[EDI]
		CMP AL,AH
		JNE OHHH
		INC EBX
		INC EDI
		INC ECX
		JMP LOOP2
	OHHH:
		CMP ECX,WSIZE
		JE FOUND
	INC ESI
	POP ECX
LOOP LOOP1
JMP ENDLOOP
FOUND:
MOV DONE,EBX
POP ECX
MOV EDI,EDX
MOV ESI,WSIZE
L3:
MOV AL,1
MOV SUCCESS,AL
CMP ESI,0
JE ENDLOOP	
MOV EBX,000C0000H
MOV AX,ROW
SHL EAX,16
MOV AX,COL
DEC AX
IMUL AX,3
ADD EBX,EAX
CALL CURSORMOVEMENT
XOR EBX,EBX
MOV BX,0070H
INVOKE GETSTDHANDLE,-11
INVOKE SETCONSOLETEXTATTRIBUTE,EAX,EBX
invoke GetStdHandle, -11
invoke WriteConsoleA, EAX, EDI, 1, offset x, 0
INC COL
INC EDI
DEC ESI
JMP L3
ENDLOOP:
	MOV EBX,000C0000H
	CALL CURSORMOVEMENT
RET
CHECK2 ENDP

CHECK3 PROC
MOV EDI,OFFSET UWORD
XOR ECX,ECX
L00:
MOV AL,[EDI]
CMP AL,97
JL ENDN
INC ECX
INC EDI
JMP L00
ENDN:
MOV WSIZE,ECX
MOV EDI,OFFSET UWORD
MOV ESI,OFFSET GRID
MOVZX EAX,POS
DEC EAX
ADD ESI,EAX
MOV EDX,ESI
L1:
	MOV AL,[EDI]
	MOV AH,[ESI]
	CMP AL,AH
	JNE ENDLOOP
	INC EDI
	ADD ESI,14
LOOP L1
CMP ECX,0
JNE ENDLOOP

;
MOV ESI,OFFSET WORDS
MOV ECX,LENGTHOF WORDS
SUB ECX,WSIZE
LOOP1:
	MOV EBX,ESI
	MOV EDI,OFFSET UWORD
	PUSH ECX
	XOR ECX,ECX
	LOOP2:
		MOV AH,[EBX]
		MOV AL,[EDI]
		CMP AL,AH
		JNE OHHH
		INC EBX
		INC EDI
		INC ECX
		JMP LOOP2
	OHHH:
		CMP ECX,WSIZE
		JE FOUND
	INC ESI
	POP ECX
LOOP LOOP1
JMP ENDLOOP
FOUND:
MOV DONE,EBX
POP ECX
MOV EDI,EDX
MOV ESI,WSIZE
L3:
MOV AL,1
MOV SUCCESS,AL
CMP ESI,0
JE ENDLOOP	
MOV EBX,000C0000H
MOV AX,ROW
SHL EAX,16
MOV AX,COL
DEC AX
IMUL AX,3
ADD EBX,EAX
CALL CURSORMOVEMENT
XOR EBX,EBX
MOV BX,0070H
INVOKE GETSTDHANDLE,-11
INVOKE SETCONSOLETEXTATTRIBUTE,EAX,EBX
invoke GetStdHandle, -11
invoke WriteConsoleA, EAX, EDI, 1, offset x, 0
DEC COL
INC ROW
ADD EDI,14
DEC ESI
JMP L3
ENDLOOP:
RET
CHECK3 ENDP


CHECK4 PROC
MOV EDI,OFFSET UWORD
XOR ECX,ECX
L00:
MOV AL,[EDI]
CMP AL,97
JL ENDN
INC ECX
INC EDI
JMP L00
ENDN:
MOV WSIZE,ECX
MOV EDI,OFFSET UWORD
MOV ESI,OFFSET GRID
MOVZX EAX,POS
DEC EAX
ADD ESI,EAX
MOV EDX,ESI
L1:
	MOV AL,[EDI]
	MOV AH,[ESI]
	CMP AL,AH
	JNE ENDLOOP
	INC EDI
	ADD ESI,16
LOOP L1
CMP ECX,0
JNE ENDLOOP

;
MOV ESI,OFFSET WORDS
MOV ECX,LENGTHOF WORDS
SUB ECX,WSIZE
LOOP1:
	MOV EBX,ESI
	MOV EDI,OFFSET UWORD
	PUSH ECX
	XOR ECX,ECX
	LOOP2:
		MOV AH,[EBX]
		MOV AL,[EDI]
		CMP AL,AH
		JNE OHHH
		INC EBX
		INC EDI
		INC ECX
		JMP LOOP2
	OHHH:
		CMP ECX,WSIZE
		JE FOUND
	INC ESI
	POP ECX
LOOP LOOP1
JMP ENDLOOP
FOUND:
MOV DONE,EBX
POP ECX
MOV EDI,EDX
MOV ESI,WSIZE
L3:
MOV AL,1
MOV SUCCESS,AL
CMP ESI,0
JE ENDLOOP	
MOV EBX,000C0000H
MOV AX,ROW
SHL EAX,16
MOV AX,COL
DEC AX
IMUL AX,3
ADD EBX,EAX
CALL CURSORMOVEMENT
XOR EBX,EBX
MOV BX,0070H
INVOKE GETSTDHANDLE,-11
INVOKE SETCONSOLETEXTATTRIBUTE,EAX,EBX
invoke GetStdHandle, -11
invoke WriteConsoleA, EAX, EDI, 1, offset x, 0
INC COL
INC ROW
ADD EDI,16
DEC ESI
JMP L3
ENDLOOP:
RET
CHECK4 ENDP


CHECK5 PROC
MOV EDI,OFFSET UWORD
XOR ECX,ECX
L00:
MOV AL,[EDI]
CMP AL,97
JL ENDN
INC ECX
INC EDI
JMP L00
ENDN:
MOV WSIZE,ECX
MOV EDI,OFFSET UWORD
MOV ESI,OFFSET GRID
MOVZX EAX,POS
DEC EAX
ADD ESI,EAX
MOV EDX,ESI
L1:
	MOV AL,[EDI]
	MOV AH,[ESI]
	CMP AL,AH
	JNE ENDLOOP
	INC EDI
	ADD ESI,15
LOOP L1
CMP ECX,0
JNE ENDLOOP

;
MOV ESI,OFFSET WORDS
MOV ECX,LENGTHOF WORDS
SUB ECX,WSIZE
LOOP1:
	MOV EBX,ESI
	MOV EDI,OFFSET UWORD
	PUSH ECX
	XOR ECX,ECX
	LOOP2:
		MOV AH,[EBX]
		MOV AL,[EDI]
		CMP AL,AH
		JNE OHHH
		INC EBX
		INC EDI
		INC ECX
		JMP LOOP2
	OHHH:
		CMP ECX,WSIZE
		JE FOUND
	INC ESI
	POP ECX
LOOP LOOP1
JMP ENDLOOP
FOUND:
MOV DONE,EBX
POP ECX
MOV EDI,EDX
MOV ESI,WSIZE
L3:
MOV AL,1
MOV SUCCESS,AL
CMP ESI,0
JE ENDLOOP	
MOV EBX,000C0000H
MOV AX,ROW
SHL EAX,16
MOV AX,COL
DEC AX
IMUL AX,3
ADD EBX,EAX
CALL CURSORMOVEMENT
XOR EBX,EBX
MOV BX,0070H
INVOKE GETSTDHANDLE,-11
INVOKE SETCONSOLETEXTATTRIBUTE,EAX,EBX
invoke GetStdHandle, -11
invoke WriteConsoleA, EAX, EDI, 1, offset x, 0
INC ROW
ADD EDI,15
DEC ESI
JMP L3
ENDLOOP:
RET
CHECK5 ENDP



GENRANDOMCHAR PROC
XOR eax, eax
XOR ebx, ebx
XOR ecx, ecx
XOR edx, edx

mov esi, offset GRID
mov ecx, 224
L1:
mov eax, 26
call generaterandom
add eax, 97
mov [esi][ecx], al
dec ecx
cmp ecx, -1
jne L1
RET
GENRANDOMCHAR ENDP

PRINTGRID PROC 
mov esi, 15
mov ebx, offset GRID
mov edi, 1
L2:
PUSH ESI
MOV ESI,15
L3:
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, ebx, edi, offset x, 0
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET SPACES, LENGTHOF SPACES, offset x, 0
INC EBX
DEC ESI
cmp ESI, 0
jne L3
POP ESI
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset nextline, lengthof nextline, offset X, 0
dec esi
cmp esi, 0
jne L2
RET
PRINTGRID ENDP


GETWORDS PROC USES EAX ESI EDI EDX
invoke CreateFileA, offset path, 1, 0, 0, 3, 128, 0		; eax will have the handle
invoke ReadFile, eax, offset BUFFER, lengthof BUFFER, offset x, 0    
MOV ESI, OFFSET BUFFER
MOV EDI,OFFSET WORDS
MOV ECX,8
L0:
	MOV EAX,315
	CALL generaterandom
	ADD ESI, EAX
	L1:
		MOV DX,0A0DH
		CMP [ESI],DX
		JE GET
		INC ESI
		JMP L1
	GET:
		MOV AL,[ESI]
		MOV [EDI],AL
		INC EDI
		INC ESI
		CMP [ESI],DX
		JNE GET
LOOP L0
MOV DX,0A0DH
MOV [EDI],DX
MOV EBX,00030000H
CALL CURSORMOVEMENT
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET WORDS, LENGTHOF WORDS, offset x, 0
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, OFFSET NEXTLINE, LENGTHOF NEXTLINE, offset x, 0
RET
GETWORDS ENDP

GETSIZE PROC
MOV ESI,OFFSET WORDS
MOV EDI,OFFSET SIZES
MOV ECX,8
L1:
	XOR BL,BL
	ADD ESI,2
LOO:
	MOV AX,0A0DH
	CMP [ESI],AX
	JE EN
	INC BL
	INC ESI
	JMP LOO
EN:
	MOV [EDI],BL
	INC EDI
	LOOP L1
RET
GETSIZE ENDP



HIDEWORDS PROC

MOV ECX,8
L0:
	MOV EAX,5
	CALL generaterandom
	CMP EAX,0
	JNE CON1
	CALL CONDITION0
	JMP L1
	CON1:
		CMP EAX,1
		JNE CON2
		CALL CONDITION1
		JMP L1
		CON2:
			CMP EAX,2
			JNE CON3
			CALL CONDITION2
			JMP L1
			CON3:
				CMP EAX,3
				JNE CON4
				CALL CONDITION3
				JMP L1
				CON4:
					CMP EAX,4
					JNE CON5
					CALL CONDITION4
					JMP L1
					CON5:
						CALL CONDITION5
L1:
	LOOP L0
RET
HIDEWORDS ENDP

CONDITION0 PROC USES ECX
MOV EDI,OFFSET SIZES
MOVZX ESI,WORDNO
ADD EDI,ESI
MOV CL,[EDI]
L2:
MOV EAX,225
CALL generaterandom
MOV COUNTER,0
MOV EBX,EAX
l1:
	CMP RES[EAX],42
	JE L2
	CMP EAX,0
	JL ENDLOOP
	SUB EAX,15
	INC COUNTER
	JMP L1
ENDLOOP:
	CMP CL,COUNTER
	JG L2
	MOV COUNTER,CL
	MOV EAX,OFFSET WORDS
	ADD EAX,2
	MOVZX ESI,DEALT
	ADD EAX,ESI
	L3:
		CMP COUNTER,0
		JE LOOPENDS
		MOV CL,[EAX]
		MOV GRID[EBX],CL
		MOV RES[EBX],42
		INC EAX
		SUB EBX,15
		DEC COUNTER
		JMP L3
LOOPENDS:
	INC WORDNO
	MOV CL,[EDI]
	ADD DEALT,CL
	ADD DEALT,2
RET
CONDITION0 ENDP

CONDITION1 PROC USES ECX
MOV EDI,OFFSET SIZES
MOVZX ESI,WORDNO
ADD EDI,ESI
MOV CL,[EDI]
L2:
MOV EAX,225
CALL generaterandom
MOV COUNTER,0
MOV EBX,EAX
MOV ADDRES,EAX
l1:
	CMP RES[EBX],42
	JE L2
	MOV DL,15
	DIV DL
	CMP AH,0
	JE ENDLOOP
	DEC EBX
	MOV EAX,EBX
	INC COUNTER
	JMP L1
ENDLOOP:
	MOV EBX,ADDRES
	DEC COUNTER
	CMP CL,COUNTER
	JG L2
	MOV COUNTER,CL
	MOV EAX,OFFSET WORDS
	ADD EAX,2
	MOVZX ESI,DEALT
	ADD EAX,ESI
	L3:
		CMP COUNTER,0
		JE LOOPENDS
		MOV CL,[EAX]
		MOV GRID[EBX],CL
		MOV RES[EBX],42
		INC EAX
		DEC EBX
		DEC COUNTER
		JMP L3
LOOPENDS:
	INC WORDNO
	MOV CL,[EDI]
	ADD DEALT,CL
	ADD DEALT,2
RET
CONDITION1 ENDP


CONDITION2 PROC USES ECX
MOV EDI,OFFSET SIZES
MOVZX ESI,WORDNO
ADD EDI,ESI
MOV CL,[EDI]
L2:
MOV EAX,225
CALL generaterandom
MOV COUNTER,0
MOV EBX,EAX
MOV ADDRES,EAX
l1:
	CMP RES[EBX],42
	JE L2
	MOV DL,15
	DIV DL
	CMP AH,0
	JE ENDLOOP
	INC EBX
	MOV EAX,EBX
	INC COUNTER
	JMP L1
ENDLOOP:
	MOV EBX,ADDRES
	CMP CL,COUNTER
	JG L2
	MOV COUNTER,CL
	MOV EAX,OFFSET WORDS
	ADD EAX,2
	MOVZX ESI,DEALT
	ADD EAX,ESI
		L3:
		CMP COUNTER,0
		JE LOOPENDS
		MOV CL,[EAX]
		MOV GRID[EBX],CL
		MOV RES[EBX],42
		INC EAX
		INC EBX
		DEC COUNTER
		JMP L3
LOOPENDS:
	INC WORDNO
	MOV CL,[EDI]
	ADD DEALT,CL
	ADD DEALT,2
RET
CONDITION2 ENDP

CONDITION3 PROC USES ECX
MOV EDI,OFFSET SIZES
MOVZX ESI,WORDNO
ADD EDI,ESI
MOV CL,[EDI]
L2:
MOV EAX,225
CALL generaterandom
MOV COUNTER,0
MOV EBX,EAX
MOV ADDRES,EAX
l1:
	CMP RES[EBX],42
	JE L2
	MOV DL,15
	DIV DL
	CMP AH,0
	JE ENDLOOP
	CMP EBX,225
	JG ENDLOOP
	ADD EBX,14
	MOV EAX,EBX
	INC COUNTER
	JMP L1
ENDLOOP:
	MOV EBX,ADDRES
	DEC COUNTER
	CMP CL,COUNTER
	JG L2
	MOV COUNTER,CL
	MOV EAX,OFFSET WORDS
	ADD EAX,2
	MOVZX ESI,DEALT
	ADD EAX,ESI
	L3:
		CMP COUNTER,0
		JE LOOPENDS
		MOV CL,[EAX]
		MOV GRID[EBX],CL
		MOV RES[EBX],42
		INC EAX
		ADD EBX,14
		DEC COUNTER
		JMP L3
LOOPENDS:
	INC WORDNO
	MOV CL,[EDI]
	ADD DEALT,CL
	ADD DEALT,2
RET
CONDITION3 ENDP

CONDITION4 PROC USES ECX
MOV EDI,OFFSET SIZES
MOVZX ESI,WORDNO
ADD EDI,ESI
MOV CL,[EDI]
L2:
MOV EAX,225
CALL generaterandom
MOV COUNTER,0
MOV EBX,EAX
MOV ADDRES,EAX
l1:
	CMP RES[EBX],42
	JE L2
	MOV DL,15
	DIV DL
	CMP AH,0
	JE ENDLOOP
	CMP EBX,225
	JG ENDLOOP
	ADD EBX,16
	MOV EAX,EBX
	INC COUNTER
	JMP L1
ENDLOOP:
	MOV EBX,ADDRES
	CMP CL,COUNTER
	JG L2
	MOV COUNTER,CL
	MOV EAX,OFFSET WORDS
	ADD EAX,2
	MOVZX ESI,DEALT
	ADD EAX,ESI
	L3:
		CMP COUNTER,0
		JE LOOPENDS
		MOV CL,[EAX]
		MOV GRID[EBX],CL
		MOV RES[EBX],42
		INC EAX
		ADD EBX,16
		DEC COUNTER
		JMP L3
LOOPENDS:
	INC WORDNO
	MOV CL,[EDI]
	ADD DEALT,CL
	ADD DEALT,2
RET
CONDITION4 ENDP

CONDITION5 PROC USES ECX
MOV EDI,OFFSET SIZES
MOVZX ESI,WORDNO
ADD EDI,ESI
MOV CL,[EDI]
L2:
MOV EAX,225
CALL generaterandom
MOV COUNTER,0
MOV EBX,EAX
l1:
	CMP RES[EAX],42
	JE L2
	CMP EAX,225
	JG ENDLOOP
	ADD EAX,15
	INC COUNTER
	JMP L1
ENDLOOP:
	DEC COUNTER
	CMP CL,COUNTER
	JG L2
	MOV COUNTER,CL
	MOV EAX,OFFSET WORDS
	ADD EAX,2
	MOVZX ESI,DEALT
	ADD EAX,ESI
	L3:
		CMP COUNTER,0
		JE LOOPENDS
		MOV CL,[EAX]
		MOV GRID[EBX],CL
		MOV RES[EBX],42
		INC EAX
		ADD EBX,15
		DEC COUNTER
		JMP L3
LOOPENDS:
	INC WORDNO
	MOV CL,[EDI]
	ADD DEALT,CL
	ADD DEALT,2
RET
CONDITION5 ENDP

;TAKES EBX AS INPUT
CURSORMOVEMENT PROC
INVOKE GETSTDHANDLE,-11
INVOKE SETCONSOLECURSORPOSITION,EAX,EBX
RET
CURSORMOVEMENT ENDP


main proc
INVOKE GETTICKCOUNT
MOV STIME,EAX
ADD SEED,EAX
CALL MAINSCREEN
CALL GETWORDS
CALL GENRANDOMCHAR
CALL GETSIZE
CALL HIDEWORDS
CALL PRINTGRID
CALL SHOWSCORE
STARTGAME:
INVOKE GETTICKCOUNT 
SUB EAX,STIME
MOV ETIME,EAX
CMP ETIME,600000
JGE GAMEOVER
CALL GETINPUT
JMP STARTGAME
GAMEOVER:
INVOKE ExitProcess,EAX
main endp
end main