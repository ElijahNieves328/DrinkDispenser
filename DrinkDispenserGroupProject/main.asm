;
; DrinkDispenserGroupProject.asm
;
; Created: 12/7/2021 3:35:16 PM
; Author : Elijah Nieves, Robert McNiven
;

main:
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16



end_main:
	rjmp end_main
