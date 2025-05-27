; Rutina que copiar un bloque de datos inversamente desde cuyo primer byte que se indique es el ultimo


org #100

ORIGEN_FIN    EQU #FFFF		;; Fin del área de origen (pantalla)
DESTINO_INI   EQU #4000		;; Comienzo del destino
TAMANO        EQU #4000		;; Tamaño total del bloque a copiar (16 KB)

Start:
        ld hl, ORIGEN_FIN	;; HL apuntará al final de la pantalla (origen)
        ld de, DESTINO_INI	;; DE apunta al comienzo del área destino
        ld bc, TAMANO	        ;; Número de bytes a copiar (invertidos)

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
