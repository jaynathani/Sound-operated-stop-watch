;-----------------------------------------------------------------------------
; Assembly main line
;inititalize index page
;-----------------------------------------------------------------------------

include "m8c.inc"       ; part specific constants and macros
include "memory.inc"    ; Constants & macros for SMM/LMM and Compiler
include "PSoCAPI.inc"   ; PSoC API definitions for all User Modules
include "program_defines.inc"

export _main
;export addr_internal_inc_ms
export addr_pin_inc_ms
export addr_adc_inc_ms
export addr_timer_inc_ms
export addr_inc_ms
export addr_inc_s
export addr_inc_m
export addr_inc_h

export addr_timer_flag

export read_addr_inc_ms
export read_addr_inc_s
export read_addr_inc_m
export read_addr_inc_h

export addr_lng_p
export addr_shrt_p

export addr_acc_mode

export md_flg

export count_saved
export read_saved
export save_time_index

export iResult1  
export iResult_count
export iResult_Total
export dOpr2
export dOpr1
export dRes
export threshold_value
 
export sound_timer_running

export debug_register
export run_button_press_clock



area var(RAM)                     
;addr_internal_inc_ms: 	blk 1
addr_timer_inc_ms:		blk 1
addr_pin_inc_ms:		blk 1
addr_adc_inc_ms:		blk 1
addr_inc_ms: 			blk 1
addr_inc_s: 			blk 1
addr_inc_m: 			blk 1
addr_inc_h: 			blk 1
addr_timer_flag:		blk 1

read_addr_inc_ms: 		blk 1
read_addr_inc_s: 		blk 1
read_addr_inc_m: 		blk 1
read_addr_inc_h: 		blk 1

addr_lng_p: 			blk 1
addr_shrt_p: 			blk 1

addr_acc_mode: 			blk 1

md_flg: 				blk 1

count_saved:			blk 1
read_saved: 			blk 1
save_time_index:		blk 1

iResult_Total:			blk	4
iResult1:       		blk 4  ; ADC1 result storage
iResult_count:			blk 4
dOpr2:					blk	4
dOpr1:					blk	4
dRes:					blk 4

threshold_value:		blk 2
incoming_value:			blk 2
sound_timer_running:	blk 1

debug_register:			blk 1
run_button_press_clock:  blk 1


area text(ROM,REL)
;export time_counter
_main:

 	lcall LCD_Start


Initialize_Interrupt:
	M8C_EnableIntMask INT_MSK1, INT_MSK1_DBB01		;enable digital block one interrupt
	M8C_EnableIntMask INT_MSK0, INT_MSK0_GPIO 		;enable GPIO Interrupt Mask
	M8C_EnableGInt									;enable global interrupts

Initialize_Variables:								;initialize all values
	mov [addr_internal_inc_ms],00h					;particularly ones that are read from as to not have unknown values
	mov [addr_pin_inc_ms], 00h
	mov [addr_adc_inc_ms], 00h
	mov [addr_timer_inc_ms],00h
	mov [addr_inc_ms],00h
	mov [addr_inc_s],00h
	mov [addr_inc_m],00h
	mov [addr_inc_h],00h
	mov [md_flg],01h
	mov [debug_register], 00h
	mov [save_time_index], 00h
	mov [flag_val], 00h
	mov [threshold_value+1], 70h						;set default
	mov [count_saved], 00h
	mov [pg6_reference], 00h
	mov [max_ms], 00h
	mov [max_sec], 00h
	mov [max_min], 00h
	mov [max_hr], 00h
	mov [min_ms], 00h
	mov [min_sec], 00h
	mov [min_min], 00h
	mov [min_hr], 00h

Set_Up_Anolog:
	mov   A, PGA_1_HIGHPOWER						;enable PGA 1 in high power mode
    lcall PGA_1_Start			
	
	mov   A, PGA_2_HIGHPOWER  						;enable PGA 2 in high power mode
    lcall PGA_2_Start
	
    mov   A, LPF2_1_HIGHPOWER						;enable LPF2 in high power mode
    lcall LPF2_1_Start
	
    mov   A, 7                    					;Set resolution to 7 Bits
    lcall  DUALADC_1_SetResolution

    mov   A, DUALADC_1_HIGHPOWER    				;enable DualADC in high power mode
    lcall  DUALADC_1_Start

    mov   A, 00h                  					;Start A/D in continuous sampling mode
    lcall  DUALADC_1_GetSamples
	
	
	lcall Timer16_1_Start							;enable Timer to start running at .01ms
	
	mov reg[MVW_PP], 06h								;set mvi writing on memory page 6
	mov reg[MVR_PP], 06h								;set mvi reading from memory page 6
	
Initialize_Values_On_MVI_Page:
	mov reg[CUR_PP], 06h							;set current page to mvi referenced page
	
	mov [00h], 00h
	mov [01h], 00h
	mov [02h], 00h
	mov [03h], 00h
	
	mov [04h], 00h
	mov [05h], 00h
	mov [06h], 00h
	mov [07h], 00h

	mov [08h], 00h
	mov [09h], 00h
	mov [0Ah], 00h
	mov [0Bh], 00h
	
	mov [0Ch], 00h
	mov [0Dh], 00h
	mov [0Eh], 00h
	mov [0Fh], 00h
	
	mov [10h], 00h
	mov [11h], 00h
	mov [12h], 00h
	mov [13h], 00h
	
	mov [14h], 00h
	mov [15h], 00h
	mov [16h], 00h
	mov [17h], 00h
	
	mov [18h], 00h
	mov [19h], 00h
	mov [1Ah], 00h
	mov [1Bh], 00h
	
	mov [1Ch], 00h
	mov [1Dh], 00h
	mov [1Eh], 00h
	mov [1Fh], 00h
	
	mov [20h], 00h
	mov [21h], 00h
	mov [22h], 00h
	mov [23h], 00h
	
	mov [24h], 00h
	mov [25h], 00h
	mov [26h], 00h
	mov [27h], 00h
	
	mov reg[CUR_PP], 00h							;set current page back to 1 - was this the current page from before

loop:

	mov A, 00h
	mov X, 0Eh
	lcall LCD_Position
	mov A, [addr_shrt_p]
	lcall LCD_PrHexByte
	
;	mov A, 01h
;	mov X, 02h
;	lcall LCD_Position
;	mov A, [md_flg]
;	lcall LCD_PrHexByte
;;	
;
;;
;	mov A, 01h
;	mov X, 04h
;	lcall LCD_Position
;	mov A, [addr_pin_inc_ms]
;	lcall LCD_PrHexByte
;;	
;	mov A, 01h
;	mov X, 06h
;	lcall LCD_Position
;	mov A, [addr_adc_inc_ms]
;	lcall LCD_PrHexByte
;
;
;;	
;	mov A, 01h
;	mov X, 08h
;	lcall LCD_Position
;	mov A, [addr_timer_inc_ms]
;	lcall LCD_PrHexByte
;	
;	mov A, 01h
;	mov X, 0Ah
;	lcall LCD_Position
;	mov A, [debug_register]
;	lcall LCD_PrHexByte
;	
;	mov A, 01h
;	mov X, 0Eh
;	lcall LCD_Position
;	mov A, [threshold_value+1]
;	lcall LCD_PrHexByte
Chcklngp:
    cmp [addr_lng_p],01h 						;check if a long press was received 
	jnz StaySameMode							;if not stay in the same mode
	
	mov [addr_lng_p],00h  						;reset long press value
	mov [addr_shrt_p],00h  						;reset short press value
	


next_Mode:
    and F, FBh									;clear CF
	asl [md_flg]								;moving to next mode is a shift is current mode
	

	cmp [md_flg],20h							;check if too many shifts occured - goes into unknown mode
	jnz StaySameMode							;no than okay to perform jump to ode
	mov [md_flg],01h							;set back to first mode

StaySameMode:									;jump to corresponding mode
	cmp [md_flg],01h
	jz Accuracy_m          
	cmp [md_flg],02h
	jz Threshold_m
	cmp [md_flg],04h
	jz Button_m
;	mov [pg6_reference], 00h
	cmp [md_flg],08h
	jz Sound_m
	cmp [md_flg],10h
	jz Mem_Display
	
	

;---------------------MODES-----------------------------------------------------
;-------------------------------------------------------------------------------
;---------------------START ACCURACY MODE---------------------------------------
;SHORT PRESS(SP) STATES
;00 = Entrance to Accuracy Mode- defaults are set
;01 = Set Accuracy Mode Register to Display Tenthsec 
;02 = Set Accuracy Mode Register to Display HalfSec
;03 = Set Accuracy Mode Register to Display Seconds
Accuracy_m:
    cmp [addr_shrt_p], 00h				;check if SP is set for 00 state
	jnz check_acc_ms
	mov A, 00h							;display Accuracy Mode
	mov X, 00h
	lcall LCD_Position
	mov A, >ACCURACY_MODE
	mov X, <ACCURACY_MODE
	lcall LCD_PrCString
	
	mov A, 01h
	mov X, 00h
	lcall LCD_Position
	mov A, >CLEAN_LCD
	mov X, <CLEAN_LCD
	lcall LCD_PrCString
	
	mov [addr_acc_mode], tenthsec_mode	;defaults to tenth second mode
	mov [count_saved], 00h
	
	ljmp loop							;jump out to check for long press

check_acc_ms:
	cmp [addr_shrt_p], 01h				;check if SP is set for 01 state
	jnz check_acc_halfsec				;if not, go to next check
	mov [addr_acc_mode], tenthsec_mode	;set to tenth second mode anyways
	mov A, 00h							;display tenth second mode select on LCD
	mov X, 00h
	lcall LCD_Position
	mov A, >TENTHSEC_MODE
	mov X, <TENTHSEC_MODE
	lcall LCD_PrCString
	ljmp loop							;jump out to check for long press


check_acc_halfsec:
	cmp [addr_shrt_p] , 02h				;check if SP is set for 02 state
	jnz check_acc_sec					;if not, go to next check
	mov [addr_acc_mode], halfsec_mode	;set to half second mode
	mov A, 00h							;display half second mode select on LCD
	mov X, 00h
	lcall LCD_Position
	mov A, >HALFSEC_MODE
	mov X, <HALFSEC_MODE
	lcall LCD_PrCString
	ljmp loop							;jump out to check for long press

	
check_acc_sec:
	cmp [addr_shrt_p] , 03h				;check if SP is set for 03 state
	jnz check_acc_end					;if not, go to next check
	mov [addr_acc_mode], sec_mode		;set to half second mode
	mov A, 00h							;display second mode select on LCD
	mov X, 00h
	lcall LCD_Position
	mov A, >SEC_MODE
	mov X, <SEC_MODE
	lcall LCD_PrCString
	ljmp loop							;jump out to check for long press

check_acc_end:
	cmp [addr_shrt_p], 04h				;Accuracy Mode has only 4 SP state
	jc loop								;if SP value is less than 4, it is a known SP state					
	mov [addr_shrt_p], 00h				;if it goes over than reset SP state
	
	ljmp loop							;jmp out to check for long press
	
;---------------------END ACCURACY MODE--------------------------------------
;---------------------START THRESHOLD MODE-----------------------------------
;SHORT PRESS(SP) STATES
;00 = Entrance to Threshold Mode- defaults are set
;01 = Clean LCD to get ready for Calculating Threshold
;02 = Calculate normal room frequency to determine threshold
Threshold_m:
	cmp [addr_shrt_p], 00h				;check if SP is set for 00 state
	jnz check_input_sensitivity			;if not, go to next check
	mov A, 00h
	mov X, 00h
	lcall LCD_Position
	mov A, >THRESHOLD_MODE
	mov X, <THRESHOLD_MODE
	lcall LCD_PrCString
	ljmp loop							;jmp out to check for long press
	
check_input_sensitivity:
	cmp [addr_shrt_p], 01h				;check if SP is set for 01 state
	jnz calculate_threshold				;if not, go to next check
	mov A, 00h
	mov X, 00h
	lcall LCD_Position
	mov A, >PRESS_TO_START
	mov X, <PRESS_TO_START
	lcall LCD_PrCString
	ljmp loop							;jump out to check for long press
	
calculate_threshold:	
	;clear iresult_total
	cmp [addr_shrt_p], 02h				;check if SP is set for 02 state
	jnz calculate_threshold				;if not, go to next check
	
	mov [iResult_Total+3], 00h			;reset total and count values for use by the ADC
	mov [iResult_Total+2], 00h			;total holds the addition of each measurement
	mov [iResult_Total+1], 00h
	mov [iResult_Total+0], 00h
	
	mov [iResult_count+3], 00h			;count tallies up the number of measurements
	mov [iResult_count+2], 00h			;which have occurred during the sampling time
	mov [iResult_count+1], 00h
	mov [iResult_count+0], 00h
	
	mov [addr_adc_inc_ms],00h			;reset ADC time value being incremented in the timer ISR
wait_1_ADC:                             
    lcall  DUALADC_1_fIsDataAvailable	;check if there is data available from the ADC
    jz    wait_1_ADC					;poll until data is ready
	
	M8C_DisableGInt   					;once data is ready, it is recommended to disable GEI
    lcall  DUALADC_1_iGetData1      	;Get ADC1 Data (X=MSB A=LSB)
	M8C_EnableGInt 						;enable interrupts back up


	lcall  DUALADC_1_ClearFlag 			;clear ADC flags

	and F, FBh							;clear the CF 
	
	add	[iResult_Total+3], A			;save LSB of Data into the LSB of the 4-byte total
	mov A, X							;move X into A for use of adc instruction
	adc [iResult_Total+2], A			;save MSB of Data into the next LSB of the 4-byte total
	adc [iResult_Total+1], 00h			;continue add w/ carry for the rest of the total
	adc [iResult_Total+0], 00h
	
	inc [iResult_count+3]				;increment the count
	adc [iResult_count+2],00h			;continue add w/ carry for the rest of the total count
	adc [iResult_count+1],00h
	adc [iResult_count+0],00h
										;check if the total sampling time finished
	cmp [addr_adc_inc_ms], 28h			;once 28h (28ms) is reached, move on, otherwise continue
	jnz wait_1_ADC						;taking measurements
	
	
	mov [dOpr1+0], [iResult_Total+0]	;copy the total to the dividend for divide routine
	mov [dOpr1+1], [iResult_Total+1]
	mov [dOpr1+2], [iResult_Total+2]
	mov [dOpr1+3], [iResult_Total+3]
	
	mov [dOpr2+0], [iResult_count+0]	;copy the total to the divisor for divide routine
	mov [dOpr2+1], [iResult_count+1]
	mov [dOpr2+2], [iResult_count+2]
	mov [dOpr2+3], [iResult_count+3]
	
	lcall divide_32_routine				;call divide routine to find average frequency
	mov [iResult1+3], [dRes+3]			;copy the result from routine to local register
	mov [iResult1+2], [dRes+2]	
	mov [iResult1+1], [dRes+1]
	mov [iResult1+0], [dRes+0]
	

	mov [threshold_value+1], [iResult1+3]	;copy over LSB to threshold LSB
	mov [threshold_value+0], [iResult1+2]	;copy over MSB to threshold MSB
	
	;shift threshold value to make whistle trigger when it's 2x higher
	asl [threshold_value+1]					;multiple threshold by two
	asl [threshold_value+0]					;shift left both LSB & MSB with carry of LSB to MSB
	
	mov A, 00h								;display 'Calc Thresh' 
	mov X, 00h
	lcall LCD_Position
	mov A, >CALC_THRESH_MODE
	mov X, <CALC_THRESH_MODE
	lcall LCD_PrCString
	
	mov A, 00h								;display LSB of result & threshold
	mov X, 0Ah
	lcall LCD_Position
	mov A, [iResult1+3]
	lcall LCD_PrHexByte
	
	mov A, 00h
	mov X, 0Dh
	lcall LCD_Position
	mov A, [threshold_value+1]
	lcall LCD_PrHexByte
	
end_input_sensitivity:
	cmp [addr_shrt_p], 03h					;Theshold Mode has only 3 SP state
	jc loop									;if SP value is less than 3, it is a known SP state				
	mov [addr_shrt_p], 00h					;if it goes over than reset SP state
	
	ljmp loop
	
;---------------------END THRESHOLD MODE--------------------------------------
;---------------------START BUTTON MODE---------------------------------------
;SHORT PRESS(SP) STATES
;00 = Entrance to Button Mode
;01 = Clean LCD to get ready for displaying the timer values
;02 = Run timer
;03 = Save values from the run time
;04 = display values saved

Button_m:
    cmp [addr_shrt_p], 00h				;check if SP is set for 00 state
	jnz check_but_clear					;if not, go to next check
	mov A, 00h
	mov X, 00h
	lcall LCD_Position
	mov A, >BUTTON_MODE
	mov X, <BUTTON_MODE
	lcall LCD_PrCString

check_but_clear:
	cmp [addr_shrt_p], 01h				;check if SP is set for 01 state
	jnz check_but_start					;if not, go to next check
	mov [addr_inc_ms], 00h
	mov [addr_inc_s], 00h
	mov [addr_inc_m], 00h
	mov [addr_inc_h], 00h
	mov [addr_timer_flag], 01h 			;set flag that a new count is starting
	
	
	mov A, 00h							;clear LSD and place time markers "  :   :  "
	mov X, 00h
	lcall LCD_Position
	mov A, >CLEAR_TIME
	mov X, <CLEAR_TIME
	lcall LCD_PrCString
	ljmp loop
	
check_but_start:
	cmp [addr_shrt_p], 02h				;check if SP is set for 02 state
	jnz check_but_stop					;if not, go to next check

										
	cmp [addr_timer_flag], 01h			;check if first entry to timer then reset timer value
	jnz button_timer_routine			;if not than just keep running timer value
	mov [addr_timer_inc_ms], 00h
	mov [addr_timer_flag], 00h			;clear flag as to not enter clearing the timer value again
	
	
button_timer_routine:					
		cmp [addr_acc_mode],sec_mode	;first need to check which accuracy mode timer is in
		jz label_sec_mode

		cmp [addr_acc_mode],halfsec_mode
		jz label_halfsec_mode
					
	label_tenthsec_mode:				;if its not in sec or halfsec mode it will be in tenth
		mov [addr_inc_ms], [addr_timer_inc_ms]	;copy the timer value directly as we are 
												;display each .01s interrupt that occurs
		ljmp check_ms							;jump to check_ms




	;in halfsec mode only when timer gets to every .5s interval does the timer need to be updated
	;in order to do this a check for whether the timer value is 32h (.5s) or 00h(.0s)
	;if the check passes than display that timer value, if not than just hold on to the last value
	;that was captured until the check & update passes (view picture in report info)
	label_halfsec_mode: 				;perform check for halfmode
		mov A, [addr_timer_inc_ms]		;copy current count to A
		mov X, A						;save a copy in X
		cmp A, 32h						;compare A (which is the timer value) to .5s 
		jnz check_if_00					;if it's not .5s than comapare A with .0s 
												;if it is .5s than pass the timer count value to 
		mov [addr_inc_ms], [addr_timer_inc_ms]	;the register which will be used to display and save the time
		ljmp check_ms							;go to check_ms
	check_if_00:
		mov A, X						;compare of .5s didnt' pass so check .0s
		cmp A, 00h						
		jnz check_ms					;if its not .0s than don't update the register, hold old value
												;if it is .0s than pass the timer count value to
		mov [addr_inc_ms], [addr_timer_inc_ms]	;the register which will be used to display and save
		ljmp check_ms							;go to check_ms




	;in second mode only when timer gets to every .0s interval does the timer need to be updated
	;in order to do this a check only for when the timer value is 00h(.0s)
	;if the check passes than display that pass the timer value to the display/saved on, if not than just hold on to the last value
	;that was captured until the check & update passes (view picture in report info)
	label_sec_mode: 				
		mov A, [addr_timer_inc_ms]					;copy over timer value
		cmp A, 00h									;compare with .0s
		jnz check_ms								;keep display value as is if compare doesn't match
		mov [addr_inc_ms], [addr_timer_inc_ms]		;update value if compare matches - basically never need to update because it will always be 0
		;ljmp check_ms

	check_ms:
		mov A, [addr_timer_inc_ms] 					;copy over the timer value to determine if the timer needs to get reset
		cmp A, 64h 									;compare to 100
		jnz display_ms					
				
	reset_ms:
		mov [addr_timer_inc_ms], 00h				;do a reset on the timer to get back to 00
		inc [addr_inc_s]							;increment seconds
		
	display_ms:	
		mov A, 00h									;display ms time on LCD
		mov X, 09h
		lcall LCD_Position
		mov A, [addr_inc_ms]
		lcall LCD_PrHexByte
		
	check_sec:	
		mov A, [addr_inc_s]							;copy the seconds (that gets incremented by the check_ms) to A
		cmp A, 3Ch									;compare with 60 to make a minute
		jnz display_sec								;if it hasn't reached a full second than just continue with it's value

	reset_sec:
		mov [addr_inc_s],00h						;do a reset on the seconds timer to get back to 00
		inc [addr_inc_m]							;increment minutes
		
	display_sec:
	    mov A, 00h									;display second time on LCD
		mov X, 06h
		lcall LCD_Position
		mov A, [addr_inc_s]
		lcall LCD_PrHexByte
		
		
	check_min:
		mov A, [addr_inc_m]							;copy the minutes (that gets incremented by the check_sec) to A
		cmp A, 3Ch									;compare with 60 to make an hour
		jnz display_min								;if it hasn't reached a full minute than just continue with it's value

	reset_min:
		mov [addr_inc_s],00h						;do a reset on the minutes timer to get back to 00 after full minute reached
		inc [addr_inc_h]							;increment hours

	display_min:
	    mov A, 00h									;display minutes times on LCD
		mov X, 03h
		lcall LCD_Position
		mov A, [addr_inc_m]
		lcall LCD_PrHexByte
		
	check_hour:
		mov A, [addr_inc_h]							;perform check on hours
		cmp A, 18h									;compare with 24
		jnz display_hour							;if it hasn't reached a full 24 hours than just continue with it's value
		
	reset_hour:
		mov [addr_inc_h], 00h						;otherwise reset back to 00, 24 hours is largest timer can go
		
	display_hour:									;display timer value
		mov A, 00h
		mov X, 00h
		lcall LCD_Position
		mov A, [addr_inc_h]
		lcall LCD_PrHexByte
	ljmp loop										;jump out to check for long press
	
check_but_stop:
	cmp [addr_shrt_p], 03h							;check if SP is set for 03 state
	jnz before_check_but_end						;if not, go to next check
;	lcall Save_Time
	cmp [flag_val], 01h								;check if this is the first round of saving
	jz saved										;if it is then don't 
	mov [flag_val], 01h
;	mov [count_saved], 00h			;back to initialized value
;	mov [save_time_index], 00

;save_and_count:
		mov A, [addr_inc_h]							;copy the hours over 
		mvi [save_time_index], A					;write to register mvw is pointing to
		mov A, [addr_inc_m]							;perform for minutes
		mvi [save_time_index], A
		mov A, [addr_inc_s]							;perform for seconds
		mvi [save_time_index], A
		mov A, [addr_inc_ms]						;perform for ms
		mvi [save_time_index], A
		
		inc [count_saved]							;increment number of saved
		
	mov A, 01h										;display on LCD number of saved values
	mov X, 0Ch
	lcall LCD_Position
	mov A, [count_saved]
	lcall LCD_PrHexByte
	
	
	
saved:												;if its been saved once than don't keep saving
;	mov [flag_val], 00h								;if there is no button press, and with this code layout
;	ljmp loop										;SP loop will keep cycling, so 'flag_val' was added to 
													;only save a value once and continue incrementing from last
													;saved pointer
	;stop timer

	
before_check_but_end:								
	cmp [addr_shrt_p], 04h							;check if SP is set for 04 state				
	jnz check_but_end								;if not, go to next check						
	mov [flag_val], 00h								;clear 'first save flag' so another entrance into 
													;button mode will allow for a save
	

;	mov [pg6_reference], 00h						;set the mvi pointer back to 00
	
	mvi A, [pg6_reference]							;read from the mvi pointer						
	mov [read_addr_inc_h], A						;perform for hours
	mvi A, [pg6_reference]
	mov [read_addr_inc_m], A						;perform for minutes
	mvi A, [pg6_reference]
	mov [read_addr_inc_s], A						;perform for seconds
	mvi A, [pg6_reference]
	mov [read_addr_inc_ms], A						;perform for ms

;	mov A, 00h										;display all on LCD to confirm value saved
;	mov X, 00h
;	lcall LCD_Position
;	mov A, [read_addr_inc_h]
;	lcall LCD_PrHexByte
;	
;	mov A, 00h
;	mov X, 03h
;	lcall LCD_Position
;	mov A, [read_addr_inc_m]
;	lcall LCD_PrHexByte
;	
;	mov A, 00h
;	mov X, 06h
;	lcall LCD_Position
;	mov A, [read_addr_inc_s]
;	lcall LCD_PrHexByte
;	
;	mov A, 00h
;	mov X, 09h
;	lcall LCD_Position
;	mov A, [read_addr_inc_ms]
;	lcall LCD_PrHexByte	
	
	
	mov A, 00h										;display all on LCD to confirm value saved
	mov X, 00h
	lcall LCD_Position
	mov A, [addr_inc_h]
	lcall LCD_PrHexByte
	
	mov A, 00h
	mov X, 03h
	lcall LCD_Position
	mov A, [addr_inc_m]
	lcall LCD_PrHexByte
	
	mov A, 00h
	mov X, 06h
	lcall LCD_Position
	mov A, [addr_inc_s]
	lcall LCD_PrHexByte
	
	mov A, 00h
	mov X, 09h
	lcall LCD_Position
	mov A, [addr_inc_ms]
	lcall LCD_PrHexByte
	
	mov A, 01h
	mov X, 00h
	lcall LCD_Position
	mov A, >SAVE
	mov X, <SAVE
	lcall LCD_PrCString
	
check_but_end:
	cmp [addr_shrt_p], 05h				;Button mode has only 5 SP states
	jc loop								;if SP values is less than 5, it is a known SP state
	mov [addr_shrt_p], 00h				;if it goes over than reset SP state
	
	mov A, 01h
	mov X, 00h
	lcall LCD_Position
	mov A, >CLEAN_LCD
	mov X, <CLEAN_LCD
	lcall LCD_PrCString
	
	ljmp loop							;jmp out to check for long press
	
;---------------------END BUTTON MODE----------------------------------------
;---------------------START SOUND MODE---------------------------------------
;SHORT PRESS(SP) STATES
;00 = Entrance to Button Mode
;01 = Clean LCD to get ready for displaying the timer values
;02 = Wait for Sound to start timer
;03 = Run Timer & wait for sound to stop timer
;04 = Save values from the run time
;05 = display values saved
Sound_m:
	cmp [addr_shrt_p], 00h				;check if SP is set for 00 state
	jnz start_sound_check				;if not, go to next check
	mov A, 00h							;display on LCD
	mov X, 00h	
	lcall LCD_Position
	mov A, >SOUND_MODE
	mov X, <SOUND_MODE
	lcall LCD_PrCString
	
	mov [flag_val], 00h
	ljmp loop
	
start_sound_check:
	cmp [addr_shrt_p], 01h				;check if SP is set for 01 state
	jnz give_time_for_sound_to_occur_for_start ;if not , go to next check
	
	mov [addr_inc_ms], 00h				;clear all timer values to run new time
	mov [addr_inc_s], 00h
	mov [addr_inc_m], 00h
	mov [addr_inc_h], 00h
	mov [addr_timer_flag], 01h 			;new count is starting
	
	mov A, 00h							;display on LCD
	mov X, 00h
	lcall LCD_Position
	mov A, >CLEAR_TIME
	mov X, <CLEAR_TIME
	lcall LCD_PrCString
	ljmp loop
	
give_time_for_sound_to_occur_for_start:	
	cmp [addr_shrt_p], 02h					;check if SP is set for 02 state
	jnz run_timer							;if not, go to next check
	
	;disable button press to start timer
	;M8C_DisableIntMask INT_MSK0, INT_MSK0_GPIO 		;enable GPIO Interrupt Mask
	
	mov [iResult_Total+3], 00h			;reset total and count values for use by the ADC
	mov [iResult_Total+2], 00h			;total holds the addition of each measurement
	mov [iResult_Total+1], 00h
	mov [iResult_Total+0], 00h
	
	mov [iResult_count+3], 00h			;count tallies up the number of measurements
	mov [iResult_count+2], 00h			;which have occurred during the sampling time
	mov [iResult_count+1], 00h
	mov [iResult_count+0], 00h
	
	mov [addr_adc_inc_ms],00h			;reset ADC time value being incremented in the timer ISR
wait_2_ADC:                             
    lcall  DUALADC_1_fIsDataAvailable	;check if there is data available from the ADC
    jz    wait_2_ADC					;poll until data is ready

	M8C_DisableGInt   					;once data is ready, it is recommended to disable GEI   
    lcall  DUALADC_1_iGetData1        	;Get ADC1 Data (X=MSB A=LSB)
	M8C_EnableGInt 						;enable interrupts back up 

	lcall  DUALADC_1_ClearFlag 			;clear ADC flags 

	and F, FBh							;clear the CF
	
	add	[iResult_Total+3], A 			;save LSB of Data into the LSB of the 4-byte total
	mov A, X							;move X into A for use of adc instruction
	adc [iResult_Total+2], A			;save MSB of Data into the next LSB of the 4-byte total
	adc [iResult_Total+1], 00h			;continue add w/ carry for the rest of the total
	adc [iResult_Total+0], 00h
	
	inc [iResult_count+3]				;increment the count
	adc [iResult_count+2],00h			;continue add w/ carry for the rest of the total count
	adc [iResult_count+1],00h
	adc [iResult_count+0],00h
										;check if the total sampling time finished

	cmp [addr_adc_inc_ms], 05h			;once 05h (05ms) is reached, move on, otherwise continue
	jnz wait_2_ADC						;taking measurements
	
	mov [dOpr1+0], [iResult_Total+0]	;copy the total to the dividend for divide routine
	mov [dOpr1+1], [iResult_Total+1]
	mov [dOpr1+2], [iResult_Total+2]
	mov [dOpr1+3], [iResult_Total+3]
	
	mov [dOpr2+0], [iResult_count+0]	;copy the total to the divisor for divide routine
	mov [dOpr2+1], [iResult_count+1]
	mov [dOpr2+2], [iResult_count+2]
	mov [dOpr2+3], [iResult_count+3]
	
	lcall divide_32_routine				;call divide routine to find average frequency
	mov [iResult1+3], [dRes+3]			;copy the result from routine to local register
	mov [iResult1+2], [dRes+2]
	mov [iResult1+1], [dRes+1]
	mov [iResult1+0], [dRes+0]
	
compare_to_threshold:
	mov A, [iResult1+2]				;holds MSB of of result part that we care about (aka lower two bytes)
    cmp A, [threshold_value+0]		;holds MSB of threshold
	jz check_LSB_of_sound			;if they are both zero than check LSB
	jnc start_sound_timer			;if there was no carry, than incoming MSB is greater than threshold MSB = SOUND!
	ljmp loop						;if there was a carry, than threshold MSB is greater than incoming, so incoming isn't high enough
									;if not check if timing is running and continue running it/not running and continue not running it
	
check_LSB_of_sound:	
	mov A, [iResult1+3]				;check LSB of result vs LSB of threshold
	cmp A, [threshold_value+1]
	jnc start_sound_timer			;result is more than threshold, start the timer
	;ljmp check_run_timer			;if not jump back to loop to check for long press then come back if no press what taken to get out
	ljmp loop


start_sound_timer:
	inc [addr_shrt_p]				;received sound so increment short press to move to next SP state
	ljmp loop						;jump out to check for long press

run_timer:
	cmp [addr_shrt_p], 03h			;check if SP is set for 03 SP State
	jnz dont_run_timer				;if not, go to next check
	
	;re-enable button press
	;M8C_EnableIntMask INT_MSK0, INT_MSK0_GPIO 					;allow button presses
;
;	mov A, reg[PRT1DR]				;for debug purposes
;	xor A, FFh
;	mov reg[PRT1DR], A
	
	cmp [addr_timer_flag], 01h		;check if first entry to timer then reset timer value 
	jnz sound_timer_routine			;if not than just keep running timer value
	mov [addr_timer_inc_ms], 00h
	mov [addr_timer_flag], 00h			;clear flag as to not enter clearing the timer value again


sound_timer_routine:
	
	;call task, copy of button press task, refer commenting to that
	lcall Sound_mode_generic_timer
	
give_time_for_sound_to_occur_for_stop:	;after every iteration check if another sound comes in to 
	mov [iResult_Total+3], 00h			;stop the timer
	mov [iResult_Total+2], 00h			;follows same method of that to start the timer
	mov [iResult_Total+1], 00h
	mov [iResult_Total+0], 00h
	
	mov [iResult_count+3], 00h
	mov [iResult_count+2], 00h
	mov [iResult_count+1], 00h
	mov [iResult_count+0], 00h
	
	mov [addr_adc_inc_ms],00h			;reset ADC time value being incremented in the timer ISR
wait_2_ADC_stop:                        
    lcall  DUALADC_1_fIsDataAvailable 	;check if there is data available from the ADC
    jz    wait_2_ADC_stop				;poll until data is ready

	M8C_DisableGInt    					;once data is ready, it is recommended to disable GEI
    lcall  DUALADC_1_iGetData1        	;Get ADC1 Data (X=MSB A=LSB)
	M8C_EnableGInt 						;enable interrupts back up


	lcall  DUALADC_1_ClearFlag 			;clear ADC flags 

	and F, FBh							;clear the CF
	
	add	[iResult_Total+3], A 			;save LSB of Data into the LSB of the 4-byte total
	mov A, X							;move X into A for use of adc instruction
	adc [iResult_Total+2], A			;save MSB of Data into the next LSB of the 4-byte total
	adc [iResult_Total+1], 00h			;continue add w/ carry for the rest of the total
	adc [iResult_Total+0], 00h
	
	inc [iResult_count+3]				;increment the count
	adc [iResult_count+2],00h			;continue add w/ carry for the rest of the total count
	adc [iResult_count+1],00h
	adc [iResult_count+0],00h
										;check if the total sampling time finished
	cmp [addr_adc_inc_ms], 05h			;once 05h (05ms) is reached, move on, otherwise continue
	jnz wait_2_ADC						;taking measurements
	
	mov [dOpr1+0], [iResult_Total+0]	;copy the total to the dividend for divide routine
	mov [dOpr1+1], [iResult_Total+1]
	mov [dOpr1+2], [iResult_Total+2]
	mov [dOpr1+3], [iResult_Total+3]
	
	mov [dOpr2+0], [iResult_count+0]	;copy the total to the divisor for divide routine
	mov [dOpr2+1], [iResult_count+1]
	mov [dOpr2+2], [iResult_count+2]
	mov [dOpr2+3], [iResult_count+3]
	
	lcall divide_32_routine				;call divide routine to find average frequency
	mov [iResult1+3], [dRes+3]			;copy the result from routine to local register
	mov [iResult1+2], [dRes+2]
	mov [iResult1+1], [dRes+1]
	mov [iResult1+0], [dRes+0]
	
compare_to_threshold_stop:
	mov A, [iResult1+2]				;holds MSB of of result part that we care about (aka lower two bytes)
    cmp A, [threshold_value+0]		;holds MSB of threshold
	jz check_LSB_of_sound_stop		;if they are both zero than check LSB
	jnc stop_the_sound_timer		;if there was no carry, than incoming MSB is greater than threshold MSB = SOUND!
	ljmp loop						;if there was a carry, than threshold MSB is greater than incoming, so incoming isn't high enough
									;if not check if timing is running and continue running it/not running and continue not running it
	
check_LSB_of_sound_stop:	
	mov A, [iResult1+3]				;check LSB of result vs LSB of threshold
	cmp A, [threshold_value+1]
	jnc stop_the_sound_timer		;result is more than threshold
	;ljmp check_run_timer			;if not jump back to loop to check for long press		
	ljmp loop	

stop_the_sound_timer:
	inc [addr_shrt_p]				;received sound so increment short press to move to next SP state	
	ljmp loop						;jump out to check for long press
									;button press will also inc SP

dont_run_timer:
	cmp [addr_shrt_p], 04h			
	jnz before_check_but_end_sound
	;save time here
	
	mov reg[MVW_PP], 06h
;	mov A, reg[PRT1DR]				;for debug purposes
;	xor A, FFh
;	mov reg[PRT1DR], A
;	
	cmp [flag_val], 01h				;check if this is the first round of saving
	jz saved_sound					;if it is then don't 
	mov [flag_val], 01h
	
	mov A, [addr_inc_h]			;Please uncomment this line while testing for actual values
	;mov A, FFh						;Comment this line while testing actual values
	mvi [save_time_index], A
	mov A, [addr_inc_m]				;Please uncomment this line while testing for actual values
	;mov A, EEh						;Comment this line while testing actual values
	mvi [save_time_index], A
	mov A, [addr_inc_s]				;Please uncomment this line while testing for actual values
	;mov A, DDh						;Comment this line while testing actual values
	mvi [save_time_index], A
	mov A, [addr_inc_ms]			;Please uncomment this line while testing for actual values
	;mov A, CCh						;Comment this line while testing actual values
	mvi [save_time_index], A
	
	inc [count_saved]
	
	mov A, 01h
	mov X, 0Ch
	lcall LCD_Position
	mov A, [count_saved]
	lcall LCD_PrHexByte
	
;	mov A, 00h
;	mov X, 0Eh
;	lcall LCD_Position
;	mov A, reg[MVW_PP]
;	lcall LCD_PrHexByte
;										;If the maximum output shown for the above dummy values is FF EE DD CC then the actual values are not being stored in 
										;addr_inc_h, addr_inc_m, addr_inc_s and addr_inc_ms. Please make sure that the values are stored in these registers.
										;the code is otherwise ditto of the code in button mode.
										
							;Because of the non-debouncing button, I have been trying to do this myself, but have not been able to 
										;start the timer with the whistle since 1 hour. Please see if this is working in your kit.
	
saved_sound:						;if its been saved once than don't keep saving
									;if there is no button press, and with this code layout
	ljmp loop						;SP loop will keep cycling, so 'flag_val' was added to 
									;only save a value once and continue incrementing from last
									;saved pointer
	
before_check_but_end_sound:
	
	cmp [addr_shrt_p], 05h
	jnz end_sound_check
	
	mov [flag_val], 00h
	
	mov reg[MVR_PP], 06h
;	mov [pg6_reference], 00h		;set the mvi pointer back to 00
;	
;	mvi A, [pg6_reference]			;read from the mvi pointer
;	mov [read_addr_inc_h], A		;perform for hours
;	mvi A, [pg6_reference]
;	mov [read_addr_inc_m], A		;perform for minutes
;	mvi A, [pg6_reference]
;	mov [read_addr_inc_s], A		;perform for seconds
;	mvi A, [pg6_reference]
;	mov [read_addr_inc_ms], A		;perfrom for ms
;
;	mov A, 00h						;display all on LCD to confirm saved values
;	mov X, 00h
;	lcall LCD_Position
;	mov A, [read_addr_inc_h]
;	lcall LCD_PrHexByte
;	
;	mov A, 00h
;	mov X, 03h
;	lcall LCD_Position
;	mov A, [read_addr_inc_m]
;	lcall LCD_PrHexByte
;	
;	mov A, 00h
;	mov X, 06h
;	lcall LCD_Position
;	mov A, [read_addr_inc_s]
;	lcall LCD_PrHexByte
;	
;	mov A, 00h
;	mov X, 09h
;	lcall LCD_Position
;	mov A, [read_addr_inc_ms]
;	lcall LCD_PrHexByte	
	
	mov A, 01h
	mov X, 00h
	lcall LCD_Position
	mov A, >SAVE
	mov X, <SAVE
	lcall LCD_PrCString

;	ljmp loop
	
end_sound_check:
	cmp [addr_shrt_p], 06h				;Sound mode has only 6 SP states
	jc loop								;if SP values is less than 5, it is a known SP state			
	mov [addr_shrt_p], 00h				;if it goes over than reset SP state

	mov A, 01h
	mov X, 00h
	lcall LCD_Position
	mov A, >CLEAN_LCD
	mov X, <CLEAN_LCD
	lcall LCD_PrCString

	ljmp loop							;jmp out to check for long press
;---------------------END SOUND MODE-----------------------------------------
;---------------------START MEMORY MODE--------------------------------------

Mem_Display:
	cmp [addr_shrt_p], 00h				;check if SP is set for 00 state
	jnz here_1
	mov A, 00h
	mov X, 00h
	lcall LCD_Position
	mov A, >MEMORY_MODE
	mov X, <MEMORY_MODE
	lcall LCD_PrCString
	ljmp loop
	
	here_1:
	mov reg[MVR_PP], 06h			;reading from memory page 6
	
;	mov [sum_ms], 00h
;	mov [sum_sec_LSB], 00h
;	mov [sum_sec_MSB], 00h
;	mov [sum_min_LSB], 00h
;	mov [sum_min_MSB], 00h
;	mov [sum_hr], 00h
;	
;	mov [avg_ms], 00h
;	mov [avg_sec], 00h
;	mov [avg_min], 00h
;	mov [avg_hr], 00h
	
	
	mov [pg6_reference], 00h

	cmp [addr_shrt_p], 01h						;check if SP is set for 01 state
	jnz shortest_time
	
	mov X, 11
;	mov [pg6_reference], 00		;bringing the position at pg6 at the starting position
	ljmp next
	
next_A:
	add [pg6_reference], 3
	and F, FBh
	ljmp next
next_B:
	add [pg6_reference], 2
	and F, FBh
	ljmp next
next_C:
	add [pg6_reference], 1
	and F, FBh
	ljmp next
	
next:
	dec X
	jz end_max
	mvi A, [pg6_reference]
	cmp A, [max_hr]
	jz check_min_max
	jc next_A
	mov [max_hr], A
	mvi A, [pg6_reference]
	mov [max_min], A
	mvi A, [pg6_reference]
	mov [max_sec], A
	mvi A, [pg6_reference]
	mov [max_ms], A
	ljmp next
check_min_max:
	mvi A, [pg6_reference]
	cmp A, [max_min]
	jz check_sec_max
	jc next_B
	mov [max_min], A
	mvi A, [pg6_reference]
	mov [max_sec], A
	mvi A, [pg6_reference]
	mov [max_ms], A
	ljmp next
check_sec_max:
	mvi A, [pg6_reference]
	cmp A, [max_sec]
	jz check_ms_max
	jc next_C
	mov [max_sec], A
	mvi A, [pg6_reference]
	mov [max_ms], A
	ljmp next
check_ms_max:
	mvi A, [pg6_reference]
	cmp A, [max_ms]
	jz next
	jc next
	mov [max_ms], A
	ljmp next

end_max:

;	mov A, 01h
;	mov X, 00h
;	lcall LCD_Position
;	mov A, >CLEAN_LCD
;	mov X, <CLEAN_LCD
;	lcall LCD_PrCString
	mov A, 00h
	mov X, 00h
	lcall LCD_Position
	mov A, >MAXIMUM
	mov X, <MAXIMUM
	lcall LCD_PrCString
	
	mov A, 01h
	;mov A, 00h
	mov X, 00h
	lcall LCD_Position
	mov A, [max_hr]
	lcall LCD_PrHexByte
	
	mov A, 01h
	;mov A, 00h
	mov X, 03h
	lcall LCD_Position
	mov A, [max_min]
	lcall LCD_PrHexByte
	
	mov A, 01h
	;mov A, 00h
	mov X, 06h
	lcall LCD_Position
	mov A, [max_sec]
	lcall LCD_PrHexByte
	
	;mov A, 01h
	mov A, 01h
	mov X, 09h
	lcall LCD_Position
	mov A, [max_ms]
	lcall LCD_PrHexByte
	
;	mov A, 01h
;	mov X, 00h
;	lcall LCD_Position
;	mov A, >CLEAN_LCD
;	mov X, <CLEAN_LCD
;	lcall LCD_PrCString


	ljmp loop
	
shortest_time:
	cmp [addr_shrt_p], 02h
	jnz average
	
	mov [pg6_reference], 00
	mov X, 10
	mvi A, [pg6_reference]
	mov [min_hr], A
	mvi A, [pg6_reference]
	mov [min_min], A
	mvi A, [pg6_reference]
	mov [min_sec], A
	mvi A, [pg6_reference]
	mov [min_ms], A
	ljmp next_values
	
min_loop:
next_1:
	add [pg6_reference], 3
	and F, FBh
	ljmp next_values
next_2:
	add [pg6_reference], 2
	and F, FBh
	ljmp next_values
next_3:
	add [pg6_reference], 1
	and F, FBh
next_values:
	dec X
	jz end_min
	mvi A, [pg6_reference]
	cmp A, [min_hr]
	jz check_min_min
	jnc next_1
	mov [min_hr], A
	mvi A, [pg6_reference]
	mov [min_min], A
	mvi A, [pg6_reference]
	mov [min_sec], A
	mvi A, [pg6_reference]
	mov [min_ms], A
	ljmp next_values
check_min_min:
	mvi A, [pg6_reference]
	cmp A, [min_min]
	jz check_sec_min
	jnc next_2
	mov [min_min], A
	mvi A, [pg6_reference]
	mov [min_sec], A
	mvi A, [pg6_reference]
	mov [min_ms], A
	ljmp next_1
check_sec_min:
	mvi A, [pg6_reference]
	cmp A, [min_sec]
	jz check_ms_min
	jnc next_3
	mov [min_sec], A
	mvi A, [pg6_reference]
	mov [min_ms], A
	ljmp next_1
check_ms_min:
	mvi A, [pg6_reference]
	cmp A, [min_ms]
	jz next_values
	jnc next_values
	mov [min_ms], A
	ljmp next_values
	
end_min:
;	mov A, 01h
;	mov X, 00h
;	lcall LCD_Position
;	mov A, >CLEAN_LCD
;	mov X, <CLEAN_LCD
;	lcall LCD_PrCString
	
	mov A, 01h
	mov X, 00h
	lcall LCD_Position
	mov A, [min_hr]
	lcall LCD_PrHexByte
	
	mov A, 01h
	mov X, 03h
	lcall LCD_Position
	mov A, [min_min]
	lcall LCD_PrHexByte
	
	mov A, 01h
	mov X, 06h
	lcall LCD_Position
	mov A, [min_sec]
	lcall LCD_PrHexByte
	
	mov A, 01h
	mov X, 09h
	lcall LCD_Position
	mov A, [min_ms]
	lcall LCD_PrHexByte
	
;	mov A, 00h
;	mov X, 00h
;	lcall LCD_Position
;	mov A, >CLEAN_LCD
;	mov X, <CLEAN_LCD
;	lcall LCD_PrCString
	
	mov A, 00h
	mov X, 00h
	lcall LCD_Position
	mov A, >MINIMUM
	mov X, <MINIMUM
	lcall LCD_PrCString
	
	ljmp loop
average:
	cmp [addr_shrt_p],03h
	jnz end_memory_mode
	
	;Computing sum here
	
	mov [counter_sum],90h
	mov [counter_input],00h	
	mov A,00h
	mvi [counter_sum],A
	mvi [counter_sum],A
	mvi [counter_sum],A
	mvi [counter_sum],A
	
	;register counter_sum will point to register 90h so that counter_sum can be implemented in MVI
	;load the first set of inputs into register that hold sum (90h,91h,92h)
	
	mov [counting_adds],4h	;since there will be 4 additions to finish adding two "times" we will set a counter for that.
	mov [input_count],09h	;This will enable us to add 4 sets of "time" values. This can be changed as per the requirement.
compute_sum:
	mov [counting_adds],4h
	mov [counter_sum],90h
add_values:
	;read value from the 1st set of inputs
	mvi A,[counter_input]
	mov [operand_2],A
	;move value in 90h to add to corresponding ms value 
	mvi A,[counter_sum]
	add A,[operand_2]
	cmp A,3Ch	;compare each value with 60 so that when it exceeds 60, add 1 to next value in the sequence.
	jnc add_one	;if A is >= 3C increment the value in the sequence by 1
	;move the sum into 90h register which is designated to hold ms values
	dec [counter_sum]
	mvi [counter_sum],A
	dec [counting_adds]
	cmp [counting_adds],00	;compare if all 4 values are added. 
	jnz add_values
	dec [input_count]		;this counter keeps track of how many sets of values have been added.
	cmp [input_count],00
	jnz compute_sum		;if they are added then start adding new set of values to the existing sum.
	ljmp _avg_cal
	
	;incrementing the next value by 1
add_one:
	sub A,3Ch	;get the value to be written into 90h after subtracting the carry value 
	dec [counter_sum]
	mvi [counter_sum],A 
	mvi A,[counter_sum]	;read value in 91h so that carry value can be added to it
	add A,1		;add carry value
	dec [counter_sum]		
	mvi [counter_sum],A	;write back the value to 91h after adding carry.
	dec [counter_sum]	
	dec [counting_adds]
	cmp [counting_adds],00	;compare if all 4 values are added. 
	jnz add_values
	dec [input_count]		;this counter keeps track of how many sets of values have been added.
	cmp [input_count],00
	jnz compute_sum		;if they are added then start adding new set of values to the existing sum.
	ljmp _avg_cal

	;Computing average here
	
_avg_cal:
	mov [input_count],09h
	mov [72h],00h
	mov reg[CUR_PP], 06h
	mov [10h], [93h] 			;ram_2[10h]=value in 93h which is the sum of hours
	mov reg[CUR_PP], 00h		;set Current Page Pointer back to 0
	mov [EBh], 10h 				;initialize MVI read pointer to 10h
	mvi A, [EBh]				;read the value in 93h to A
	mov [86h],00h
	mov [result_avg],B0h
	mov [quotient_val], 00h
	
compute_avg_hr:
	cmp A,[input_count]
	jnc find_q_hr
	mov [85h],A					;85h holds the remainder
	mov A,[quotient_val]
	mvi [result_avg],A	;register 83h holds the quotient
	ljmp compute_avg_min

find_q_hr:
	sub A,[input_count]
	inc [quotient_val]
	ljmp compute_avg_hr
	
compute_avg_min:
	mov [72h],0Ah
	mov [61h],00h
	mov [68h],00h
	mov A,00h
	
Com_rem:
	mov [quotient_val],00h
	mov [75h], 06h
	
compute_prd:
	add A,[85h]
	dec [75h]
	cmp [75h],00h
	jnz compute_prd
	
compute_rem:
	cmp A,[input_count]
	jnc find_q1
	mov [86h],A			;86h holds the remainder
	mov [68h],[quotient_val]		;holds the quotient
	mov A,[68h]
	add [61h],A
	mov A,00h
	add A,[86h]			;add remainder to A and repeat the operation for "value in [input_count]" times
	dec [72h]
	cmp [72h],00h
	jnz Com_rem
	ljmp add_tonext

find_q1:
	sub A,[input_count]
	inc [quotient_val]
	ljmp compute_rem
	
add_tonext:
	mov reg[CUR_PP], 06h 		;set Current Page Pointer to 2
	mov [10h], [92h] 				
	mov reg[CUR_PP], 00h

	mov [EBh], 10h 		;initialize MVI read pointer to 10h
	mvi A, [EBh]		;read the value in 92h into A
	add A,[86h]
	mov [quotient_val],00h
	
compute_avg:
	cmp A,[input_count]
	jnc find_q_min
	mov [85h],A					;85h holds the remainder
	mov A,[quotient_val]
	add A,[61h]
	mvi [result_avg],A			;register 81h holds the quotient
	ljmp compute_avg_sec

find_q_min:
	sub A,[input_count]
	inc [quotient_val]
	ljmp compute_avg
	
compute_avg_sec:
	mov [72h],0Ah
	mov [61h],00h
	mov [68h],00h
	mov A,00h
	
Com_rem_sec:
	mov [quotient_val],00h
	mov [75h],06h	
	
compute_prd_sec:
	add A,[85h]
	dec [75h]
	cmp [75h],00h
	jnz compute_prd_sec
	
compute_rem_sec:
	cmp A,[input_count]
	jnc find_q1_sec
	mov [86h],A			;86h holds the remainder
	mov [68h],[quotient_val]		;holds the quotient
	mov A,[68h]
	add [61h],A
	mov A,00h
	add A,[86h]			;add remainder to A and repeat the operation for "value in [input_count]" times
	dec [72h]
	cmp [72h],00h
	jnz Com_rem_sec
	ljmp add_tonext_sec

find_q1_sec:
	sub A,[input_count]
	inc [quotient_val]
	ljmp compute_rem_sec
	
add_tonext_sec:
	mov reg[CUR_PP], 06h 		;set Current Page Pointer to 2
	mov [10h], [91h] 				
	mov reg[CUR_PP], 00h

	mov [EBh], 10h 		;initialize MVI read pointer to 10h
	mvi A, [EBh]		;read the value in 92h into A
	add A,[86h]
	mov [quotient_val],00h
	
compute_avg_sec1:
	cmp A,[input_count]
	jnc find_q_sec
	mov [85h],A					;85h holds the remainder
	mov A,[quotient_val]
	add A,[61h]
	mvi [result_avg],A					;register 81h holds the quotient
	ljmp compute_avg_end

find_q_sec:
	sub A,[input_count]
	inc [quotient_val]
	ljmp compute_avg_sec1
	
compute_avg_end:
	mov [counting_adds],B3h
	mov A,[85h]
	mvi [counting_adds],A
	
	mov [counter_input],B0h
	mvi A,[counter_input]
	mov [C0h],A
	mvi A,[counter_input]
	mov [C1h],A
	mvi A,[counter_input]
	mov [C2h],A
	mvi A,[counter_input]
	mov [C3h],A
	
	;Display
	lcall   LCD_Start       ; Initialize LCD
	mov    A,00h           ; Set cursor position at row = 0
   	mov    X,00h           ; col = 5
   	lcall   LCD_Position
   	mov    A, >STRING3     	; Higher byte
   	mov	   X, <STRING3
    lcall  LCD_PrCString   

	mov    A,01h           ; Set cursor position at row = 0
   	mov    X,00h           ; col = 5
   	lcall   LCD_Position
   	mov    A,[C0h]      	; Higher byte
    lcall   LCD_PrHexByte     
	
	mov    A,01h           ; Set cursor position at row = 0
   	mov    X,02h           ; col = 5
   	lcall   LCD_Position
   	mov    A, >THE_STRING20     	; Higher byte
   	mov	   X, <THE_STRING20
    lcall  LCD_PrCString          
	
  	mov    A,01h           ; Set cursor position at row = 0
   	mov    X,03h           ; col = 5
   	lcall   LCD_Position
   	mov    A,[C1h]      	; Lower byte
   	lcall   LCD_PrHexByte  
	
	mov    A,01h           ; Set cursor position at row = 0
   	mov    X,05h           ; col = 5
   	lcall   LCD_Position
   	mov    A, >THE_STRING20     	; Higher byte
	mov	   X, <THE_STRING20
    lcall   LCD_PrCString          
	
	mov    A,01h           ; Set cursor position at row = 0
   	mov    X,06h           ; col = 5
   	lcall   LCD_Position
   	mov    A,[C2h]      	; Load pointer to ROM string
   	lcall   LCD_PrHexByte   
	
	mov    A,01h           ; Set cursor position at row = 0
   	mov    X,08h           ; col = 5
   	lcall   LCD_Position
   	mov    A, >THE_STRING21      	; Higher byte
	mov	   X, <THE_STRING21
    lcall   LCD_PrCString          
	
	mov    A,01h           ; Set cursor position at row = 0
   	mov    X,09h           ; col = 5
   	lcall   LCD_Position
   	mov    A,[C3h]      	; Load pointer to ROM string
   	lcall   LCD_PrHexByte  

;ljmp loop
	
end_memory_mode:
	cmp [addr_shrt_p], 04h
	mov [addr_shrt_p], 00h
	
	mov A, 01h
	mov X, 00h
	lcall LCD_Position
	mov A, >CLEAN_LCD
	mov X, <CLEAN_LCD
	lcall LCD_PrCString
	ljmp loop


;---------------------END MEMORY MODE----------------------------------------
	
.terminate:
    ljmp .terminate
	
;---------------------END OF MAIN CODE----------------------------------------
;-----------------------------------------------------------------------------

divide_32_routine:	
	push X ; preserve the X register if necessary 
	mov A, >dRes ; push the address of result variable 
	push A 
	mov A, <dRes 
	push A 
	mov A, [dOpr2+0] ; push the second parameter dOpr2 
	push A 
	mov A, [dOpr2+1] 
	push A 
	mov A, [dOpr2+2] 
	push A 
	mov A, [dOpr2+3] 
	push A 
	mov A, [dOpr1+0] ; push the first parameter dOpr1 
	push A 
	mov A, [dOpr1+1] 
	push A 
	mov A, [dOpr1+2] 
	push A 
	mov A, [dOpr1+3] 
	push A 
	lcall divu_32x32_32 ; do the application 
	add SP, 246 ; pop the stack 
	pop X ; restore the X register if necessary
ret	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;alex charan
Sound_mode_generic_timer:
;check_run_timer:

	;lcall Display_Time_LCD
	;ljmp loop

		cmp [addr_acc_mode],sec_mode
		jz Sound_label_sec_mode

		cmp [addr_acc_mode],halfsec_mode
		jz Sound_label_halfsec_mode

	Sound_label_tenthsec_mode:
		;mov [addr_inc_ms], [addr_internal_inc_ms]
		mov [addr_inc_ms], [addr_timer_inc_ms]
		ljmp Sound_check_ms

	Sound_label_halfsec_mode: 
;		mov A, [addr_internal_inc_ms]
		mov A, [addr_timer_inc_ms]
		mov X, A
		cmp A, 32h
		jnz Sound_check_if_00
;		mov [addr_inc_ms], [addr_internal_inc_ms]
		mov [addr_inc_ms], [addr_timer_inc_ms]
		ljmp Sound_check_ms
	Sound_check_if_00:
		mov A, X
		cmp A, 00h
		jnz Sound_check_ms
;		mov [addr_inc_ms], [addr_internal_inc_ms]
		mov [addr_inc_ms], [addr_timer_inc_ms]
		ljmp Sound_check_ms
		
	Sound_label_sec_mode: 
;		mov A, [addr_internal_inc_ms]					;copy over because you need to compare
		mov A, [addr_timer_inc_ms]
		cmp A, 00h
		jnz Sound_check_ms									;keep display value as is
		;if it is 00 
;		mov [addr_inc_ms], [addr_internal_inc_ms]		;update value to be displayed
		mov [addr_inc_ms], [addr_timer_inc_ms]
		;ljmp Sound_check_ms
		

	Sound_check_ms:
;		mov A, [addr_internal_inc_ms] 	;
		mov A, [addr_timer_inc_ms] 	;
		cmp A, 64h 		;compare to 100
		jnz Sound_display_ms
		
	Sound_reset_ms:
;		mov [addr_internal_inc_ms], 00h
		mov [addr_timer_inc_ms], 00h
		inc [addr_inc_s]		;increment seconds
		
	Sound_display_ms:
		mov A, 00h
		mov X, 09h
		lcall LCD_Position
		mov A, [addr_inc_ms]
		lcall LCD_PrHexByte
		
	Sound_check_sec:	
		mov A, [addr_inc_s]	;move [251] to A as to not mess up the actual number in [251] during compare
		cmp A, 3Ch		;compare with 60
						;need to check CF : if it's not set than [251] is larger than 60
		jnz Sound_display_sec

	Sound_reset_sec:
		mov [addr_inc_s],00h
		inc [addr_inc_m]		;increment minutes
		
	Sound_display_sec:
	    mov A, 00h
		mov X, 06h
		lcall LCD_Position
		mov A, [addr_inc_s]
		lcall LCD_PrHexByte
		
		
	Sound_check_min:
		mov A, [addr_inc_m]	;move [251] to A as to not mess up the actual number in [251] during compare
		cmp A, 3Ch		;compare with 60
						;need to check CF : if it's not set than [251] is larger than 60
		jnz Sound_display_min

	Sound_reset_min:
		mov [addr_inc_s],00h
		inc [addr_inc_h]

	Sound_display_min:
	    mov A, 00h
		mov X, 03h
		lcall LCD_Position
		mov A, [addr_inc_m]
		lcall LCD_PrHexByte
		
	Sound_check_hour:
		mov A, [addr_inc_h]
		cmp A, 18h		;compare with 24
		jnz Sound_display_hour
		
	Sound_reset_hour:
		mov [addr_inc_h], 00h
		
	Sound_display_hour:
		mov A, 00h
		mov X, 00h
		lcall LCD_Position
		mov A, [addr_inc_h]
		lcall LCD_PrHexByte
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;-----------------------------------------------------------------------------
;---------------------ROUTINE lcallS-------------------------------------------


;---------------------END OF ROUTINE lcallS------------------------------------
;-----------------------------------------------------------------------------



.LITERAL 
THE_STRNG:
ds "EvryTng is Awsme"
db 00h
.ENDLITERAL 

.LITERAL 
TENTHSEC_MODE:
ds "ACC: TENTH      "
db 00h
.ENDLITERAL 

.LITERAL 
HALFSEC_MODE:
ds "ACC: HALF     "
db 00h
.ENDLITERAL 

.LITERAL 
SEC_MODE:
ds "ACC: SEC       "
db 00h
.ENDLITERAL 

.LITERAL 
ACCURACY_MODE:
ds "ACCURACY MODE "
db 00h
.ENDLITERAL

.LITERAL 
BUTTON_MODE:
ds "BUTTON MODE   "
db 00h
.ENDLITERAL

.LITERAL 
DEBUG_MODE:
ds "DEBUG MODE      "
db 00h
.ENDLITERAL

.LITERAL 
CLEAR_TIME:
ds "00:00:00:00     "
db 00h
.ENDLITERAL


.LITERAL 
MEMORY_MODE:
ds "MEMORY MODE   "
db 00h
.ENDLITERAL

.LITERAL 
THRESHOLD_MODE:
ds "THRESHOLD MODE"
db 00h
.ENDLITERAL

.LITERAL 
PRESS_TO_START:
ds "PRESS TO START  "
db 00h
.ENDLITERAL

.LITERAL 
CALC_THRESH_MODE:
ds "SAMPLING:       "
db 00h
.ENDLITERAL

.LITERAL 
WHISTLE_MODE:
ds "WHISTLE:        "
db 00h
.ENDLITERAL

.LITERAL 
SOUND_MODE:
ds "SOUND MODE    "
db 00h
.ENDLITERAL

.LITERAL 
SOUND_TIMER:
ds "START S TIMER   "
db 00h
.ENDLITERAL

.LITERAL 
STOP_SOUND_TIMER:
ds "STOP S TIMER    "
db 00h
.ENDLITERAL

.LITERAL 
CLEAN_LCD:
ds "                "
db 00h
.ENDLITERAL


.LITERAL 
SAVE:
ds "SAVE"
db 00h
.ENDLITERAL 

.LITERAL 
THREE_SPACE:
ds "   "
db 00h
.ENDLITERAL 

.LITERAL 
NINE_SPACE:
ds "         "
db 00h
.ENDLITERAL 

.LITERAL 
THE_STRING20:
ds ":"
db 00h
.ENDLITERAL 

.LITERAL 
THE_STRING21:
ds "."
db 00h
.ENDLITERAL 

.LITERAL 
STRING3:
ds "AVERAGE:    "
db 00h
.ENDLITERAL 

.LITERAL 
MINIMUM:
ds "MINIMUM:    "
db 00h
.ENDLITERAL 

.LITERAL 
MAXIMUM:
ds "MAXIMUM:    "
db 00h
.ENDLITERAL 
