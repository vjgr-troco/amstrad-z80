;---------------------------------------
; SPRITE XOR DEMO - MODO 0 - AMSTRAD CPC
; vjgr-troco - trocoloco  
;---------------------------------------
org &1000

start:
	
  

    xor a
    call &bc0e          ; establece modo 0
    
    di
    ld hl,&c9fb		; desactiva firmware
    ld (&0038),hl
    ei

    ld hl,paleta	; carga paleta de colores
    call inicializar_paleta


    ld bc,&bc0c		; memoria de video en #4000
    out (c),c
    inc b
    ld a,&10		
    out (c),a
    dec b
    inc c
    out (c),c
    inc b
    xor a
    out (c),a

 
main

    ld hl,&61A0         ; direccion donde se imprimira sprite
    ld de,Bola0		; datos sprite
   
    call draw_sprite_xor_mode0

    call pulsa_espacio
    call 0

;--------------------------------------
; RUTINA DE DIBUJO XOR DE SPRITE 16x16 EN MODO 0 (OPTIMIZADA)
;--------------------------------------
; Entradas:
; HL = direccion en pantalla (parte superior izquierda del sprite)
; DE = direccion del sprite (128 bytes, 8 por línea)
; Se asume sprite de 16 líneas y 8 bytes por línea (modo 0)
; Unrolled line loop - 5 bytes
; Calculo de siguiente linea preparado para pantalla en #4000 y #C000
; Usa SP como si fuera otro registro y hacer la suma

draw_sprite_xor_mode0:
    di
    ld (backup_sp+1),sp       
    ld sp,#7FB   	 ; suma salto de linea = #800 - bytes a pintar por linea
    ex af,af' 
    ld a,16              ; 16 lineas del sprite
next_sprite_line:
    ex af,af' 
;    ld b,8              ; 8 bytes por línea
draw_sprite_byte:	; pinta linea
    ld a,(de): xor (hl): ld (hl),a : inc de: inc hl
    ld a,(de): xor (hl): ld (hl),a : inc de: inc hl
    ld a,(de): xor (hl): ld (hl),a : inc de: inc hl
    ld a,(de): xor (hl): ld (hl),a : inc de: inc hl
    ld a,(de): xor (hl): ld (hl),a : inc de: inc hl
    add hl,sp		; 2048 (linea abajo) - 8 (ya avanzados) = 2040
    ld a,h : and &38	; ajusta direccion memoria para pantalla en #4000
    jr nz,no_wrap
    ld bc,80-#4000	; correccion de bloque en la RAM de video CPC
    add hl,bc
no_wrap:
    ex af,af'
    dec a
    jr nz,next_sprite_line
    backup_sp : ld sp,0
    ei
    ret

;configura modo y paleta de colores
inicializar_paleta:
    ld hl,paleta+16			
set_colores:
    ld bc,&7F10
bucle_colores:
    ld a,(hl)
    dec hl
    out (c),c
    out (c),a
    dec c
    jp p,bucle_colores
    ret

; Test teclado (tecla espacio)
pulsa_espacio:
    ld   bc,#f40e
    out  (c),c              ;; PPI 8255: write 14 to port A (D0-D7 of AY-3-8912)
    ld   bc,#f6c0
    out  (c),c              ;; AY-3-8912: BDIR=1, BC1=1: select R14 register (keyboard)
    ld   a,#00
    out  (c),a              ;; AY-3-8912: BDIR=0, BC1=0: inactive
    ld   bc,#f792
    out  (c),c              ;; PPI 8255: write to control reg.: set port A as input
    ld   bc,#f645
    out  (c),c              ;; AY-3-8912: BDIR=0, BC1=1 (transfert R14 to D0-D7)
    ld   b,#f4
    in   a,(c)              ;; PPI 8255: read port A (D0-D7 of AY-3-8912)
    ld   bc,#f782
    out  (c),c              ;; PPI 8255: write to control reg.: set port A as output
    ld   bc,#f609
    out  (c),c              ;; PPI 8255: select keyboard line 9
    rla                     ;; roll bit 0 to Carry (== 'space' key)
    jr   c,pulsa_espacio       ;; if not pressed, loop
    ret

	
;--------------------------------------
; DATOS DE SPRITE DE 10x16 (5 bytes x 16 lineas = 80 bytes)
;--------------------------------------

.Bola0
defb &00,&04,&F3,&08,&00; line 0
defb &00,&F3,&F3,&F3,&00; line 1
defb &10,&F3,&F3,&F3,&20; line 2
defb &10,&F3,&F3,&F3,&20; line 3
defb &F3,&F3,&F3,&F3,&F3; line 4
defb &F3,&F3,&0C,&F3,&F3; line 5
defb &59,&A6,&24,&59,&A6; line 6
defb &59,&A6,&24,&59,&A6; line 7
defb &59,&A6,&0C,&59,&A6; line 8
defb &59,&A6,&0C,&59,&A6; line 9
defb &F3,&F3,&0C,&F3,&F3; line 10
defb &F3,&F3,&F3,&F3,&F3; line 11
defb &10,&F3,&F3,&F3,&20; line 12
defb &10,&F3,&F3,&F3,&20; line 13
defb &00,&F3,&F3,&F3,&00; line 14
defb &00,&04,&F3,&08,&00; line 15

; colores
paleta 	db &55,&54,&46,&40,&4B,&4C,&57,&53,&5E,&5C,&56,&4E,&5D,&4A,&5B,&52
