;
; DrinkDispenserGroupProject.asm
;
; Created: 12/7/2021 3:35:16 PM
; Author : Elijah Nieves, Robert McNiven, Michael D'Agostino
;
; This program is made to function as a drink dispenser. When the right button is pressed, it will dispense liquid (this is simulated by turning a servo)
; However, there is a water sensor to detect how much liquid is left. If there is not a sufficient amount of liquid, the program will stop dispensing and turn on an LED which signals the lack of liquid. 
; If the drink dispensing button is pressed again while there is not sufficient liquid, it will blink the LED to tell the user there is not sufficient liquid.
;
; Additionally, the left button is used to simulate dispensing ice. When the button is pressed, it will spin the servo for 3 seconds. This is to represent the machine dispensing a couple of ice cubes. 

; TODO: 
	; Make sure the algorithm is correct by running it on the Arduino set up
	; Make sure the program uses the water sensor input properly
	; Implement the ice cube routine (maybe as an interrupt?)


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

	sbi PORTD, Right_Button			; set Right button output pin in PORTD so that Right Button is set for pull up
	sbi PORTD, Left_Button			; set Left button output pin in PORTD so that Left Button is set for pull up

	sbi PORTC, Water_Level_Sensor	; set Water Sensor output pin in PORTD so that Water Sensor is set for pull up

	; make sure the LEDs are off
	cbi PORTB, Right_LED		
	cbi PORTD, Left_LED

Wait:
	sbis PIND, Right_Button			; unless there is input (in pull-up, input = 1), skip the right input routine
	call RightInput					; call the routuine for the right button being pressed
	cbi PORTD, Servo				; turn off the Servo if it is on
	rjmp Wait

RightInput:
	sbic PINC, Water_Level_Sensor   ; if the sensor is not sending input (it is dry)
	rjmp BlinkRightLEDTwice			; blink the LED instead of dispensing, which then returns to the main routine
	sbi PORTD, Servo				; else, turn on the servo
DispenseDrink:
	sbis PIND, Right_Button			; if the Right button is not being pressed
	ret								; return the the main routine where it turns off the Servo
	
	sbic PINC, Water_Level_Sensor   ; if the sensor is not sending input (it is dry)
	rjmp OutofLiquid				; stop dispensing liquid and run the out of liquid routine

	rjmp DispenseDrink				; else, keep dispensing drink

OutofLiquid:
	cbi PORTD, Servo				; turn off the servo
	sbi PORTB, Right_LED			; turn on the Right LED to signal that there is no more Right Drink.
	ret								; return to main routine


BlinkRightLEDTwice:
	ldi r21, 2						; this is how many times we have blinked

	sbi PORTB, Right_LED			; turn on the Right LED
	call T1Normal_1sec				; delay 1 second
	cbi PORTB, Right_LED			; turns off the Right LED

	dec r21
	brne OutOfLiquid				; when r21 == 2, we have blinked twice and will exit.
	rjmp blink						; loop of one second blinking


T1Normal_1sec:
; use this for the ice cubes! when ice cube button is pressed, turn the servo on, call the timer (call 3 times if the timer is 1 second), then turn the servo off.
; 1,000,000 microsecond delay. (1 second)
; Prescaler = 1024
; Load TCNT1H:TCNT1L with initial count
; TCNT1 = 49911 = $C2:$F7
	ldi r20, $C2
	sts TCNT1H, r20
	ldi r20, $F7
	sts TCNT1L, r20

; Load TCCR1A & TCCR1B
	clr r20
	sts TCCR1A, r20
	ldi r20, $05	
	sts TCCR1B, r20		; Normal mode – clears all WGM, sets CS12 and CS10 (prescaler 1024)

T1Normal_Wait:
; Monitor TOV1 in TIFR1
	sbis TIFR1, TOV1	; check to see if overflow flag is set(0?). if it is...
	rjmp T1Normal_Wait

	clr r20
	sts TCCR1B, r20		; stop the timer by clearing it

	sbi TIFR1, TOV1		; Clear TOV0 flag by writing a 1 to TOV0 bit in TIFR0

	ret

