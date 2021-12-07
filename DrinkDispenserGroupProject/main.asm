;
; DrinkDispenserGroupProject.asm
;
; Created: 12/7/2021 3:35:16 PM
; Author : Elijah Nieves, Robert McNiven, Michael D'Agostino
;

.equ Right_LED = PB1
.equ Left_LED = PD6
.equ Servo = PD4
.equ Right_Button = PD3
.equ Left_Button = PD2
.equ Water_Level_Sensor = PC3

main:
	;initialize stack
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16

	sbi	DDRB, DDB4		; sets Right LED pin in the direction register B for output
	sbi	DDRD, DDD6		; sets Left LED pin in the direction register D for output

	sbi DDRD, DDD4		; sets Servo pin in the direction register D for output

	cbi DDRD, DDD3		; clears the Right button pin in the direction register D for input
	cbi DDRD, DDD2		; clears the Left button pin in the direction register D for input

	cbi DDRC, DDC3		; clears the Water Sensor pin in the direction register C for input

	sbi PORTD, Right_Button		; set Right button output pin in PORTD so that Right Button is set for pull up
	sbi PORTD, Left_Button		; set Left button output pin in PORTD so that Left Button is set for pull up

	sbi PORTC, Water_Level_Sensor		; set Water Sensor output pin in PORTD so that Water Sensor is set for pull up


end_main:
	rjmp end_main
