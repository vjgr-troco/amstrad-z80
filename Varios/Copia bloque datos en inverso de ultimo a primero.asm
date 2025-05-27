; Rutinas que copian bloques de datos de forma inversa
; Origen A de ultimo a primero en Destino B y viceversa

org #100

;CopiaInvertida
ORIGEN_FIN    EQU #FFFF		;; Fin del área de origen (pantalla)
DESTINO_INI   EQU #4000		;; Comienzo del destino
TAMANO        EQU #4000		;; Tamaño total del bloque a copiar (16 KB)

;RevierteCopia

Start:
        ld hl, ORIGEN_FIN	;; HL apuntará al final de la pantalla (origen)
        ld de, DESTINO_INI	;; DE apunta al comienzo del área destino
        ld bc, TAMANO	        ;; Número de bytes a copiar (invertidos)
	call CopiaInvertida
		
	ld a,#40
        call #BC08

	ld hl,#c000
	ld (hl),0
	ld de,&c001
	ld bc,&3fff
	ldir

	ld hl,#4000		;; HL apunta al primer byte
	ld de,#FFFF		;; DE apunta al ultimo byte del bloque donde se copiara
	ld bc,#4000		;; Numero de bytes a copiar (de ultimo a primero)
	call RevierteCopia

	ld a,#C0
        call #BC08
	
	
	call #BB03
	call #BB18
	rst 0

;;--------------------------------------------------
;; Rutina que copia un bloque de datos inversamente desde cuyo primer byte que se indique es el ultimo
;; El destino de los bytes funciona inversamente a un LDD
;; ENTRADAS 
;; HL = Origen byte final ; DE = Destino byte inicio bloque hasta final ; BC = Tamanio de bloque a copiar

CopiaInvertida:
        ld a,(hl)		;; Leer byte desde el final de pantalla
        ld (de),a		;; Escribir byte en orden directo desde el inicio
        dec hl			;; Retroceder origen
        inc de			;; Avanzar destino
        dec bc			;; Decrementa contador
        ld a,b			;; comprueba que B y C valgan ambos 0
        or c			;; Cuenta llega a 0?
        jp nz, CopiaInvertida	;; Si B y C = 0 entonces fin
	ret
;;--------------------------------------------------
;; Rutina que copia un bloque de datos inversamente desde cuyo primer byte que se indique es el ultimo
;; El destino de los bytes funciona inversamente a un LDD
;; ENTRADAS 
;; HL = Origen byte inicial ; DE = Destino byte final bloque hasta inicial ; BC = Tamanio de bloque a copiar
RevierteCopia:
	ld a,(hl)
	ld (de),a
        inc hl
	dec de
 	dec bc
	ld a,b
	or c
	jp nz, RevierteCopia
	ret

	