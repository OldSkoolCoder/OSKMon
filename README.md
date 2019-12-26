# OSKMon

## OldSkoolCoder Machine Code Monitor

This repository shopws how a common set of code can be made to be used on two different systems, C64 and VIC 20

this code is a machine code monitor for both systems and allows the user to create machine code programs directly onto the computer.

Enjoy

### List of Command avaliable in OSKMon

The parameters in the command formats are represented as follows :-
*(addr)     A two byte hex address, e.g. 0400
*(dev)		A single byte dex device number, e.g. 08 (DISC)
*(opcode)	A valid 6510 assembly mnemonic, e.g. LDA
*(operand)	A valid operand for the proceeding instruction, e.g. #$01
*(value)	A single byte hex value, e.g. FF
*(data)     A String of literal data enclosed in quotes of hex values. Successive items are separated with commas.
*(ref)		A two byte hex address, e.g. 2000
*(offset)	A two byte offset value, e.g. 3000

#### A – ASSEMBLE
Format :	`A (addr) (opcode) (operand)`
Purpose :	
>To assemble code starting from a specific address.
>The command allows you to input assembly code line by line, and have it stored as machine code. When the command is entered, the appropriate code is written in memory beginning at the specified address.
>The address of the available memory location beyond that required by the specific op-code and operand is then prompted awaiting input of additional code. To terminate the A command, simply press <RETURN> when the new address is prompted. If you input an illegal op-code or operand, DALEMON will place a question mark after the illegal quantity and will return you to the monitor with the prompt ‘>’ and a new line.
>If you fail to specify either the op-code or operand, DALEMON will ignore the line and return you to the monitor with a ‘>’ on a new line.
**N.B.** All operands must be given as hex numbers proceeded by a dollar sign ($). I.e. typed as $nn or $nnnn

Example :	
To Enter the following machine code :-
`   LDA #$19`
`   JSR $FFD2`
`	RTS`
Beginning at address $C000
Type : 	A C000 LDA#$19 <RETURN>
Display :	>, C000 LDA #$19
		    >A C002
Type :	JSR $FFD2 <RETURN>
Display :	>, C000 LDA #$19
		    >, C002 JSR FFD2
		    >A C005
Type :	RTS <RETURN>
Display :	>, C000 LDA #$19
		    >, C002 JSR FFD2
		    >, C005 RTS
		    >, C006
Result : The machine code equivalent of the specified assembly language is stored in the memory from location $C000 to $C005 inclusive.
 
#### C – COMMAND
Format :	`C (opcode)`
Purpose :	
>To show you all the addressing modes of that command.
>This command allows you to see what addressing modes are available.

Example :	
To show all the addressing modes for CMP.
Type :	C CMP <RETURN>
Display :	
CMP$DCBA		ABSOLUTE
CMP$DCBA,X		ABSOLUTE,X
CMP$DCBA,Y		ABSOLUTE,Y
CMP#$BA		    IMMEDIATE
CMP($BA,X)		(INDIRECT,X)
CMP($BA),Y		(INDIRECT),Y
CMP$BA		    ZERO-PAGE
CMP$BA,X		ZERO-PAGE,X
Result : There are eight possible addressing modes for op-code CMP.

#### D – DISSASSEMBLE
Format :	`D (addr) (addr)`
Purpose :	
>To disassemble code between a range of addresses
>The D command enables you to convert the code that is stored in the computer’s memory back into assembly language notations. You may specify a range of addresses to be disassembled. The lines specified will be displayed on the screen one at a time and the screen will scroll.
>The <STOP> key will terminate the scrolling and you will remain in the disassemble mode. While you are in Disassemble mode, a line of code on the screen can be modified by a simply correcting or retyping the line and pressing <RETURN>.
>The A Command is automatically activated. When you have made the change, you remain in the A mode with the cursor positioned after the address on the line following the correct line. To terminate the assembly mode, clear the screen and press <RETURN>.

Example :	
To disassemble the lines of code input in the example of the assemble command, and then to change the address in the second line to $FFDO
Type :	D C000 C005 <RETURN>
Display :	>, C000 LDA #$19
		>, C002 JSR $FFD2
		>, C005 RTS
Action :	Move the cursor so that it is positioned over the 2 in $FFD2
Type :	0 <RETURN>
Display :	>, C000 LDA #$19
		>, C002 JSR $FFD0
		>A C005 RTS
Result :	The code from location C000 to C005 is disassembled. The change is made and then stored with the <RETURN> key. You are left in the assemble mode.

F – FILL
Format :	F (addr) (addr) (value)
Purpose :	To Fill memory between two specified addresses with a given value.
The F command enabled you to put a known value into a specified block of memory. This is useful for initialising data structure for the blanking out the contents of any RAM area.
Simply specify the range of the block of memory and the pattern you wish to write in that block. Naturally you should not specify addresses from $0000 to $01FF (Page Zero and one) or $9000 to $A000 (where DALEMON is stored)
Example : 	To write $EA (a no-op instruction) from location $2000 to $3000 inclusive.
Type:		F 2000 3000 EA <RETURN>
Result :	The no-op instruction ($EA) is written in all the addresses from $2000 to $3000.
G – GO
Format :	G or G (addr)
Purpose :	To execute a program beginning at the location currently in the program counter or beginning from a specified address.
The G command may be used alone or stated with an address. When G is used alone, the C64’s 6510 cpu will execute the program in memory beginning with the location currently in the program counter. (To display the contents of the program counter, use the R command as described later in this manual).
Example :	assume that you have a program in memory and wish to begin execution from location $2000
Type :	G 2000 <RETURN>
Result :	The register will be restored. The PC will be set to $2000. The program will begin executing at $2000
 
H – HUNT
Format :	H (addr) (addr) (data) [up to 11 pieces of data or 25 characters]
Purpose :	To search through a specified block of memory and locate all occurrences of particular data or character strings.
The H command easily locates and specified character pattern that’s in the computer’s memory and displays it on the screen. You use this command to locate data, which is specified in hex, or to find text strings up to 25 characters long (1/2 a line).
All locations within the specified range which contain the requested characters will be found. If there are more occurrences than will fit on the screen, the screen will scroll. The <CONTROL> key will slow the rate of scrolling. When all occurrences within the range have been located, you will be returned to DALEMON.
Example 1 : Assume that the data string A92F3C is stored in memory somewhere between locations $C000 and location $C0FF. To locate the string.
Type :	H C000 C0FF A9 2F 3C <RETURN>
Result :	Memory is searched between $C000 and $C0FF and the locations where A92F3C is stored, are displayed.
Example 2 : Assume that the data string ‘PRESS PLAY ON’ is stored in memory somewhere between locations $E000 and location $FFFF. To locate the string.
Type :	H C000 C0FF ‘PRESS PLAY ON <RETURN>
Result :	Memory is searched between $E000 and $FFFF and the locations where ‘PRESS PLAY ON’ is stored, are displayed.
I – INTERPRET
Format :	I (addr) (addr)
Purpose :	To locate and display printable txt characters within a specified block of memory.
The I Command will display any of the 96 printable CBM ASCII code equivalents occurring within the specified block of memory. All other characters in the block will be indicated by a dot ‘.’.
If the specified block fills the screen, the screen will scroll. The <STOP> key will terminate the scrolling and the <CONTROL> key will slow the rate of scrolling.
Example :	To show the characters in memory from $A09E to $A19E
Type :	I A09E A19E <RETURN>
 
L – LOAD
Format :	L “FILENAME” (dev)
Purpose :	To load a program file into memory from a specified device.
The L Command enables you to read a load file or a program file which is stored on a cassette or disc and write it into the C64’s RAM. For disc files, the address of the first location in RAM into which the load file will be read must be the first two bytes of a file. Tape files have the start address as part of the header block.
Example :	Assume you have a disc program file names TEST which is 258 bytes long, the first two bytes of which are 00CA. To read this file into memory.
Type :	L “TEST” 08 <RETURN>
Result :	The program named TEST which is on the diskette in the disc unite is loaded into memory from CA00 to CB00 inclusive.
M – MEMORY
Format :	M (addr) (addr)
Purpose :	To display the hec code which is stored in a given block of memory.
The M command will display the contents of memory from the start address in the command up to and including the contents of the end address. The display will have the address and ten hex bytes on a line.
If only one address is given in the command, ten bytes will be displayed beginning with the contents of the specified address.
The contents of the memory may be changed by typing over the displayed values and then pressing the <RETURN> key.
Example :	display the ten bytes of memory beginning at location $c000 and to change the $00 to $FF
Type :	M C000 C005 <RETURN>
Display :	>: C000 A0 00 EA EA EA EA EA EA EA EA
Action : 	Position the cursor over the first 0 or 00. Type FF and press <RETURN>
Result :	the ten bytes of the memory beginning at location $C000 should now read :- A0 FF EA EA EA EA EA EA EA EA
O – OUTPUT
Format :	O (Y or N)
Purpose :	To set the printer up for printing if ‘Y’. or to stop printer printing by answering ‘N’.
Type : 	OY or ON <RETURN>
 
R – REGISTER
Format :	R
Purpose :	To display the contents of the registers.
The R command enables you to view the current status of the following registers in the C64’s 6520 CPU.
Program Counter = 	PC		IRQ Jump Vectors = 	IRQ	
NMI Jump Vectors = 	NMI 		Status Register = 	SR
Accumulator = 		AC		Index Register X = 	XR
Index Register Y = 	YR		Stack Pointer = 		SP
This can be useful when you are debugging a program because the R enables you to see if the registers contain the values you are expecting. You may also change the values in the register whilst in the R mode by simply typing over a value and pressing <RETURN>.
The register display is automatically generated when DALEMON is started up or when a BRK is reached in G mode.
Example :	To display the contents of the registers
Type :	R
Display :	>R
		>B*
		   PC   IRQ NMI  SR AC XR YR SP
		>;DC84 EA31 FE72 B1 0C 00 93 F6
S – SAVE
Format :	S “FILENAME” (dev) (addr) (addr)
Purpose :	To write the contents of a specified RAM area to a particular device.
The S command enables you to save a program on diskette or cassette, so that it can be used at a later time. The command consisted of the name of the file, the number of the device to be written too and the start and end address of the RAM block.
The filename must be enclosed in quotation marks and must obey the syntax rules of the C64 files, i.e. it must begin with an alphabetical character and be more than 16 characters long. The device number of the cassette unit is 01 and of the disc unit, 08. The final address must be one larger than the location of the last byte you wish to write.
WARNING
If the final address is not one larger than the location of the last byte you wish to save, the last byte will be lost.
If the specified device is not present you will get an error message and be returned to BASIC.
Example :	Assume that you have a program in memory from location $C000 to $C0FF. To write that program to the diskette in the disc drive, naming that program TEST1.
Type :	S “TEST1” 08 C000 C100 <RETURN>
Result :	A file names TEST1 will be written on the diskette. It will contain the code which is in RAM locations $C000 to $C0FF inclusive.
T – TRANSFER
Format :	T (addr) (addr) (addr)
Purpose :	To transfer the contents of a block of memory from one area of RAM to another.
The T command enables you to relocate your program or data to another part of memory. This can be useful if you which to expand a program or to use part of a program elsewhere without re-typing.
The command consists of three addresses. The first two indicate the block of memory to be duplicated. The third address indicates the starting address for the copy.
Example :	Assume that you have a block of data in memory from location $3000 to $3500. Toe move that data to a new location beginning at $4000.
Type :	T 3000 3500 4000 <RETURN>
Result :	the data in block $3000 to $3500, is now copied to $4000 to $4500
X – EXIT
Format : 	X
Purpose :	The terminate DALEMON and return control back to BASIC.
The use of X command returns you back to BASIC. Your program will remain in memory.
Example :	To exit DALEMON
Type :	X <RETURN>
Result :	You will return to BASIC and any BASIC program you had in memory will be retained, you will be prompted by READY.
# - DECIMAL to HEXADECIMAL CONVERTOR
Format :	# (No.)	(Range 0 – 65535)
Purpose :	This is to help you convert DECIMAL into HEX and BINARY.
Example :	To convert 245 to HEX and BINARY
Type :	# 245 <RETURN>
Display :	># 245
		>$=00F5
		>%=00000000 11110101
 
$ - HEXADECIMAL TO DECIMAL CONVERTOR
Format :	$ (addr)	(Range 0000 – FFFF)
Purpose :	This is to help you convert HEXADECIMAL into DECIMAL and BINARY.
Example :	To convert $01FE to DECIMAL and BINARY
Type :	$01FE <RETURN>
Display :	>$01FE
		>#=500
		>%=00000001 11111110
% - BINARY to DECIMAL CONVERTOR
Format :	% (16 Bit No.)	(two sets of eight)
Purpose :	This is to help you convert BINARY into DECIMAL and HEX.
Example :	To convert 11111111 11111111 to DECIMAL and HEX
Type :	%11111111 11111111 <RETURN>
Display :	>%11111111 11111111
		>$=FFFF
		>#=65535
