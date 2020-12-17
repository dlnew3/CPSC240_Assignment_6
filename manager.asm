;==============================================================================================================
;Program name: "Harmonic Sum". This program is meant to calculate the 
;   Harmonic Sum of an inputted integer. Copyright (C) 2020 Dennis Newman
;This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License  *
;version 3 as published by the Free Software Foundation.                                                                    *
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied         *
;Warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.     *
;A copy of the GNU General Public License v3 is available here:  <https://www.gnu.org/licenses/>.
;==============================================================================================================

;==============================================================================================================
;Author Information
;       Author Name: Dennis Newman
;       Author email: dlnew3@csu.fullerton.edu
;;
;Program Information
;   Program Name: Harmonic Sum
;   Program Languages: One module in C++, two modules in x86
;   Date Program began: Dec. 8, 2020
;   Date Program completed:
;   Files in this program: main.cpp, manager.asm, read_clock.asm, r.sh
;   Status: In Progress
;;
;References for this program
;   Jorgensen, X86-64 Assembly Language Programming with Ubuntu, Version 1.1.40.
;;
;This File
;   File Name: manager.asm
;   Language: x86-64 with Intel Syntax
;   Assemble: nasm -f elf64 -l manager.lis -o manager.o manager.asm

;======= Beginning of Code Area ===================================================================================================

extern printf               ;External C++ function for writing to standard output devices
extern scanf                ;External C++ function for reading from standard input devices
extern getfreq          ;User-Defined function
;extern atof


;==================================================================================================================================
segment .data               ;Initialized Data goes here

start_tics dq 0
close_tics dq 0
input dq 0
output dq 0
fHarmonNumerator dq 1.0

numberFormat db "%ld", 0
stringFormat db "%s", 0

input_msg db "Please enter the number of terms to be included in the sum: ", 10, 0
error_msg db "Error: Inputted value is not a positive integer, closing program...", 10, 0
initial_tics db 10, "The clock is now %ld tics and the computation will begin.", 10, 0
column_head db 10, "Terms completed", 9, "Harmonic sum", 10 , 0
row_hsum db 9, "%ld", 9, "%lf", 10, 0
final_tics db 10, "The clock is now %ld tics, which equals %lf seconds.", 10, 0
exit_msg db "The harmonic sum will be returned to the driver.", 10, 0

;============Debug Statements==============
dbg_getfreq db "Clock Speed is %f GHz", 10, 0
dbg_tics db "Current tics = %ld tics", 10, 0
dbg_seconds db "Elapsed seconds = %.12lf seconds", 10, 0
dbg_input db "Received input = %ld.", 10, 0
dbg_block_conf db "Block completed", 10, 0 
dbg_float db "%lf", 10, 0
;============Debug Statements==============

global hsum     	        ;Makes manager callable by functions outside of file.

segment .bss


segment .text
hsum:

;==================================== Back-up GPRs ====================================
  push  rbp         ;Save a copy of the stack base pointer
  mov   rbp, rsp    ;We do this in order to be 100% compatible with C and C++.
  push  rbx         ;Back up rbx
  push  rcx         ;Back up rcx
  push  rdx         ;Back up rdx
  push  rsi         ;Back up rsi
  push  rdi         ;Back up rdi
  push  r8          ;Back up r8
  push  r9          ;Back up r9
  push  r10         ;Back up r10
  push  r11         ;Back up r11
  push  r12         ;Back up r12
  push  r13         ;Back up r13
  push  r14         ;Back up r14
  push  r15         ;Back up r15
  pushf             ;Back up rflags

;======================================================================================

;===================================Debug Section================================================
;; DEBUG getfreq
xor rax, rax
call getfreq
mov rax, 1
mov rdi, dbg_getfreq
call printf
;; DEBUG getfreq _END

;; DEBUG tics (START)
xor rax, rax
rdtsc
mov [start_tics], eax		; Lower half of RDTSC will be in eax
mov [start_tics+4], edx		; Upper half of RDTSC will be in edx
mov rdi, dbg_tics			; First parameter for printf
mov rsi, [start_tics]		; Second parameter for printf
call printf
;; DEBUG tics (START) _END

;; DEBUG tics (CLOSE)
xor rax, rax
rdtsc
mov [close_tics], eax		; Lower half of RDTSC will be in eax
mov [close_tics+4], edx		; Upper half of RDTSC will be in edx
mov rdi, dbg_tics			; First parameter for printf
mov rsi, [close_tics]		; Second parameter for printf
call printf
; DEBUG tics (CLOSE) _END

;; DEBUG SECONDS
; getfreq -> xmm15
xor rax, rax
call getfreq
mov r15, [close_tics]
sub r15, [start_tics]
cvtsi2sd xmm13, r15
mov rax, 0
movsd xmm15, xmm0
; Math part
mov r13, 0x41cdcd6500000000	; 1 billion
movq xmm12, r13				; xmm12 = 1bil
movsd xmm14, xmm15			; xmm14 = Clock Speed
mulsd xmm14, xmm12			; xmm14 = Clock Speed * 1bil
divsd xmm13, xmm14			; xmm13 = Elapsed time / (GHz * 1bil)
; printf part
mov rax, 1
mov rdi, dbg_seconds
mov rsi, r15
movsd xmm0, xmm13
call printf
;; DEBUG SECONDS _END
;===================================Debug Section================================================


;;	Input Message
mov rax, 0
mov rdi, input_msg
call printf
;;	Input Message _END

;;	Receive input
mov qword rdi, numberFormat
push qword -1                     	;Reserve space for input
push qword -1
mov qword rsi, rsp               	;Now rsi points to that dummy value on the stack
mov qword rax, 0                 	;No vector registers
call scanf                       	;Call the external function; the new value is placed into the location that rsi points to
pop qword r15                          	;First inputted integer is saved in r15
pop rax
mov [input], r15								
;; Receive input _END


;===================================Debug Section================================================
;; DEBUG INPUT
mov rdi, dbg_input
mov rsi, [input]
mov rax, 0
call printf
;; DEBUG INPUT _END					
;===================================Debug Section================================================

mov r15, 0                                  ; Initialize the loop counter to 0
mov r14, [input]					        ; Initialize counter validation to inputted value
movsd xmm15, [fHarmonNumerator]		  		; xmm15 = hsum numerator, always 1

;;	Output Column Head
mov qword rax, 0
mov rdi, stringFormat
mov rsi, column_head
call printf
;;	Output Column Head _END

;================================================================================================
;================================================================================================
;====================CODE STABLE UP TO THIS POINT. SEG FAULT DOWN BELOW==========================

mov rdi, dbg_input			; 
mov rsi, r14
call printf

movsd xmm0, [fHarmonNumerator]
mov rax, 1
mov rdi, dbg_float
call printf

;===================================Loop Start===================================================
hsum_loop:

;;	Loop Validation
xor rax, rax                       ;No data from the SSE will be printed
cmp r15, r14							; Compares r15 to r14
jg non_positive_input					; If r15 >= r14, input received is <= 1
;;	Loop Validation _END



;;	Loop Body
inc r15									; increment r15. Loop Counter and denominator
cvtsi2sd xmm14, r15						; Converts r15(Denominator) to xmm14 register
movsd xmm15, [fHarmonNumerator]
divsd xmm15, xmm14						; Division of Numerator(xmm15) by Denominator(xmm14)



; Add harmonic increment to sum
movsd xmm13, [output]
addsd xmm13, xmm15						; Adds the latest division to output total
movsd [output], xmm13


; Validation for output of terms
mov rax, r15
mov r9, 12
cqo
idiv r9									; rdx = rax(loop counter) % 12
cmp rdx, 0								
je term_output							; if counter is a multiple of 12, output the term
; Validation to continue Loop
cmp r15, r14							; if loop counter == input value...
je loop_end								; ... jump to closing statements
jmp hsum_loop							; else start hsum_loop all over again
;;	Loop Body _END

;;	Term Output
term_output:							;loop if term needs to be outputted
mov rax, 1
mov rdi, row_hsum
mov rsi, r15
movsd xmm0, [output]
call printf
jmp hsum_loop							;jumps back to start of hsum_loop
;;	Term Output _END
;===================================Loop End===================================================

non_positive_input:
mov rdi, error_msg
mov rax, 0
call printf


loop_end:
mov rdi, final_tics
mov rax, 1
mov rsi, r15
movsd xmm0, [output]
call printf

mov rdi, exit_msg
mov rax, [output]
call printf


;==================================== Restore GPRs ====================================
  popf              ;Restore rflags
  pop   r15         ;Restore r15
  pop   r14         ;Restore r14
  pop   r13         ;Restore r13
  pop   r12         ;Restore r12
  pop   r11         ;Restore r11
  pop   r10         ;Restore r10
  pop   r9          ;Restore r9
  pop   r8          ;Restore r8
  pop   rdi         ;Restore rdi
  pop   rsi         ;Restore rsi
  pop   rdx         ;Restore rdx
  pop   rcx         ;Restore rcx
  pop   rbx         ;Restore rbx
  pop   rbp         ;Return rbp to point to the base of the activation record of the caller.
;======================================================================================

  ret