;; Division numero 16 bits / 10
;; Si el numero es de 8 bits, se deriva a una funcion especifica y mas rapida
;; Input  / Entrada DE = signo 16 bits - 0 a 65535 
;; Output numero de  8 bits = A  / 17 nops
;; Output numero de 16 bits = DE / 262 +-5  nops

org &1000
nolist

ld de,#FF ; Entrada -> resultado / 10 = #15	
call division_entre_10
ret


division_entre_10:
	ld a,d			; valor alto del numero pasado por HL
	or a			; byte alto = 0?
	jr z,numero_8_bits 	; A = 0 = numero de 8 bits, sino continua operacion de 16 bits

;================================
; Rutina que divide numero de 16 bits entre 10
; Uso de logica de "long division" bit a bit, shift + resta
; Entrada
;   DE = numero a dividir (16 bits)
; Salida
;   DE = cociente (16 bits)
; ================================
numero_16_bits			; DIVIDISION ENTRE 256
	xor a			; A = resto = 0
	ld b,16			; B = numero de bits a procesar (16)
div10_bucle:
	sla e			; Desplaza DE << 1 (bit mas significativo en carry)
        rl d
	rl a  		        ; Mueve carry a A (resto <<= 1)
	cp 10
	jr c,no_resta
	sub 10 		        ; A -= 10
	inc e			; Suma 1 al bit del cociente
no_resta:
	djnz div10_bucle
	ret

; Rotacion del nibble alto al bajo para la division entre 10, sin resto	
numero_8_bits
	ld a,e
	srl a
	srl a
	srl a
	srl a
	ret
