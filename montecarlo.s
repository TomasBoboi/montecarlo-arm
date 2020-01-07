.global _start
.extern write_str
.extern write_word

.data
.balign 4
startup_s:	.asciz 	"\r\n-----------  MONTE CARLO  -----------\r\n\r\n"
end_s:		.asciz	"------------------------------\r\n\r\n--------  PROGRAM TERMINATED --------\r\n\r\n"
top_s:		.asciz	" ---------------------------- \r\n|    VALUE    |  ITERATIONS  |\r\n ---------------------------- \r\n\r"
l:			.asciz	"  "
new_line:	.asciz 	"\r\n"

iterations:		.word	10

a:				.word	33569	// prime
c:				.word	12345
// a and c are co-primes; a - 1 is divisible by all prime factors of m
// a - 1 is divisible by 4 if m is divisible by 4
// Hull–Dobell Theorem => period = m, for all seeds

xn:				.word	13		// seed, initially / current element, X(n)

.text
_start:
	LDR 	SP, =stack_top	// initialize Stack Pointer
	
	LDR 	R0, =startup_s	// print some startup stuff
	BL 		write_str
	LDR		R0, =top_s
	BL		write_str

	MOV 	R2, #1			// initialize main counter

	main_loop:
		CMP		R2, #9				// we'll go up to 10^9 iterations
		BGT		end_main

		PUSH	{R2}

		LDR		R0, =l			// we'll print some spaces at the beginning of each line
		BL		write_str
		
		LDR 	R0, =iterations	// load the number of iterations from memory
		LDR 	R0, [R0]
		PUSH	{R0}			// push parameter to stack
		BL 		montecarlo		// call the montecarlo function

		POP		{R0}			// get the number of points inside the circle for a given number of iterations
		LSL		R0, R0, #2		// multiply it by 4 to get the approximation for pi
		BL		write_word		// print it

		LDR		R0, =iterations	// print the number of iterations
		LDR		R0, [R0]
		BL		write_word
		LDR		R0, =new_line
		BL		write_str

		LDR		R0, =iterations	// update the number of iterations, multiplying it by 10
		LDR		R0, [R0]
		MOV 	R1, #10
		MOV		R2, R0
		MUL		R0, R2, R1
		LDR 	R1, =iterations
		STR		R0, [R1]		// store the updated number of iterations in memory
		LDR		R0, =xn			// reset the seed to 13 (not really necessary)
		MOV		R1, #13
		STR		R1, [R0]

		POP		{R2}			// get the main counter and increment it
		ADD		R2, R2, #1

		BL		main_loop
	
	end_main:
		LDR		R0, =end_s		// print a string at the end of the program
		BL		write_str

		B		.

rng:
	PUSH	{LR}

	LDR		R0, =xn		// load current element, X(n) from memory
	LDR		R0, [R0]
	LDR		R1, =a		// load a from memory
	LDR		R1, [R1]
	LDR		R2, =c		// load c from memory
	LDR		R2, [R2]

	MOV		R3, R0
	MUL		R0, R3, R1	// x(n+1) = (x(n) * a + c) mod 2^16
	ADD		R0, R2

	MOV		R2, #255	// modulus operation: we keep only the ls-16 bits of x(n+1)
	LSL		R2, R2, #8
	ADD		R2, R2, #255
	AND		R0, R0, R2	// R2 will be 0x0000FFFF

	LDR		R1, =xn		// store the next element in memory
	STR		R0, [R1]
	
	POP		{LR}
	PUSH	{R0}		// send return value to stack
	BX		LR

montecarlo:
	POP 	{R0}	// get the number of elements to be generated
	PUSH 	{LR}

	MOV		R1, R0	// R1 will be the number of elements to be generated
	MOV 	R2, #1	// R2 will be the counter
	
	MOV		R6, #0	// R6 will count the points within the circle
	
	loop:
		CMP		R2, R1		// if counter > iterations then terminate loop
		BGT		end_loop

		PUSH	{R1, R2}	// push iteration number and counter to stack

		BL		rng			// generate a random number
		POP		{R3}		// get the random number from stack

		BL		rng			// generate a random number
		POP		{R4}		// get the random number from stack

		EOR		R5, R5, R5	// we set R5 to 0x00000000
		MVN		R5, R5		// then we invert all bits to get 0xFFFFFFFF
		LSR		R5, R5, #17	// the radius of the circle is 0x00007FFF = 32767

		// circle of radius 32767, centered around 0, inside a square of side 65535
		// mapping: we generate numbers from 0 to 65535
		// we need to map them to -32767 -> +32767
		// to do that, we just substract 32767 from each number

		SUB		R3, R3, R5
		SUB		R4, R4, R5

		MOV		R7, R5
		MUL		R5, R7, R5	// we square the radius

		MOV		R7, R3
		MUL 	R3, R7, R3	// R3 becomes X^2
		MOV		R7, R4
		MUL		R4, R7, R4	// R4 becomes Y^2
		ADD		R3, R4		// R3 becomes X^2 + Y^2
		
		CMP		R3, R5		// if X^2 + Y^2 is less than the square of the radius, we are inside the circle, and we increment the counter
		BHI		no_incr
		ADD		R6, R6, #1

		no_incr:
			POP		{R1, R2}	// pop iteration number and counter from stack
			ADD		R2, R2, #1	// increment counter

			B		loop
	
	end_loop:
		POP 	{LR}
		PUSH	{R6}		// send the number of points inside the circle to the main loop
		BX 		LR

